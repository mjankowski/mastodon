# frozen_string_literal: true

class ValidateStatCheckConstraints < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :account_stats, name: :following_count_check
    validate_check_constraint :account_stats, name: :followers_count_check
    validate_check_constraint :account_stats, name: :statuses_count_check

    validate_check_constraint :status_stats, name: :replies_count_check
    validate_check_constraint :status_stats, name: :reblogs_count_check
    validate_check_constraint :status_stats, name: :favourites_count_check
  end
end
