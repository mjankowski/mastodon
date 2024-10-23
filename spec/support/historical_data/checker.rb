# frozen_string_literal: true

module HistoricalData
  class Checker
    MODELS = [
      Account,
      AccountAlias,
      AccountConversation,
      Admin::ActionLog,
      Doorkeeper::Application,
      Identity,
      NotificationPolicy,
      PreviewCard,
      Status,
      User,
      WebauthnCredential,
    ].freeze

    attr_accessor :errors

    def initialize
      MODELS.each(&:reset_column_information)
      @errors = []
    end

    def validate
      unless Account.find_by(username: 'admin', domain: nil)&.hide_collections? == false
        @errors << 'Unexpected value for Account#hide_collections? for user @admin'
        exit(1)
      end

      unless Account.find_by(username: 'user', domain: nil)&.hide_collections? == true
        @errors << 'Unexpected value for Account#hide_collections? for user @user'
        exit(1)
      end

      unless Account.find_by(username: 'evil', domain: 'activitypub.com')&.suspended?
        @errors << 'Unexpected value for Account#suspended? for user @evil@activitypub.com'
        exit(1)
      end

      unless Status.find(6).account_id == Status.find(7).account_id
        @errors << 'Users @remote@remote.com and @Remote@remote.com not properly merged'
        exit(1)
      end

      if Account.exists?(domain: Rails.configuration.x.local_domain)
        @errors << 'Faux remote accounts not properly cleaned up'
        exit(1)
      end

      unless AccountConversation.first&.last_status_id == 11
        @errors << 'AccountConversation records not created as expected'
        exit(1)
      end

      if Account.find(Account::INSTANCE_ACTOR_ID).private_key.blank?
        @errors << 'Instance actor does not have a private key'
        exit(1)
      end

      unless Account.find_by(username: 'user', domain: nil).custom_filters.map { |filter| filter.keywords.pluck(:keyword) } == [['test'], ['take']]
        @errors << 'CustomFilterKeyword records not created as expected'
        exit(1)
      end

      unless Admin::ActionLog.find_by(target_type: 'DomainBlock', target_id: 1).human_identifier == 'example.org'
        @errors << 'Admin::ActionLog domain block records not updated as expected'
        exit(1)
      end

      unless Admin::ActionLog.find_by(target_type: 'EmailDomainBlock', target_id: 1).human_identifier == 'example.org'
        @errors << 'Admin::ActionLog email domain block records not updated as expected'
        exit(1)
      end

      unless User.find(1).settings['notification_emails.favourite'] == true && User.find(1).settings['notification_emails.mention'] == false
        @errors << 'User settings not kept as expected'
        exit(1)
      end

      unless User.find(1).settings['web.trends'] == false
        @errors << 'User settings not kept as expected'
        exit(1)
      end

      unless Account.find_remote('bob', 'ActivityPub.com').domain == 'activitypub.com'
        @errors << 'Account domains not properly normalized'
        exit(1)
      end

      unless PreviewCard.where(id: PreviewCardsStatus.where(status_id: 12).select(:preview_card_id)).pluck(:url) == ['https://joinmastodon.org/']
        @errors << 'Preview cards not deduplicated as expected'
        exit(1)
      end

      unless Account.find_local('kmruser').user.chosen_languages == %w(en ku ckb)
        @errors << 'Chosen languages not migrated as expected for kmr users'
        exit(1)
      end

      unless Account.find_local('kmruser').user.settings['default_language'] == 'ku'
        @errors << 'Default posting language not migrated as expected for kmr users'
        exit(1)
      end

      unless Account.find_local('qcuser').user.locale == 'fr-CA'
        @errors << 'Locale for fr-QC users not updated to fr-CA as expected'
        exit(1)
      end

      policy = NotificationPolicy.find_by(account: User.find(1).account)
      unless policy.for_private_mentions == 'accept' && policy.for_not_following == 'filter'
        @errors << "Notification policy not migrated as expected: #{policy.for_private_mentions.inspect}, #{policy.for_not_following.inspect}"
        exit(1)
      end

      unless Identity.where(provider: 'foo', uid: 0).count == 1
        @errors << 'Identities not deduplicated as expected'
        exit(1)
      end

      unless WebauthnCredential.where(user_id: 1, nickname: 'foo').count == 1
        @errors << 'Webauthn credentials not deduplicated as expected'
        exit(1)
      end

      unless AccountAlias.where(account_id: 1, uri: 'https://example.com/users/foobar').count == 1
        @errors << 'Account aliases not deduplicated as expected'
        exit(1)
      end

      # This is checking the attribute rather than the method, to avoid the legacy fallback
      # and ensure the data has been migrated
      unless Account.find_local('qcuser').user[:otp_secret] == 'anotpsecretthatshouldbeencrypted'
        @errors << 'OTP secret for user not preserved as expected'
        exit(1)
      end

      unless Doorkeeper::Application.find(2)[:scopes] == 'write:accounts profile'
        @errors << 'Application OAuth scopes not rewritten as expected'
        exit(1)
      end

      unless Doorkeeper::Application.find(2).access_tokens.first[:scopes] == 'write:accounts profile'
        @errors << 'OAuth access token scopes not rewritten as expected'
        exit(1)
      end
    end
  end
end
