# frozen_string_literal: true

module HistoricalData
  class VersionTwoFourThree
    MIGRATION_TARGET = 2018_07_07_154237

    def populate
      user_key = OpenSSL::PKey::RSA.new(2048)
      user_private_key = ActiveRecord::Base.connection.quote(user_key.to_pem)
      user_public_key = ActiveRecord::Base.connection.quote(user_key.public_key.to_pem)

      ActiveRecord::Base.connection.execute(<<~SQL)
        INSERT INTO "custom_filters"
          (id, account_id, phrase, context, whole_word, irreversible, created_at, updated_at)
        VALUES
          (1, 2, 'test', '{ "home", "public" }', true, true, now(), now()),
          (2, 2, 'take', '{ "home" }', false, false, now(), now());

        -- Orphaned admin action logs

        INSERT INTO "admin_action_logs"
          (account_id, action, target_type, target_id, created_at, updated_at)
        VALUES
          (1, 'destroy', 'Account', 1312, now(), now()),
          (1, 'destroy', 'User', 1312, now(), now()),
          (1, 'destroy', 'Report', 1312, now(), now()),
          (1, 'destroy', 'DomainBlock', 1312, now(), now()),
          (1, 'destroy', 'EmailDomainBlock', 1312, now(), now()),
          (1, 'destroy', 'Status', 1312, now(), now()),
          (1, 'destroy', 'CustomEmoji', 1312, now(), now());

        INSERT INTO "domain_blocks"
          (id, domain, created_at, updated_at)
        VALUES
          (1, 'example.org', now(), now());

        INSERT INTO "email_domain_blocks"
          (id, domain, created_at, updated_at)
        VALUES
          (1, 'example.org', now(), now());

        -- Admin action logs with linked objects

        INSERT INTO "admin_action_logs"
          (account_id, action, target_type, target_id, created_at, updated_at)
        VALUES
          (1, 'destroy', 'Account', 1, now(), now()),
          (1, 'destroy', 'User', 1, now(), now()),
          (1, 'destroy', 'DomainBlock', 1, now(), now()),
          (1, 'destroy', 'EmailDomainBlock', 1, now(), now()),
          (1, 'destroy', 'Status', 1, now(), now()),
          (1, 'destroy', 'CustomEmoji', 3, now(), now());

        INSERT INTO "settings"
          (id, thing_type, thing_id, var, value, created_at, updated_at)
        VALUES
          (3, 'User', 1, 'notification_emails', E'--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nfollow: false\nreblog: true\nfavourite: true\nmention: false\nfollow_request: true\ndigest: true\nreport: true\npending_account: false\ntrending_tag: true\nappeal: true\n', now(), now()),
          (4, 'User', 1, 'trends', E'--- false\n', now(), now());

        INSERT INTO "accounts"
          (id, username, domain, private_key, public_key, created_at, updated_at)
        VALUES
          (10, 'kmruser', NULL, #{user_private_key}, #{user_public_key}, now(), now()),
          (11, 'qcuser', NULL, #{user_private_key}, #{user_public_key}, now(), now());

        INSERT INTO "users"
          (id, account_id, email, created_at, updated_at, admin, locale, chosen_languages)
        VALUES
          (4, 10, 'kmruser@localhost', now(), now(), false, 'ku', '{en,kmr,ku,ckb}');

        INSERT INTO "users"
          (id, account_id, email, created_at, updated_at, locale,
           encrypted_otp_secret, encrypted_otp_secret_iv, encrypted_otp_secret_salt,
           otp_required_for_login)
        VALUES
          (5, 11, 'qcuser@localhost', now(), now(), 'fr-QC',
           E'Fttsy7QAa0edaDfdfSz094rRLAxc8cJweDQ4BsWH/zozcdVA8o9GLqcKhn2b\nGi/V\n',
           'rys3THICkr60BoWC',
           '_LMkAGvdg7a+sDIKjI3mR2Q==',
           true);

        INSERT INTO "settings"
          (id, thing_type, thing_id, var, value, created_at, updated_at)
        VALUES
          (5, 'User', 4, 'default_language', E'--- kmr\n', now(), now()),
          (6, 'User', 1, 'interactions', E'--- !ruby/hash:ActiveSupport::HashWithIndifferentAccess\nmust_be_follower: false\nmust_be_following: true\nmust_be_following_dm: false\n', now(), now());

        INSERT INTO "identities"
          (provider, uid, user_id, created_at, updated_at)
        VALUES
          ('foo', 0, 1, now(), now()),
          ('foo', 0, 1, now(), now());
      SQL
    end
  end
end
