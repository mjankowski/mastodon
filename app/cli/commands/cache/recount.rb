# frozen_string_literal: true

module Commands
  module Cache
    class Recount
      def recount_accounts
        # parallelize_with_progress(accounts_with_stats) do |account|
        accounts_with_stats.each do |account|
          recount_account_stats(account)
        end
      end

      def recount_statuses
        # parallelize_with_progress(statuses_with_stats) do |status|
        statuses_with_stats.each do |status|
          recount_status_stats(status)
        end
      end

      private

      def accounts_with_stats
        Account.local.includes(:account_stat)
      end

      def statuses_with_stats
        Status.includes(:status_stat)
      end

      def recount_account_stats(account)
        account.account_stat.tap do |account_stat|
          account_stat.following_count = account.active_relationships.count
          account_stat.followers_count = account.passive_relationships.count
          account_stat.statuses_count = account.statuses.not_direct_visibility.count

          account_stat.save if account_stat.changed?
        end
      end

      def recount_status_stats(status)
        status.status_stat.tap do |status_stat|
          status_stat.replies_count = status.replies.not_direct_visibility.count
          status_stat.reblogs_count = status.reblogs.count
          status_stat.favourites_count = status.favourites.count

          status_stat.save if status_stat.changed?
        end
      end
    end
  end
end
