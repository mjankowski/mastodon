# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Role' do
  describe 'Associations' do
    it { is_expected.to belong_to(:role).class_name(UserRole).optional }
  end

  describe 'Delegations' do
    it { is_expected.to delegate_method(:can?).to(:role) }
  end

  describe '.those_who_can' do
    before { Fabricate(:moderator_user) }

    context 'when there are not any user roles' do
      before { UserRole.destroy_all }

      it 'returns an empty list' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([])
      end
    end

    context 'when there are not users with the needed role' do
      it 'returns an empty list' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([])
      end
    end

    context 'when there are users with roles' do
      let!(:admin_user) { Fabricate(:admin_user) }

      it 'returns the users with the role' do
        expect(described_class.those_who_can(:manage_blocks)).to eq([admin_user])
      end
    end
  end
end
