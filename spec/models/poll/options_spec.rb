# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Poll::Options do
  describe 'Validations' do
    context 'when account is local' do
      subject { Fabricate.build :poll }

      it { is_expected.to_not allow_value([]).for(:options) }
    end
  end

  describe 'Callbacks' do
    describe 'Normalizing options' do
      context 'when values are missing and padded' do
        let(:poll) { Fabricate.build :poll }

        before { poll.options = ['One', '', '  Three  '] }

        it 'strips and compacts the array' do
          expect { poll.valid? }
            .to change(poll, :options).to(%w(One Three))
        end
      end
    end
  end

  describe '#loaded_options' do
    before { poll.options = %w(One Two) }

    context 'with a poll hiding totals' do
      let(:poll) { Fabricate.build :poll, hide_totals: true }

      it 'returns serialized option values' do
        expect(poll.loaded_options)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Poll::Option).and(have_attributes(poll:, id: '0', votes_count: nil, title: /One/)),
            be_a(Poll::Option).and(have_attributes(poll:, id: '1', votes_count: nil, title: /Two/))
          )
      end
    end

    context 'with an expired poll' do
      let(:poll) { Fabricate.build :poll, expires_at: 5.days.ago }

      it 'returns serialized option values' do
        expect(poll.loaded_options)
          .to be_an(Array)
          .and contain_exactly(
            be_a(Poll::Option).and(have_attributes(poll:, id: '0', votes_count: 0, title: /One/)),
            be_a(Poll::Option).and(have_attributes(poll:, id: '1', votes_count: 0, title: /Two/))
          )
      end
    end
  end
end
