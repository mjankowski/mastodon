# frozen_string_literal: true

class AddUsersCountToUserRoles < ActiveRecord::Migration[7.1]
  def change
    add_column :user_roles, :users_count, :integer

    reversible do |dir|
      dir.up do
        safety_assured { populate_values }
      end
    end
  end

  def populate_values
    execute <<-SQL.squish
      UPDATE user_roles
        SET users_count = (
          SELECT COUNT(1)
          FROM users
          WHERE users.role_id = user_roles.id
        )
    SQL
  end
end
