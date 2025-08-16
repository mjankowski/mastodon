# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::Confirmations::ResendsController do
  render_views

  before { sign_in Fabricate(:admin_user) }

  describe 'POST #create' do
    subject { post :create, params: { account_id: user.account.id } }

    let!(:user) { Fabricate(:user, confirmed_at: confirmed_at) }

    before do
      allow(UserMailer).to receive(:confirmation_instructions) { instance_double(ActionMailer::MessageDelivery, deliver_later: nil) }
    end

    context 'when email is not confirmed' do
      let(:confirmed_at) { nil }

      it 'resends confirmation mail' do
        subject

        expect(response)
          .to redirect_to admin_accounts_path
        expect(flash[:notice])
          .to eq I18n.t('admin.accounts.resend_confirmation.success')
        expect(UserMailer)
          .to have_received(:confirmation_instructions).once
      end
    end

    context 'when email is confirmed' do
      let(:confirmed_at) { Time.zone.now }

      it 'does not resend confirmation mail' do
        subject

        expect(response)
          .to redirect_to admin_accounts_path
        expect(flash[:error])
          .to eq I18n.t('admin.accounts.resend_confirmation.already_confirmed')
        expect(UserMailer)
          .to_not have_received(:confirmation_instructions)
      end
    end
  end
end
