# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StatusStat do
  describe 'Associations' do
    it { is_expected.to belong_to(:status).inverse_of(:status_stat) }
  end

  describe 'Count column wrappers' do
    let(:status_stat) { Fabricate.build :status_stat, replies_count: value, reblogs_count: value, quotes_count: value, favourites_count: value }

    context 'when value is negative' do
      let(:value) { -123 }

      it 'adjusts values up to zero' do
        expect(status_stat.favourites_count).to be_zero
        expect(status_stat.quotes_count).to be_zero
        expect(status_stat.reblogs_count).to be_zero
        expect(status_stat.replies_count).to be_zero
      end
    end

    context 'when values are positive' do
      let(:value) { 123 }

      it 'preserves values' do
        expect(status_stat.favourites_count).to eq(123)
        expect(status_stat.quotes_count).to eq(123)
        expect(status_stat.reblogs_count).to eq(123)
        expect(status_stat.replies_count).to eq(123)
      end
    end
  end

  describe 'Callbacks' do
    describe 'Clamping untrusted counts on save' do
      subject { status_stat.save }

      let(:status_stat) { Fabricate.build :status_stat, untrusted_favourites_count: count, untrusted_reblogs_count: count }

      before { stub_const 'StatusStat::MAX_UNTRUSTED_COUNT', 10 }

      context 'when counts are too high' do
        let(:count) { 100 }

        it 'changes value to limit' do
          expect { subject }
            .to change(status_stat, :untrusted_favourites_count).to(10)
            .and change(status_stat, :untrusted_reblogs_count).to(10)
        end
      end

      context 'when counts are too low' do
        let(:count) { -100 }

        it 'changes value to zero' do
          expect { subject }
            .to change(status_stat, :untrusted_favourites_count).to(0)
            .and change(status_stat, :untrusted_reblogs_count).to(0)
        end
      end

      context 'when counts are acceptable' do
        let(:count) { 5 }

        it 'preserves count' do
          expect { subject }
            .to not_change(status_stat, :untrusted_favourites_count).from(count)
            .and not_change(status_stat, :untrusted_reblogs_count).from(count)
        end
      end
    end
  end
end
