# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountMigration::Cooldown do
  describe '#remaining_cooldown_days' do
    subject { account_migration.remaining_cooldown_days }

    before { stub_const('AccountMigration::COOLDOWN_PERIOD', 30.days) }

    let(:account_migration) { Fabricate :account_migration, created_at: }

    context 'with a record still in cooldown' do
      let(:created_at) { 15.days.ago }

      it { is_expected.to eq(15) }
    end

    context 'with a record out of cooldown' do
      let(:created_at) { 150.days.ago }

      it { is_expected.to be_negative }
    end
  end
end
