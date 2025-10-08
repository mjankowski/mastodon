# frozen_string_literal: true

class BulkImportRow < ApplicationRecord
  belongs_to :bulk_import

  def to_csv
    case bulk_import.type.to_sym
    when :following
      [data['acct'], data.fetch('show_reblogs', true), data.fetch('notify', false), language_list]
    when :blocking
      [data['acct']]
    when :muting
      [data['acct'], data.fetch('hide_notifications', true)]
    when :domain_blocking
      [data['domain']]
    when :bookmarks
      [data['uri']]
    when :lists
      [data['list_name'], data['acct']]
    end
  end

  private

  def language_list
    data['languages']&.join(', ')
  end
end
