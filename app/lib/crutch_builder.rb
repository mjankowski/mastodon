# frozen_string_literal: true

class CrutchBuilder
  def crutches(receiver_id, statuses, list: nil)
    crutches = {}

    crutches[:active_mentions] = crutches_active_mentions(statuses)

    check_for_blocks = statuses.flat_map do |s|
      arr = crutches[:active_mentions][s.id] || []
      arr.push(s.account_id)

      if s.reblog? && s.reblog.present?
        arr.push(s.reblog.account_id)
        arr.concat(crutches[:active_mentions][s.reblog_of_id] || [])
      end

      arr
    end

    crutches[:following]            = crutches_following(receiver_id, statuses, list)
    crutches[:languages]            = Follow.where(account_id: receiver_id, target_account_id: statuses.map(&:account_id)).pluck(:target_account_id, :languages).to_h
    crutches[:hiding_reblogs]       = Follow.where(account_id: receiver_id, target_account_id: statuses.filter_map { |s| s.account_id if s.reblog? }, show_reblogs: false).pluck(:target_account_id).index_with(true)
    crutches[:blocking]             = Block.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).index_with(true)
    crutches[:muting]               = Mute.where(account_id: receiver_id, target_account_id: check_for_blocks).pluck(:target_account_id).index_with(true)
    crutches[:domain_blocking]      = AccountDomainBlock.where(account_id: receiver_id, domain: statuses.flat_map { |s| [s.account.domain, s.reblog&.account&.domain] }.compact).pluck(:domain).index_with(true)
    crutches[:blocked_by]           = Block.where(target_account_id: receiver_id, account_id: statuses.map { |s| [s.account_id, s.reblog&.account_id] }.flatten.compact).pluck(:account_id).index_with(true)
    crutches[:exclusive_list_users] = crutches_exclusive_list_users(receiver_id, statuses) if list.blank?

    crutches
  end

  def crutches_exclusive_list_users(recipient_id, statuses)
    lists = List.where(account_id: recipient_id, exclusive: true)
    ListAccount.where(list: lists, account_id: statuses.map(&:account_id)).pluck(:account_id).index_with(true)
  end

  def crutches_following(recipient_id, statuses, list)
    if list.blank? || list.show_followed?
      Follow.where(account_id: recipient_id, target_account_id: statuses.filter_map(&:in_reply_to_account_id)).pluck(:target_account_id).index_with(true)
    elsif list.show_list?
      ListAccount.where(list_id: list.id, account_id: statuses.filter_map(&:in_reply_to_account_id)).pluck(:account_id).index_with(true)
    else
      {}
    end
  end

  def crutches_active_mentions(statuses)
    Mention
      .active
      .where(status_id: statuses.flat_map { |status| [status.id, status.reblog_of_id] }.compact)
      .pluck(:status_id, :account_id)
      .each_with_object({}) { |(id, account_id), mapping| (mapping[id] ||= []).push(account_id) }
  end
end
