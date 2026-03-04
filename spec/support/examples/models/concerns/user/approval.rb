# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Approval' do
  describe 'Scopes' do
    let!(:approved_user) { Fabricate :user }
    let!(:unapproved_user) { Fabricate :user }

    before { unapproved_user.update! approved: false }

    describe '.approved' do
      it 'returns approved records' do
        expect(described_class.approved)
          .to include(approved_user)
          .and not_include(unapproved_user)
      end
    end

    describe '.pending' do
      it 'returns non approved records' do
        expect(described_class.pending)
          .to include(unapproved_user)
          .and not_include(approved_user)
      end
    end
  end

  describe '#approve!' do
    subject { user.approve! }

    before do
      Setting.registrations_mode = 'approved'
      allow(TriggerWebhookWorker).to receive(:perform_async)
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
