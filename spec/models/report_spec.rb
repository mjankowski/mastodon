# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report do
  describe 'statuses' do
    it 'returns the statuses for the report' do
      status = Fabricate(:status)
      _other = Fabricate(:status)
      report = Fabricate(:report, status_ids: [status.id])

      expect(report.statuses).to eq [status]
    end
  end

  describe 'media_attachments_count' do
    it 'returns count of media attachments in statuses' do
      status1 = Fabricate(:status, ordered_media_attachment_ids: [1, 2])
      status2 = Fabricate(:status, ordered_media_attachment_ids: [5])
      report  = Fabricate(:report, status_ids: [status1.id, status2.id])

      expect(report.media_attachments_count).to eq 3
    end
  end

  describe 'assign_to_self!' do
    subject { report.assigned_account_id }

    let(:report) { Fabricate(:report, assigned_account_id: original_account) }
    let(:original_account) { Fabricate(:account) }
    let(:current_account) { Fabricate(:account) }

    before do
      report.assign_to_self!(current_account)
    end

    it 'assigns to a given account' do
      expect(subject).to eq current_account.id
    end
  end

  describe 'unassign!' do
    subject { report.assigned_account_id }

    let(:report) { Fabricate(:report, assigned_account_id: account.id) }
    let(:account) { Fabricate(:account) }

    before do
      report.unassign!
    end

    it 'unassigns' do
      expect(subject).to be_nil
    end
  end

  describe 'resolve!' do
    subject(:report) { Fabricate(:report, action_taken_at: nil, action_taken_by_account_id: nil) }

    let(:acting_account) { Fabricate(:account) }

    before do
      report.resolve!(acting_account)
    end

    it 'records action taken' do
      expect(report.action_taken?).to be true
      expect(report.action_taken_by_account_id).to eq acting_account.id
    end
  end

  describe 'unresolve!' do
    subject(:report) { Fabricate(:report, action_taken_at: Time.now.utc, action_taken_by_account_id: acting_account.id) }

    let(:acting_account) { Fabricate(:account) }

    before do
      report.unresolve!
    end

    it 'unresolves' do
      expect(report.action_taken?).to be false
      expect(report.action_taken_by_account_id).to be_nil
    end
  end

  describe 'unresolved?' do
    subject { report.unresolved? }

    let(:report) { Fabricate(:report, action_taken_at: action_taken) }

    context 'when action is taken' do
      let(:action_taken) { Time.now.utc }

      it { is_expected.to be false }
    end

    context 'when action not is taken' do
      let(:action_taken) { nil }

      it { is_expected.to be true }
    end
  end

  describe 'history' do
    subject(:action_logs) { report.history }

    let(:report) { Fabricate(:report, target_account_id: target_account.id, status_ids: [status.id]) }
    let(:target_account) { Fabricate(:account) }
    let(:status) { Fabricate(:status) }
    let(:account_warning) { Fabricate(:account_warning, report_id: report.id) }

    let!(:matched_type_account_warning) { Fabricate(:action_log, target_type: 'AccountWarning', target_id: account_warning.id) }
    let!(:matched_type_account) { Fabricate(:action_log, target_type: 'Account', target_id: report.target_account_id) }
    let!(:matched_type_report) { Fabricate(:action_log, target_type: 'Report', target_id: report.id) }
    let!(:matched_type_status) { Fabricate(:action_log, target_type: 'Status', target_id: status.id) }

    let!(:unmatched_type_account_warning) { Fabricate(:action_log, target_type: 'AccountWarning') }
    let!(:unmatched_type_account) { Fabricate(:action_log, target_type: 'Account') }
    let!(:unmatched_type_report) { Fabricate(:action_log, target_type: 'Report') }
    let!(:unmatched_type_status) { Fabricate(:action_log, target_type: 'Status') }

    it 'returns expected logs' do
      expect(action_logs)
        .to have_attributes(count: 4)
        .and include(matched_type_account_warning)
        .and include(matched_type_account)
        .and include(matched_type_report)
        .and include(matched_type_status)
        .and not_include(unmatched_type_account_warning)
        .and not_include(unmatched_type_account)
        .and not_include(unmatched_type_report)
        .and not_include(unmatched_type_status)
    end
  end

  describe '#unresolved_siblings?' do
    subject { Fabricate :report }

    context 'when the target account has other unresolved reports' do
      before { Fabricate :report, action_taken_at: nil, target_account: subject.target_account }

      it { is_expected.to be_unresolved_siblings }
    end

    context 'when the target account has a resolved report' do
      before { Fabricate :report, action_taken_at: 3.days.ago, target_account: subject.target_account }

      it { is_expected.to_not be_unresolved_siblings }
    end

    context 'when the target account has no other reports' do
      before { described_class.where(target_account: subject.target_account).destroy_all }

      it { is_expected.to_not be_unresolved_siblings }
    end
  end

  describe 'Validations' do
    subject { Fabricate.build :report }

    it { is_expected.to_not allow_value([-1]).for(:rule_ids) }

    describe 'Comment size limits' do
      subject { Fabricate.build :report, account: account }

      context 'with a local reporter' do
        let(:account) { Fabricate(:account, domain: nil) }

        it { is_expected.to_not allow_value(comment_over_limit).for(:comment) }
      end

      context 'with a remote reporter' do
        let(:account) { Fabricate(:account, domain: 'example.com', protocol: :activitypub, inbox_url: 'http://example.com/inbox') }

        it { is_expected.to allow_value(comment_over_limit).for(:comment) }
      end

      def comment_over_limit
        'a' * described_class::COMMENT_SIZE_LIMIT * 2
      end
    end

    describe 'Rule requirements dependent on category' do
      subject { Fabricate.build :report, category: category }

      context 'with a category that is not "violation"' do
        let(:category) { :spam }
        let(:rule) { Fabricate :rule }

        it { is_expected.to_not allow_value(rule.id).for(:rule_ids) }
      end

      context 'with extra rule ids on a violation category report' do
        let(:category) { :violation }

        it { is_expected.to_not allow_value([nil, Fabricate(:rule).id]).for(:rule_ids) }
      end
    end
  end
end
