# frozen_string_literal: true

class AddStatCheckConstraints < ActiveRecord::Migration[7.1]
  def change
    add_check_constraint :account_stats, 'following_count >= 0', name: :following_count_check, validate: false
    add_check_constraint :account_stats, 'followers_count >= 0', name: :followers_count_check, validate: false
    add_check_constraint :account_stats, 'statuses_count >= 0', name: :statuses_count_check, validate: false

    add_check_constraint :status_stats, 'replies_count >= 0', name: :replies_count_check, validate: false
    add_check_constraint :status_stats, 'reblogs_count >= 0', name: :reblogs_count_check, validate: false
    add_check_constraint :status_stats, 'favourites_count >= 0', name: :favourites_count_check, validate: false
  end
end
