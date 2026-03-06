# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::Polls do
  subject { Fabricate.build :status }

  describe 'Associations' do
    it { is_expected.to belong_to(:preloadable_poll).class_name(Poll).with_foreign_key(:poll_id).optional.inverse_of(false) }
    it { is_expected.to have_one(:poll).inverse_of(:status).dependent(:destroy) }
  end

  describe 'Nesting' do
    it { is_expected.to accept_nested_attributes_for(:poll) }
  end

  describe 'Scopes' do
    describe '.only_polls' do
      let!(:poll_status) { Fabricate :status, poll: Fabricate(:poll) }
      let!(:no_poll_status) { Fabricate :status }

      it 'returns the expected statuses' do
        expect(Status.only_polls)
          .to include(poll_status)
          .and not_include(no_poll_status)
      end
    end

    describe '.without_polls' do
      let!(:poll_status) { Fabricate :status, poll: Fabricate(:poll) }
      let!(:no_poll_status) { Fabricate :status }

      it 'returns the expected statuses' do
        expect(Status.without_polls)
          .to not_include(poll_status)
          .and include(no_poll_status)
      end
    end
  end

  describe 'Callbacks' do
    describe 'Setting poll id' do
      context 'with an unpersisted but assigned poll' do
        let!(:poll) { Fabricate :poll }
        let(:status) { Fabricate.build :status }

        before { status.poll = poll }

        it 'updates poll id on save' do
          expect { status.save }
            .to change(status, :poll_id).to(poll.id)
        end
      end
    end
  end

  describe '#with_poll?' do
    subject { Fabricate.build(:status) }

    context 'when a preloadable poll is present' do
      before { subject.preloadable_poll = Fabricate.build(:poll) }

      it { is_expected.to be_with_poll }
    end

    context 'when a preloadable poll is not present' do
      before { subject.preloadable_poll = nil }

      it { is_expected.to_not be_with_poll }
    end
  end
end
