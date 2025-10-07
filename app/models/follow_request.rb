# frozen_string_literal: true

class FollowRequest < ApplicationRecord
  include Paginable
  include RelationshipCacheable
  include RateLimitable
  include FollowLimitable

  belongs_to :account
  belongs_to :target_account, class_name: 'Account'

  has_one :notification, as: :activity, dependent: :destroy

  validates :account_id, uniqueness: { scope: :target_account_id }
  validates :languages, language: true

  def authorize!
    follow = account.follow!(target_account, reblogs: show_reblogs, notify: notify, languages: languages, uri: uri, bypass_limit: true)

    if account.local?
      ListAccount.where(follow_request: self).update_all(follow_request_id: nil, follow_id: follow.id)
      MergeWorker.perform_async(target_account.id, account.id, 'home')
      MergeWorker.push_bulk(account.owned_lists.with_list_account(target_account).pluck(:id)) do |list_id|
        [target_account.id, list_id, 'list']
      end
    end

    destroy!
  end

  alias reject! destroy!
end
