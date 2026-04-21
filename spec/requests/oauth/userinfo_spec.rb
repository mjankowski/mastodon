# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'OAuth Userinfo Endpoint' do
  include RoutingHelper

  let(:user)     { Fabricate(:user) }
  let(:account)  { user.account }
  let(:token)    { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: scopes) }
  let(:scopes)   { 'profile' }
  let(:headers)  { { 'Authorization' => "Bearer #{token.token}" } }

  shared_examples 'oauth userinfo response' do
    it 'returns http success and expected endpoint values' do
      subject

      expect(response)
        .to have_http_status(:success)
      expect(response.media_type)
        .to eq('application/json')
      expect(response.parsed_body)
        .to include(
          iss: root_url,
          sub: ActivityPub::TagManager.instance.uri_for(account),
          name: account.display_name,
          preferred_username: account.username,
          profile: short_account_url(account),
          picture: full_asset_url(account.avatar_original_url)
        )
    end
  end

  # The spec requires both GET and POST for the userinfo endpoint:
  # https://openid.net/specs/openid-connect-core-1_0.html#UserInfo

  describe 'GET /oauth/userinfo' do
    subject { get '/oauth/userinfo', headers: headers }

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
    it_behaves_like 'oauth userinfo response'
  end

  describe 'POST /oauth/userinfo' do
    subject { post '/oauth/userinfo', headers: headers }

    it_behaves_like 'forbidden for wrong scope', 'read:accounts'
    it_behaves_like 'oauth userinfo response'
  end
end
