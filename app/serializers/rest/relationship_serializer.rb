# frozen_string_literal: true

class REST::RelationshipSerializer < REST::BaseSerializer
  # Please update `app/javascript/mastodon/api_types/relationships.ts` when making changes to the attributes

  object_as :account

  attribute :id do
    account.id.to_s
  end

  attribute :following do
    options[:relationships].following[account.id] ? true : false
  end

  attribute :showing_reblogs do
    (options[:relationships].following[account.id] || {})[:reblogs] ||
      (options[:relationships].requested[account.id] || {})[:reblogs] ||
      false
  end

  attribute :notifying do
    (options[:relationships].following[account.id] || {})[:notify] ||
      (options[:relationships].requested[account.id] || {})[:notify] ||
      false
  end

  attribute :languages do
    (options[:relationships].following[account.id] || {})[:languages] ||
      (options[:relationships].requested[account.id] || {})[:languages]
  end

  attribute :followed_by do
    options[:relationships].followed_by[account.id] || false
  end

  attribute :blocking do
    options[:relationships].blocking[account.id] || false
  end

  attribute :blocked_by do
    options[:relationships].blocked_by[account.id] || false
  end

  attribute :muting do
    options[:relationships].muting[account.id] ? true : false
  end

  attribute :muting_notifications do
    (options[:relationships].muting[account.id] || {})[:notifications] || false
  end

  attribute :requested do
    options[:relationships].requested[account.id] ? true : false
  end

  attribute :requested_by do
    options[:relationships].requested_by[account.id] ? true : false
  end

  attribute :domain_blocking do
    options[:relationships].domain_blocking[account.id] || false
  end

  attribute :endorsed do
    options[:relationships].endorsed[account.id] || false
  end

  attribute :note do
    (options[:relationships].account_note[account.id] || {})[:comment] || ''
  end
end
