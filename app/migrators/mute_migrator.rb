# frozen_string_literal: true

class MuteMigrator < BaseMigrator
  def call
    local_source_muted_by_relationships.find_each do |mute|
      call_mute_service(mute) unless muting_or_following_target?(mute.account)
      add_account_note_if_needed!(mute.account, 'move_handler.carry_mutes_over_text')
    end
  end

  private

  def call_mute_service(mute)
    MuteService
      .new
      .call(
        mute.account,
        @target_account,
        notifications: mute.hide_notifications
      )
  end

  def local_source_muted_by_relationships
    @source_account
      .muted_by_relationships
      .where(account: Account.local)
  end

  def muting_or_following_target?(account)
    account.muting?(@target_account) || account.following?(@target_account)
  end
end
