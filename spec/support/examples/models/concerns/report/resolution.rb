# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'Report::Resolution' do
  describe 'Scopes' do
    let!(:resolved) { Fabricate :report, action_taken_at: 5.days.ago }
    let!(:unresolved) { Fabricate :report, action_taken_at: nil }

    describe '.resolved' do
      it 'returns reports which have had action taken' do
        expect(described_class.resolved)
          .to contain_exactly(resolved)
      end
    end

    describe '.unresolved' do
      it 'returns reports which have not had action taken' do
        expect(described_class.unresolved)
          .to contain_exactly(unresolved)
      end
    end
  end

  describe '#resolve!' do
    let(:acting_account) { Fabricate(:account) }
    let(:report) { Fabricate(:report, action_taken_at: nil, action_taken_by_account_id: nil) }

    it 'resolves report and records action taken' do
      expect { report.resolve!(acting_account) }
        .to change(report, :action_taken?).to(true)
        .and change(report, :action_taken_by_account).to(acting_account)
    end
  end

  describe '#unresolve!' do
    let(:acting_account) { Fabricate(:account) }
    let(:report) { Fabricate(:report, action_taken_at: Time.now.utc, action_taken_by_account_id: acting_account.id) }

    it 'unresolves report and removed action taken account' do
      expect { report.unresolve! }
        .to change(report, :action_taken?).to(false)
        .and change(report, :action_taken_by_account).to(be_nil)
    end
  end

  describe '#unresolved?' do
    subject { Fabricate(:report, action_taken_at: action_taken) }

    context 'when action has been taken' do
      let(:action_taken) { Time.now.utc }

      it { is_expected.to_not be_unresolved }
    end

    context 'when action has not been taken' do
      let(:action_taken) { nil }

      it { is_expected.to be_unresolved }
    end
  end

  describe '#action_taken?' do
    subject { Fabricate(:report, action_taken_at: action_taken) }

    context 'when action has been taken' do
      let(:action_taken) { Time.now.utc }

      it { is_expected.to be_action_taken }
    end

    context 'when action has not been taken' do
      let(:action_taken) { nil }

      it { is_expected.to_not be_action_taken }
    end
  end
end
