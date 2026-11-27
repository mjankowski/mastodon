# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ActionLogsHelper do
  before { sign_in Fabricate(:admin_user) }

  describe '#sorted_action_log_target_types' do
    it 'falls back to unique, titleized target types in alphabetical order' do
      types = helper.sorted_action_log_target_types

      expect(types).to include(
        ['Collection', 'Collection'],
        ['Custom Emoji', 'CustomEmoji'],
        ['Moderation Subscription', 'ModerationSubscription'],
        ['User Role', 'UserRole']
      )
      expect(types).to eq(types.uniq.sort_by(&:first))
    end

    it 'uses translated singular model names and sorts by the translated labels' do
      allow(CustomEmoji.model_name).to receive(:human)
        .with(default: 'Custom Emoji')
        .and_return('Emoji')

      types = helper.sorted_action_log_target_types

      expect(types).to include(['Emoji', 'CustomEmoji'])
      expect(types).to eq(types.sort_by(&:first))
    end
  end

  describe '#sorted_action_log_types' do
    it 'returns only actions for the selected target type in alphabetical order' do
      expect(helper.sorted_action_log_types('Announcement')).to eq(
        [
          ['Create Announcement', :create_announcement],
          ['Delete Announcement', :destroy_announcement],
          ['Update Announcement', :update_announcement],
        ]
      )
    end
  end

  describe 'with Tags' do
    let(:tag) { Fabricate(:tag, name: '#supertag') }
    let(:account) { Fabricate(:account) }
    let!(:log) { Fabricate(:action_log, target: tag, account: account, usable: false, listable: true) }

    describe '#permutation_of_key' do
      it 'returns different permutations for all different states' do
        expect(helper.permutation_of_key(log, :usable)).to eq(:not_usable)
        expect(helper.permutation_of_key(log, :trendable)).to be_nil
        expect(helper.permutation_of_key(log, :listable)).to eq(:listable)
      end
    end

    describe '#chain_multiple_translations' do
      it 'returns translation keys for all different states' do
        expect(helper.chain_multiple_translations(log)).to eq('Cannot be used; Can be suggested')
      end
    end
  end
end
