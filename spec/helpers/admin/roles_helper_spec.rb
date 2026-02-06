# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::RolesHelper do
  describe '#privileges_list' do
    subject { helper.privileges_list(user_role) }

    context 'with a role with default permissions' do
      let(:user_role) { Fabricate.build :user_role }

      it { is_expected.to be_blank }
    end

    context 'with a role with specific permissions' do
      let(:user_role) { Fabricate(:user_role, permissions: UserRole::FLAGS[:manage_users]) }

      it { is_expected.to eq('Manage Users') }
    end
  end
end
