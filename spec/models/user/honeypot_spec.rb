# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Honeypot do
  subject { Fabricate.build :user }

  describe 'Validations' do
    it { is_expected.to validate_absence_of(:website).on(:create) }
    it { is_expected.to validate_absence_of(:confirm_password).on(:create) }
  end
end
