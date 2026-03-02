# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::StatusesSearch, :inline_jobs do
  before do
    Fabricate :status, account:, visibility: :public
    Fabricate :status, account:, visibility: :private
    reset_indices
  end

  describe 'a non-indexable account becoming indexable' do
    let!(:account) { Fabricate :account, indexable: false }

    context 'when picking a non-indexable account' do
      it 'does not have statuses in the PublicStatusesIndex but has statuses in the StatusesIndex' do
        expect(public_statuses_results.count)
          .to eq(0)

        expect(statuses_results.count)
          .to eq(2)
      end
    end

    context 'when the non-indexable account becomes indexable' do
      before { account.update!(indexable: true) }

      it 'adds the public statuses to the PublicStatusesIndex' do
        reset_indices

        expect(public_statuses_results.count)
          .to eq(1)
        expect(statuses_results.count)
          .to eq(2)
      end
    end
  end

  describe 'an indexable account becoming non-indexable' do
    let!(:account) { Fabricate :account, indexable: true }

    context 'when picking an indexable account' do
      it 'has statuses in the PublicStatusesIndex' do
        expect(public_statuses_results.count)
          .to eq(1)

        expect(statuses_results.count)
          .to eq(2)
      end
    end

    context 'when the indexable account becomes non-indexable' do
      before { account.update!(indexable: false) }

      it 'removes the statuses from the PublicStatusesIndex' do
        reset_indices

        expect(public_statuses_results.count)
          .to eq(0)
        expect(statuses_results.count)
          .to eq(2)
      end
    end
  end

  def public_statuses_results
    @public_statuses_results ||= PublicStatusesIndex.filter(term: { account_id: account.id })
  end

  def statuses_results
    @statuses_results ||= StatusesIndex.filter(term: { account_id: account.id })
  end

  def reset_indices
    PublicStatusesIndex.reset!
    StatusesIndex.reset!
  end
end
