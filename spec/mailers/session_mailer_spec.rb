# frozen_string_literal: true

require 'rails_helper'

describe SessionMailer do
  let(:receiver) { Fabricate(:user) }

  describe '#suspicious_sign_in' do
    let(:remote_ip) { '192.168.0.1' }
    let(:agent) { 'NCSA_Mosaic/2.0 (Windows 3.1)' }
    let(:timestamp) { Time.now.utc }
    let(:mail) { described_class.with(user: receiver).suspicious_sign_in(remote_ip, agent, timestamp) }

    it 'renders suspicious sign in notification' do
      receiver.update!(locale: nil)

      expect(mail)
        .to be_present
        .and(have_body_text(I18n.t('user_mailer.suspicious_sign_in.explanation')))
    end

    include_examples 'localized subject',
                     'user_mailer.suspicious_sign_in.subject'
  end

  describe '#welcome' do
    let(:mail) { described_class.with(user: receiver).welcome }

    it 'renders welcome mail' do
      expect(mail)
        .to be_present
        .and(have_subject(I18n.t('user_mailer.welcome.subject')))
        .and(have_body_text(I18n.t('user_mailer.welcome.explanation')))
    end
  end
end
