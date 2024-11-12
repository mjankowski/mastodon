# frozen_string_literal: true

RSpec.shared_examples 'User::Approval' do
  describe 'Scopes' do
    let(:approved_user) { Fabricate :user }
    let(:pending_user) { Fabricate :user }

    before do
      approved_user.update(approved: true)
      pending_user.update(approved: false)
    end

    describe '.approved' do
      it 'returns records that are approved' do
        expect(described_class.approved)
          .to include(approved_user)
          .and not_include(pending_user)
      end
    end

    describe '.pending' do
      it 'returns records that are not approved' do
        expect(described_class.pending)
          .to include(pending_user)
          .and not_include(approved_user)
      end
    end
  end

  describe '#approve!' do
    before { Setting.registrations_mode = 'approved' }

    context 'when the user is already confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: Time.now.utc, approved: false) }

      before { allow(TriggerWebhookWorker).to receive(:perform_async) }

      it 'sets the approved flag and triggers `account.approved` web hook' do
        expect { user.approve! }
          .to change { user.reload.approved? }.to(true)

        expect(TriggerWebhookWorker)
          .to have_received(:perform_async).with('account.approved', 'Account', user.account_id).once
      end
    end

    context 'when the user is not confirmed' do
      let(:user) { Fabricate(:user, confirmed_at: nil, approved: false) }

      before { allow(TriggerWebhookWorker).to receive(:perform_async) }

      it 'sets the approved flag and does not trigger web hook' do
        expect { user.approve! }
          .to change { user.reload.approved? }.to(true)

        expect(TriggerWebhookWorker)
          .to_not have_received(:perform_async).with('account.approved', 'Account', user.account_id)
      end
    end
  end

  describe '#pending?' do
    context 'with an approved user' do
      subject { Fabricate.build :user, approved: true }

      it { is_expected.to_not be_pending }
    end

    context 'with a not approved user' do
      subject { Fabricate.build :user, approved: false }

      it { is_expected.to be_pending }
    end
  end
end
