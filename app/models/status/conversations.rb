# frozen_string_literal: true

module Status::Conversations
  extend ActiveSupport::Concern

  included do
    belongs_to :conversation, optional: true

    has_one :owned_conversation, class_name: 'Conversation', foreign_key: 'parent_status_id', inverse_of: :parent_status, dependent: nil

    before_validation :set_conversation

    after_create :update_conversation

    # The `prepend: true` option below ensures this runs before
    # the `dependent: destroy` callbacks remove relevant records
    before_destroy :unlink_from_conversations!, prepend: true
  end

  def unlink_from_conversations!
    return unless direct_visibility?

    inbox_owners = mentioned_accounts.local
    inbox_owners += [account] if account.local?

    inbox_owners.each do |inbox_owner|
      AccountConversation.remove_status(inbox_owner, self)
    end
  end

  private

  def set_conversation
    self.thread = thread.reblog if thread&.reblog?

    self.reply = !(in_reply_to_id.nil? && thread.nil?) unless reply

    if reply? && !thread.nil?
      self.in_reply_to_account_id = carried_over_reply_to_account_id
      self.conversation_id        = thread.conversation_id if conversation_id.nil?
    elsif conversation_id.nil?
      build_conversation
    end
  end

  def update_conversation
    return if reply?

    conversation.update!(parent_status: self, parent_account: account) if conversation && conversation.parent_status.nil?
  end
end
