# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Web::PushSubscription do
  subject { described_class.new(data: data) }

  let(:account) { Fabricate(:account) }

  let(:policy) { 'all' }

  let(:data) do
    {
      policy: policy,

      alerts: {
        mention: true,
        reblog: false,
        follow: true,
        follow_request: false,
        favourite: true,
      },
    }
  end

  describe '#policy' do
    context 'with no data' do
      let(:data) { nil }

      it 'defaults to nil' do
        expect(subject.policy).to be_nil
      end
    end

    context 'with populated data' do
      let(:data) { { policy: 'all' } }

      it 'pulls from data json' do
        expect(subject.policy).to eq('all')
      end
    end
  end

  describe '#alerts' do
    context 'with no data' do
      let(:data) { nil }

      it 'provides defaults' do
        expect(subject.alerts).to eq({})
      end
    end

    context 'with populated data' do
      let(:data) { { alerts: { mention: true, follow: false } } }

      it 'pulls from data json' do
        expect(subject.alerts.symbolize_keys)
          .to include(mention: true)
          .and include(follow: false)
      end
    end
  end

  describe '#pushable?' do
    let(:notification_type) { :mention }
    let(:notification) { Fabricate(:notification, account: account, type: notification_type) }

    %i(mention reblog follow follow_request favourite).each do |type|
      context "when notification is a #{type}" do
        let(:notification_type) { type }

        it 'returns boolean corresponding to alert setting' do
          expect(subject.pushable?(notification)).to eq data[:alerts][type]
        end
      end
    end

    context 'when policy is all' do
      let(:policy) { 'all' }

      it 'returns true' do
        expect(subject.pushable?(notification)).to be true
      end
    end

    context 'when policy is none' do
      let(:policy) { 'none' }

      it 'returns false' do
        expect(subject.pushable?(notification)).to be false
      end
    end

    context 'when policy is followed' do
      let(:policy) { 'followed' }

      context 'when notification is from someone you follow' do
        before do
          account.follow!(notification.from_account)
        end

        it 'returns true' do
          expect(subject.pushable?(notification)).to be true
        end
      end

      context 'when notification is not from someone you follow' do
        it 'returns false' do
          expect(subject.pushable?(notification)).to be false
        end
      end
    end

    context 'when policy is follower' do
      let(:policy) { 'follower' }

      context 'when notification is from someone who follows you' do
        before do
          notification.from_account.follow!(account)
        end

        it 'returns true' do
          expect(subject.pushable?(notification)).to be true
        end
      end

      context 'when notification is not from someone who follows you' do
        it 'returns false' do
          expect(subject.pushable?(notification)).to be false
        end
      end
    end
  end
end
