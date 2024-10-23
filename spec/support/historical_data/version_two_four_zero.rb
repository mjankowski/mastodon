# frozen_string_literal: true

module HistoricalData
  class VersionTwoFourZero
    MIGRATION_TARGET = 2018_05_14_140000

    def populate
      ActiveRecord::Base.connection.execute(<<~SQL.squish)
        INSERT INTO "settings"
          (id, thing_type, thing_id, var, value, created_at, updated_at)
        VALUES
          (1, 'User', 1, 'hide_network', E'--- false\n', now(), now()),
          (2, 'User', 2, 'hide_network', E'--- true\n', now(), now());
      SQL
    end
  end
end
