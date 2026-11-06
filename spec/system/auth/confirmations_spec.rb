# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Auth Confirmation' do
  describe 'Confirming a new account' do
    let(:user) { Fabricate(:user, confirmed_at: nil) }

    it 'confirms the user and queues timeline setup' do
      confirmation_link = resend_confirmation_instructions

      expect { visit confirmation_link }
        .to change { user.reload.confirmed_at }.from(nil).to(be_present)
      expect(page)
        .to have_title(I18n.t('auth.login'))
      expect(BootstrapTimelineWorker)
        .to have_enqueued_sidekiq_job(user.account_id)
    end

    context 'when approval is required' do
      let(:user) { Fabricate(:user, confirmed_at: nil, bypass_registration_checks: true) }

      before { Setting.registrations_mode = 'approved' }

      it 'confirms the email without approving the user' do
        confirmation_link = resend_confirmation_instructions

        expect { visit confirmation_link }
          .to change { user.reload.confirmed_at }.from(nil).to(be_present)
        expect(user.reload)
          .to_not be_approved
        expect(page)
          .to have_title(I18n.t('auth.login'))
        expect(BootstrapTimelineWorker)
          .to_not have_enqueued_sidekiq_job
      end
    end
  end

  describe 'Confirming a changed email address' do
    let(:user) { Fabricate(:user, unconfirmed_email: 'new-email@example.com') }

    it 'updates the email without queuing timeline setup' do
      confirmation_link = resend_confirmation_instructions

      expect { visit confirmation_link }
        .to change { user.reload.email }.from(user.email).to('new-email@example.com')
        .and(change { user.reload.unconfirmed_email }.from('new-email@example.com').to(nil))
      expect(page)
        .to have_title(I18n.t('auth.login'))
      expect(BootstrapTimelineWorker)
        .to_not have_enqueued_sidekiq_job
    end
  end

  def resend_confirmation_instructions
    visit new_user_session_path
    click_on I18n.t('auth.didnt_get_confirmation')
    expect(page)
      .to have_title(I18n.t('auth.resend_confirmation'))

    fill_in 'user_email', with: user.email
    emails = capture_emails do
      Sidekiq.testing!(:inline) { click_on I18n.t('auth.resend_confirmation') }
    end
    expect(emails.size)
      .to eq(1)
    expect(emails.first.to)
      .to contain_exactly(user.unconfirmed_email.presence || user.email)

    email_links(emails.first).first
  end
end
