# frozen_string_literal: true

require_relative 'base'

module Mastodon::CLI
  class Cache < Base
    desc 'clear', 'Clear out the cache storage'
    def clear
      command_cache_clear.clear_rails_cache
      say('OK', :green)
    end

    option :concurrency, type: :numeric, default: 5, aliases: [:c]
    option :verbose, type: :boolean, aliases: [:v]
    desc 'recount TYPE', 'Update hard-cached counters'
    long_desc <<~LONG_DESC
      Update hard-cached counters of TYPE by counting referenced
      records from scratch. TYPE can be "accounts" or "statuses".

      It may take a very long time to finish, depending on the
      size of the database.
    LONG_DESC
    def recount(type)
      processed, _aggregate = process_recount(type)

      say
      say("OK, recounted #{processed} records", :green)
    end

    private

    def process_recount(type)
      case type.to_sym
      when :accounts
        command_cache_recount.recount_accounts
      when :statuses
        command_cache_recount.recount_statuses
      else
        fail_with_message "Unknown type: #{type}"
      end
    end

    def command_cache_clear
      Commands::Cache::Clear.new
    end

    def command_cache_recount
      Commands::Cache::Recount.new
    end
  end
end
