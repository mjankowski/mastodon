# frozen_string_literal: true

class Mover::Blocks
  def initialize(source_account, target_account)
    @source_account = source_account
    @target_account = target_account
  end

  def move
    blocks_targeting_source.find_each do |block|
      move_block(block) unless skip_block_move?(block)
    end
  end

  private

  def move_block(block)
    BlockService.new.call(block.account, @target_account)
    add_account_note(block.account) unless note_exists?(block.account)
  end

  def blocks_targeting_source
    @source_account
      .blocked_by_relationships
      .where(account: Account.local)
  end

  def skip_block_move?(block)
    block.account.blocking?(@target_account) || block.account.following?(@target_account)
  end

  def add_account_note(account)
    @target_account.targeted_account_notes.create!(account:, comment: text_for(account))
  end

  def note_exists?(account)
    @target_account.targeted_account_notes.exists?(account:)
  end

  def text_for(account)
    I18n.with_locale(account.user_locale.presence || I18n.default_locale) do
      I18n.t('move_handler.carry_blocks_over_text', acct: @source_account.acct)
    end
  end
end
