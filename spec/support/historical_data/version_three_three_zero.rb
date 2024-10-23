# frozen_string_literal: true

module HistoricalData
  class VersionThreeThreeZero
    MIGRATION_TARGET = 2020_12_18_054746

    def populate
      ActiveRecord::Base.connection.execute(<<~SQL.squish)
        INSERT INTO "webauthn_credentials"
          (user_id, nickname, external_id, public_key, created_at, updated_at)
        VALUES
          (1, 'foo', 1, 'foo', now(), now()),
          (1, 'foo', 2, 'bar', now(), now());

        INSERT INTO "account_aliases"
          (account_id, uri, acct, created_at, updated_at)
        VALUES
          (1, 'https://example.com/users/foobar', 'foobar@example.com', now(), now()),
          (1, 'https://example.com/users/foobar', 'foobar@example.com', now(), now());

        /* Doorkeeper records
           While the `read:me` scope was technically not valid in 3.3.0,
           it is still useful for the purposes of testing the `ChangeReadMeScopeToProfile`
           migration.
        */

        INSERT INTO "oauth_applications"
          (id, name, uid, secret, redirect_uri, scopes, created_at, updated_at)
        VALUES
          (2, 'foo', 'foo', 'foo', 'https://example.com/#foo', 'write:accounts read:me', now(), now()),
          (3, 'bar', 'bar', 'bar', 'https://example.com/#bar', 'read:me', now(), now());

        INSERT INTO "oauth_access_tokens"
          (token, application_id, scopes, resource_owner_id, created_at)
        VALUES
          ('secret', 2, 'write:accounts read:me', 4, now());
      SQL
    end
  end
end
