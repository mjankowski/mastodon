# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::Search do
  let!(:account) { Fabricate :account, discoverable:, note: 'Account note text' }

  before { reset_indices }

  describe 'a non-discoverable account becoming discoverable' do
    let(:discoverable) { false }

    context 'when picking a non-discoverable account' do
      it 'its bio is not in the AccountsIndex' do
        expect(results.count)
          .to eq(1)
        expect(results.first.text)
          .to be_nil
      end
    end

    context 'when the non-discoverable account becomes discoverable' do
      before { account.update!(discoverable: true) }

      it 'its bio is added to the AccountsIndex' do
        reset_indices

        expect(results.count)
          .to eq(1)
        expect(results.first.text)
          .to eq(account.note)
      end
    end
  end

  describe 'a discoverable account becoming non-discoverable' do
    let(:discoverable) { true }

    context 'when picking an discoverable account' do
      it 'has its bio in the AccountsIndex' do
        expect(results.count)
          .to eq(1)
        expect(results.first.text)
          .to eq(account.note)
      end
    end

    context 'when the discoverable account becomes non-discoverable' do
      before { account.update!(discoverable: false) }

      it 'its bio is removed from the AccountsIndex' do
        reset_indices

        expect(results.count)
          .to eq(1)
        expect(results.first.text)
          .to be_nil
      end
    end
  end

  def results
    @results ||= AccountsIndex.filter(term: { username: account.username })
  end

  def reset_indices
    AccountsIndex.reset!
  end
end
