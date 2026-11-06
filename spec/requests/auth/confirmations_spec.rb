# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Confirmation' do
  describe 'GET /auth/confirmation' do
    context 'when user is already confirmed' do
      let!(:user) { Fabricate(:user) }

      before { sign_in(user) }

      it 'redirects to root path' do
        get user_confirmation_path(confirmation_token: 'foobar')

        expect(response)
          .to redirect_to(root_path)
      end
    end

    context 'when user is already confirmed but unapproved' do
      let!(:user) { Fabricate(:user, approved: false) }

      before do
        user.approved = false
        user.save!
        sign_in(user, scope: :user)
      end

      it 'redirects to settings' do
        get user_confirmation_path(confirmation_token: 'foobar')

        expect(response)
          .to redirect_to(edit_user_registration_path)
      end
    end
  end
end
