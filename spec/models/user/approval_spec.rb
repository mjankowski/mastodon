# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Approval do
  subject { User.new }

  describe 'Scopes' do
    let!(:approved_user) { Fabricate :user }
    let!(:unapproved_user) { Fabricate :user }

    before { unapproved_user.update! approved: false }

    describe '.approved' do
      it 'returns approved records' do
        expect(User.approved)
          .to include(approved_user)
          .and not_include(unapproved_user)
      end
    end

    describe '.pending' do
      it 'returns non approved records' do
        expect(User.pending)
          .to include(unapproved_user)
          .and not_include(approved_user)
      end
    end
  end

  describe 'Callbacks' do
    describe 'Setting approved' do
      let(:user) { Fabricate.build :user, account: Fabricate(:account) }

      before { user.approved = nil }

      context 'when a username block exists' do
        before { Fabricate :username_block, username: user.account.username, allow_with_approval: true }

        it 'changes approved to false' do
          expect { user.save }
            .to change(user, :approved).to(false)
        end
      end

      context 'when an IP block exists' do
        before do
          Fabricate :ip_block, ip: sign_up_ip, severity: :sign_up_requires_approval
          user.sign_up_ip = sign_up_ip
        end

        let(:sign_up_ip) { '100.100.100.100' }

        it 'changes approved to false' do
          expect { user.save }
            .to change(user, :approved).to(false)
        end
      end

      context 'when an email domain block exists' do
        before { Fabricate :email_domain_block, domain: user.email_domain, allow_with_approval: true }

        it 'changes approved to false' do
          expect { user.save }
            .to change(user, :approved).to(false)
        end
      end

      context 'when registrations are open' do
        before { Setting.registrations_mode = 'open' }

        it 'changes approved to true' do
          expect { user.save }
            .to change(user, :approved).to(true)
        end
      end

      context 'when an invitation is present' do
        before { user.invite = Fabricate :invite }

        it 'changes approved to true' do
          expect { user.save }
            .to change(user, :approved).to(true)
        end
      end

      context 'when account is external' do
        before { user.external = true }

        it 'changes approved to true' do
          expect { user.save }
            .to change(user, :approved).to(true)
        end
      end
    end
  end

  describe '#approve!' do
    subject { user.approve! }

    before do
      Setting.registrations_mode = 'approved'
      allow(TriggerWebhookWorker).to receive(:perform_async)
    end

    context 'when the user is already approved' do
      let(:user) { Fabricate.build :user }

      before { user.approved = true }

      it { is_expected.to be_nil }
    end

    context 'when the user is already confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: false) }

      it 'sets the approved flag and triggers `account.approved` web hook' do
        expect { subject }.to change { user.reload.approved? }.to(true)

        expect(TriggerWebhookWorker).to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
      end
    end

    context 'when the user is not confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: nil, approved: false) }

      it 'sets the approved flag and does not trigger web hook' do
        expect { subject }.to change { user.reload.approved? }.to(true)

        expect(TriggerWebhookWorker).to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end
  end

  describe '#pending?' do
    subject { user.pending? }

    context 'when user is approved' do
      let(:user) { Fabricate.build :user, approved: true }

      it { is_expected.to be(false) }
    end

    context 'when user is not approved' do
      let(:user) { Fabricate.build :user, approved: false }

      it { is_expected.to be(true) }
    end
  end
end
