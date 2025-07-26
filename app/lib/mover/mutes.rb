# frozen_string_literal: true

class Mover::Mutes
  def initialize(source_account, target_account)
    @source_account = source_account
    @target_account = target_account
  end

  def move
    mutes_targeting_source.find_each do |mute|
      move_mute(mute) unless skip_mute_move?(mute)
    end
  end

  private

  def move_mute(mute)
    MuteService.new.call(mute.account, @target_account, notifications: mute.hide_notifications)
    add_account_note(mute.account) unless note_exists?(mute.account)
  end

  def mutes_targeting_source
    @source_account
      .muted_by_relationships
      .where(account: Account.local)
  end

  def skip_mute_move?(mute)
    mute.account.muting?(@target_account) || mute.account.following?(@target_account)
  end

  def add_account_note(account)
    @target_account.targeted_account_notes.create!(account:, comment: text_for(account))
  end

  def note_exists?(account)
    @target_account.targeted_account_notes.exists?(account:)
  end

  def text_for(account)
    I18n.with_locale(account.user_locale.presence || I18n.default_locale) do
      I18n.t('move_handler.carry_mutes_over_text', acct: @source_account.acct)
    end
  end
end
