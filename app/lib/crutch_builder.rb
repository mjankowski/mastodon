# frozen_string_literal: true

class CrutchBuilder
  attr_reader :receiver_id, :statuses, :list

  attr_accessor :crutches

  def initialize(receiver_id, statuses, list: nil)
    @receiver_id = receiver_id
    @statuses = statuses
    @list = list
    @crutches = {}
    generate
  end

  private

  def generate
    crutches.tap do |crutches|
      crutches[:active_mentions] = crutches_active_mentions(statuses)

      check_for_blocks = block_candidates

      crutches[:following] = crutches_following
      crutches[:languages] = crutches_languages
      crutches[:hiding_reblogs] = crutches_hiding_reblogs
      crutches[:blocking] = crutches_blocking(check_for_blocks)
      crutches[:muting] = crutches_muting(check_for_blocks)
      crutches[:domain_blocking] = crutches_domain_blocking
      crutches[:blocked_by] = crutches_blocked_by
      crutches[:exclusive_list_users] = crutches_exclusive_list_users if list.blank?
    end
  end

  def block_candidates
    @block_candidates ||= statuses.flat_map do |status|
      collection = crutches[:active_mentions][status.id] || []
      collection.push(status.account_id)

      if status.reblog? && status.reblog.present?
        collection.push(status.reblog.account_id)
        collection.concat(crutches[:active_mentions][status.reblog_of_id] || [])
      end

      collection
    end
  end

  def crutches_blocked_by
    Block
      .where(target_account_id: receiver_id, account_id: statuses_and_reblogs_account_ids)
      .pluck(:account_id)
      .index_with(true)
  end

  def statuses_and_reblogs_account_ids
    statuses
      .map { |status| [status.account_id, status.reblog&.account_id] }
      .flatten
      .compact
  end

  def crutches_domain_blocking
    AccountDomainBlock
      .where(account_id: receiver_id, domain: statuses_and_reblogs_account_domains)
      .pluck(:domain)
      .index_with(true)
  end

  def statuses_and_reblogs_account_domains
    statuses
      .flat_map { |status| [status.account.domain, status.reblog&.account&.domain] }
      .compact
  end

  def crutches_hiding_reblogs
    Follow
      .where(account_id: receiver_id, target_account_id: reblog_statuses_account_ids, show_reblogs: false)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def reblog_statuses_account_ids
    statuses
      .filter_map { |status| status.account_id if status.reblog? }
  end

  def crutches_languages
    Follow
      .where(account_id: receiver_id, target_account_id: statuses.map(&:account_id))
      .pluck(:target_account_id, :languages)
      .to_h
  end

  def crutches_exclusive_list_users
    lists = List.where(account_id: receiver_id, exclusive: true)
    ListAccount
      .where(list: lists, account_id: statuses.map(&:account_id))
      .pluck(:account_id)
      .index_with(true)
  end

  def crutches_muting(check_for_blocks)
    Mute
      .where(account_id: receiver_id, target_account_id: check_for_blocks)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def crutches_blocking(check_for_blocks)
    Block
      .where(account_id: receiver_id, target_account_id: check_for_blocks)
      .pluck(:target_account_id)
      .index_with(true)
  end

  def crutches_following
    if list.blank? || list.show_followed?
      Follow
        .where(account_id: receiver_id, target_account_id: statuses.filter_map(&:in_reply_to_account_id))
        .pluck(:target_account_id)
        .index_with(true)
    elsif list.show_list?
      ListAccount
        .where(list_id: list.id, account_id: statuses.filter_map(&:in_reply_to_account_id))
        .pluck(:account_id)
        .index_with(true)
    else
      {}
    end
  end

  def crutches_active_mentions(_statuses)
    Mention
      .active
      .where(status_id: statuses_and_reblogs_ids)
      .pluck(:status_id, :account_id)
      .each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }
  end

  def statuses_and_reblogs_ids
    statuses
      .flat_map { |status| [status.id, status.reblog_of_id] }
      .compact
  end
end
