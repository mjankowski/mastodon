# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::Role' do
  describe 'Associations' do
    it { is_expected.to belong_to(:role).class_name(UserRole).optional }
  end

  describe 'Delegations' do
    it { is_expected.to delegate_method(:can?).to(:role) }
  end

  describe 'Validations' do
    describe 'Role elevation' do
      subject { Fabricate :user, email: 'this@that.com' }

      let(:current_account) { Fabricate :account, user: Fabricate(:user, role: Fabricate(:user_role)) }
      let(:user_role) { Fabricate(:user_role, position: 2**4) }

      before { subject.current_account = current_account }

      context 'when current_account user role has higher position' do
        before { current_account.user.role.update! position: 2**5 }

        it { is_expected.to allow_value(user_role).for(:role) }
      end

      context 'when current_account user role has lower position' do
        before { current_account.user.role.update! position: 2**3 }

        it { is_expected.to_not allow_value(user_role).for(:role).with_message(:elevated).against(:role_id) }
      end
    end
  end

  describe 'Callbacks' do
    describe 'Setting role nil when everyone' do
      subject { Fabricate.build :user, role: }

      context 'when role is everyone role' do
        let(:role) { UserRole.everyone }

        it 'changes to nil on validation' do
          expect { subject.valid? }
            .to change { subject.attributes['role_id'] }.to(be_nil).from(be_present)
        end
      end
    end
  end

  describe '#role' do
    subject { user.role }

    let(:user) { Fabricate.build :user, role: }

    context 'when user does not have a role' do
      let(:role) { nil }

      it { is_expected.to eq(UserRole.everyone) }
    end

    context 'when user has a role' do
      let(:role) { Fabricate :user_role }

      it { is_expected.to eq(role) }
    end
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
