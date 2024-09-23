# frozen_string_literal: true

class BlockMigrator < BaseMigrator
  def call
    local_source_blocked_by_relationships.find_each do |block|
      unless blocking_or_following_target?(block.account)
        call_block_service(block)
        add_account_note_if_needed!(block.account, 'move_handler.carry_blocks_over_text')
      end
    end
  end

  private

  def call_block_service(block)
    BlockService
      .new
      .call(
        block.account,
        @target_account
      )
  end

  def local_source_blocked_by_relationships
    @source_account
      .blocked_by_relationships
      .where(account: Account.local)
  end

  def blocking_or_following_target?(account)
    account.blocking?(@target_account) || account.following?(@target_account)
  end
end
