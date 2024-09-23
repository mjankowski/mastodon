# frozen_string_literal: true

require 'rails_helper'

module TestEndpoints
  # Endpoints that do not include authorization-dependent results
  # and should be cacheable no matter what.
  ALWAYS_CACHED = %w(
    /.well-known/host-meta
    /.well-known/nodeinfo
    /nodeinfo/2.0
    /manifest
    /custom.css
    /actor
    /api/v1/instance/extended_description
    /api/v1/instance/rules
    /api/v1/instance/peers
    /api/v1/instance
    /api/v2/instance
  ).freeze

  # Endpoints that should be cachable when accessed anonymously but have a Vary
  # on Cookie to prevent logged-in users from getting values from logged-out cache.
  COOKIE_DEPENDENT_CACHABLE = %w(
    /
    /explore
    /public
    /about
    /privacy-policy
    /directory
    /@alice
    /@alice/110224538612341312
    /deck/home
  ).freeze

  # Endpoints that should be cachable when accessed anonymously but have a Vary
  # on Authorization to prevent logged-in users from getting values from logged-out cache.
  AUTHORIZATION_DEPENDENT_CACHABLE = %w(
    /api/v1/accounts/lookup?acct=alice
    /api/v1/statuses/110224538612341312
    /api/v1/statuses/110224538612341312/context
    /api/v1/polls/123456789
    /api/v1/trends/statuses
    /api/v1/directory
  ).freeze

  # Private status that should only be returned with to a valid signature from
  # a specific user.
  # Should never be cached.
  REQUIRE_SIGNATURE = %w(
    /users/alice/statuses/110224538643211312
  ).freeze

  # Pages only available to logged-in users.
  # Should never be cached.
  REQUIRE_LOGIN = %w(
    /settings/preferences/appearance
    /settings/profile
    /settings/featured_tags
    /settings/export
    /relationships
    /filters
    /statuses_cleanup
    /auth/edit
    /oauth/authorized_applications
    /admin/dashboard
  ).freeze

  # API endpoints only available to logged-in users.
  # Should never be cached.
  REQUIRE_TOKEN = %w(
    /api/v1/announcements
    /api/v1/timelines/home
    /api/v1/notifications
    /api/v1/bookmarks
    /api/v1/favourites
    /api/v1/follow_requests
    /api/v1/conversations
    /api/v1/statuses/110224538643211312
    /api/v1/statuses/110224538643211312/context
    /api/v1/lists
    /api/v2/filters
  ).freeze

  # Pages that are only shown to logged-out users, and should never get cached
  # because of CSRF protection.
  REQUIRE_LOGGED_OUT = %w(
    /invite/abcdef
    /auth/sign_in
    /auth/sign_up
    /auth/password/new
    /auth/confirmation/new
  ).freeze

  # Non-exhaustive list of endpoints that feature language-dependent results
  # and thus need to have a Vary on Accept-Language
  LANGUAGE_DEPENDENT = %w(
    /
    /explore
    /about
    /api/v1/trends/statuses
  ).freeze

  module AuthorizedFetch
    # Endpoints that require a signature with AUTHORIZED_FETCH and LIMITED_FEDERATION_MODE
    # and thus should not be cached in those modes.
    REQUIRE_SIGNATURE = %w(
      /users/alice
    ).freeze
  end

  module DisabledAnonymousAPI
    # Endpoints that require a signature with DISALLOW_UNAUTHENTICATED_API_ACCESS
    # and thus should not be cached in this mode.
    REQUIRE_TOKEN = %w(
      /api/v1/custom_emojis
    ).freeze
  end
end

RSpec::Matchers.define :have_non_cacheable_error do
  match(notify_expectation_failures: true) do |response|
    expect(response)
      .to_not have_http_status(200)
    expect(response.cache_control[:public])
      .to be_falsy
  end
end

RSpec::Matchers.define :have_non_cacheable_response do |http_success: false|
  match(notify_expectation_failures: true) do |response|
    expect(response.cache_control[:private])
      .to be_truthy
    expect(response.cache_control[:no_store])
      .to be_truthy

    if http_success
      expect(response).to have_http_status(200)
    else
      expect(response).to be_present
    end
  end
end
RSpec::Matchers.define :be_language_dependent do
  match(notify_expectation_failures: true) do |response|
    response_vary_headers = response.headers['Vary']&.split(',')&.map { |x| x.strip.downcase }

    expect(response_vary_headers)
      .to include('accept-language')
  end
end

RSpec::Matchers.define :have_cacheable_response do |http_success: false|
  match(notify_expectation_failures: true) do |response|
    expect(response.cookies)
      .to be_empty

    # expect(response.cache_control[:max_age]&.to_i).to be_positive
    expect(response.cache_control[:public])
      .to be_truthy
    expect(response.cache_control[:private])
      .to be_falsy
    expect(response.cache_control[:no_store])
      .to be_falsy
    expect(response.cache_control[:no_cache])
      .to be_falsy

    if http_success
      expect(response).to have_http_status(200)
    else
      expect(response).to be_present
    end
  end
end

RSpec.describe 'Caching behavior' do
  # Enable CSRF protection like it is in production, as it can cause cookies
  # to be set and thus mess with cache.
  around do |example|
    old = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true

    example.run

    ActionController::Base.allow_forgery_protection = old
  end

  let(:alice) { Account.find_by(username: 'alice') }
  let(:user) { User.find_by(email: 'user@host.example') }
  let(:token) { Doorkeeper::AccessToken.find_by(resource_owner_id: user.id) }

  before_all do
    alice = Fabricate(:account, username: 'alice')
    user = Fabricate(:user, email: 'user@host.example', role: UserRole.find_by(name: 'Moderator'))
    status = Fabricate(:status, account: alice, id: 110_224_538_612_341_312)
    Fabricate(:status, account: alice, id: 110_224_538_643_211_312, visibility: :private)
    Fabricate(:invite, code: 'abcdef')
    Fabricate(:poll, status: status, account: alice, id: 123_456_789)
    Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')

    user.account.follow!(alice)
  end

  context 'when anonymously accessed' do
    describe '/users/alice' do
      it 'redirects with proper cache header', :aggregate_failures do
        get '/users/alice'

        expect(response).to redirect_to('/@alice')
        expect(response_vary_headers).to include('accept')
      end
    end

    TestEndpoints::ALWAYS_CACHED.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response

          expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
        end
      end
    end

    TestEndpoints::COOKIE_DEPENDENT_CACHABLE.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
          expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
          expect(response_vary_headers).to include('cookie')
        end
      end
    end

    TestEndpoints::AUTHORIZATION_DEPENDENT_CACHABLE.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
          expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)

          expect(response_vary_headers).to include('authorization')
        end
      end
    end

    TestEndpoints::REQUIRE_LOGGED_OUT.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response
        end
      end
    end

    (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::REQUIRE_LOGIN + TestEndpoints::REQUIRE_TOKEN).each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'responds with non cacheable error' do
          expect(response).to have_non_cacheable_error
        end
      end
    end

    describe '/api/v1/instance/domain_blocks' do
      before do
        Setting.show_domain_blocks = show_domain_blocks
        get '/api/v1/instance/domain_blocks'
      end

      context 'when set to be publicly-available' do
        let(:show_domain_blocks) { 'all' }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
        end
      end

      context 'when allowed for local users only' do
        let(:show_domain_blocks) { 'users' }

        it 'responds with non cacheable error' do
          expect(response).to have_non_cacheable_error
        end
      end

      context 'when disabled' do
        let(:show_domain_blocks) { 'disabled' }

        it 'responds with non cacheable error' do
          expect(response).to have_non_cacheable_error
        end
      end
    end
  end

  context 'when logged in' do
    before do
      sign_in user, scope: :user

      # Unfortunately, devise's `sign_in` helper causes the `session` to be
      # loaded in the next request regardless of whether it's actually accessed
      # by the client code.
      #
      # So, we make an extra query to clear issue a session cookie instead.
      #
      # A less resource-intensive way to deal with that would be to generate the
      # session cookie manually, but this seems pretty involved.
      get '/'
    end

    TestEndpoints::ALWAYS_CACHED.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
          expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
        end
      end
    end

    TestEndpoints::COOKIE_DEPENDENT_CACHABLE.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response

          expect(response_vary_headers).to include('cookie')
        end
      end
    end

    TestEndpoints::REQUIRE_LOGIN.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response(http_success: true)
        end
      end
    end

    TestEndpoints::REQUIRE_LOGGED_OUT.each do |endpoint|
      describe endpoint do
        before { get endpoint }

        it 'responds with non cacheable error' do
          expect(response).to have_non_cacheable_error
        end
      end
    end
  end

  context 'with an auth token' do
    TestEndpoints::ALWAYS_CACHED.each do |endpoint|
      describe endpoint do
        before do
          get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
          expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
        end
      end
    end

    TestEndpoints::AUTHORIZATION_DEPENDENT_CACHABLE.each do |endpoint|
      describe endpoint do
        before do
          get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
        end

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response

          expect(response_vary_headers).to include('authorization')
        end
      end
    end

    (TestEndpoints::REQUIRE_LOGGED_OUT + TestEndpoints::REQUIRE_TOKEN).each do |endpoint|
      describe endpoint do
        before do
          get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
        end

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response(http_success: true)
        end
      end
    end

    describe '/api/v1/instance/domain_blocks' do
      before do
        Setting.show_domain_blocks = show_domain_blocks
        get '/api/v1/instance/domain_blocks', headers: { 'Authorization' => "Bearer #{token.token}" }
      end

      context 'when set to be publicly-available' do
        let(:show_domain_blocks) { 'all' }

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response
        end
      end

      context 'when allowed for local users only' do
        let(:show_domain_blocks) { 'users' }

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response(http_success: true)
        end
      end

      context 'when disabled' do
        let(:show_domain_blocks) { 'disabled' }

        it 'responds with non cacheable error' do
          expect(response).to have_non_cacheable_error
        end
      end
    end
  end

  context 'with a Signature header' do
    let(:remote_actor)    { Fabricate(:account, domain: 'example.org', uri: 'https://example.org/remote', protocol: :activitypub) }
    let(:dummy_signature) { 'dummy-signature' }

    before do
      remote_actor.follow!(alice)
    end

    describe '/actor' do
      before do
        get '/actor', sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
      end

      it 'has a cacheable response' do
        expect(response).to have_cacheable_response(http_success: true)
      end
    end

    TestEndpoints::REQUIRE_SIGNATURE.each do |endpoint|
      describe endpoint do
        before do
          get endpoint, sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a non cacheable response' do
          expect(response).to have_non_cacheable_response(http_success: true)
        end
      end
    end
  end

  context 'when enabling AUTHORIZED_FETCH mode' do
    around do |example|
      ClimateControl.modify AUTHORIZED_FETCH: 'true' do
        example.run
      end
    end

    context 'when not providing a Signature' do
      describe '/actor' do
        before do
          get '/actor', headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response(http_success: true)
        end
      end

      (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::AuthorizedFetch::REQUIRE_SIGNATURE).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, headers: { 'Accept' => 'application/activity+json' }
          end

          it 'responds with non cacheable error' do
            expect(response).to have_non_cacheable_error
          end
        end
      end
    end

    context 'when providing a Signature' do
      let(:remote_actor)    { Fabricate(:account, domain: 'example.org', uri: 'https://example.org/remote', protocol: :activitypub) }
      let(:dummy_signature) { 'dummy-signature' }

      before do
        remote_actor.follow!(alice)
      end

      describe '/actor' do
        before do
          get '/actor', sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response(http_success: true)
        end
      end

      (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::AuthorizedFetch::REQUIRE_SIGNATURE).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
          end

          it 'has a non cacheable response' do
            expect(response).to have_non_cacheable_response(http_success: true)
          end
        end
      end
    end
  end

  context 'when enabling LIMITED_FEDERATION_MODE mode' do
    around do |example|
      ClimateControl.modify LIMITED_FEDERATION_MODE: 'true' do
        old_limited_federation_mode = Rails.configuration.x.limited_federation_mode
        Rails.configuration.x.limited_federation_mode = true

        example.run

        Rails.configuration.x.limited_federation_mode = old_limited_federation_mode
      end
    end

    context 'when not providing a Signature' do
      describe '/actor' do
        before do
          get '/actor', headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response(http_success: true)
        end
      end

      (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::AuthorizedFetch::REQUIRE_SIGNATURE).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, headers: { 'Accept' => 'application/activity+json' }
          end

          it 'responds with non cacheable error' do
            expect(response).to have_non_cacheable_error
          end
        end
      end
    end

    context 'when providing a Signature from an allowed domain' do
      let(:remote_actor)    { Fabricate(:account, domain: 'example.org', uri: 'https://example.org/remote', protocol: :activitypub) }
      let(:dummy_signature) { 'dummy-signature' }

      before do
        DomainAllow.create!(domain: remote_actor.domain)
        remote_actor.follow!(alice)
      end

      describe '/actor' do
        before do
          get '/actor', sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response(http_success: true)
        end
      end

      (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::AuthorizedFetch::REQUIRE_SIGNATURE).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
          end

          it 'has a non cacheable response' do
            expect(response).to have_non_cacheable_response(http_success: true)
          end
        end
      end
    end

    context 'when providing a Signature from a non-allowed domain' do
      let(:remote_actor)    { Fabricate(:account, domain: 'example.org', uri: 'https://example.org/remote', protocol: :activitypub) }
      let(:dummy_signature) { 'dummy-signature' }

      describe '/actor' do
        before do
          get '/actor', sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
        end

        it 'has a cacheable response' do
          expect(response).to have_cacheable_response(http_success: true)
        end
      end

      (TestEndpoints::REQUIRE_SIGNATURE + TestEndpoints::AuthorizedFetch::REQUIRE_SIGNATURE).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, sign_with: remote_actor, headers: { 'Accept' => 'application/activity+json' }
          end

          it 'responds with non cacheable error' do
            expect(response).to have_non_cacheable_error
          end
        end
      end
    end
  end

  context 'when enabling DISALLOW_UNAUTHENTICATED_API_ACCESS' do
    around do |example|
      ClimateControl.modify DISALLOW_UNAUTHENTICATED_API_ACCESS: 'true' do
        example.run
      end
    end

    context 'when anonymously accessed' do
      TestEndpoints::ALWAYS_CACHED.each do |endpoint|
        describe endpoint do
          before { get endpoint }

          it 'has a cacheable response' do
            expect(response).to have_cacheable_response
            expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
          end
        end
      end

      TestEndpoints::REQUIRE_LOGGED_OUT.each do |endpoint|
        describe endpoint do
          before { get endpoint }

          it 'has a non cacheable response' do
            expect(response).to have_non_cacheable_response
          end
        end
      end

      (TestEndpoints::REQUIRE_TOKEN + TestEndpoints::AUTHORIZATION_DEPENDENT_CACHABLE + TestEndpoints::DisabledAnonymousAPI::REQUIRE_TOKEN).each do |endpoint|
        describe endpoint do
          before { get endpoint }

          it 'responds with non cacheable error' do
            expect(response).to have_non_cacheable_error
          end
        end
      end
    end

    context 'with an auth token' do
      TestEndpoints::ALWAYS_CACHED.each do |endpoint|
        describe endpoint do
          before do
            get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
          end

          it 'has a cacheable response' do
            expect(response).to have_cacheable_response
            expect(response).to be_language_dependent if TestEndpoints::LANGUAGE_DEPENDENT.include?(endpoint)
          end
        end
      end

      TestEndpoints::AUTHORIZATION_DEPENDENT_CACHABLE.each do |endpoint|
        describe endpoint do
          before do
            get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
          end

          it 'has a non cacheable response' do
            expect(response).to have_non_cacheable_response

            expect(response_vary_headers).to include('authorization')
          end
        end
      end

      (TestEndpoints::REQUIRE_LOGGED_OUT + TestEndpoints::REQUIRE_TOKEN + TestEndpoints::DisabledAnonymousAPI::REQUIRE_TOKEN).each do |endpoint|
        describe endpoint do
          before do
            get endpoint, headers: { 'Authorization' => "Bearer #{token.token}" }
          end

          it 'has a non cacheable response' do
            expect(response).to have_non_cacheable_response(http_success: true)
          end
        end
      end
    end
  end

  private

  def response_vary_headers
    response.headers['Vary']&.split(',')&.map { |x| x.strip.downcase }
  end
end
