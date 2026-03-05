# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::Conversations do
  subject { Fabricate.build :status }

  describe 'Associations' do
    it { is_expected.to belong_to(:conversation).optional }
    it { is_expected.to have_one(:owned_conversation).class_name(Conversation).with_foreign_key(:parent_status_id).inverse_of(:parent_status).dependent(false) }
  end
end
