# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User::Registration do
  subject { Fabricate.build :user }

  describe 'Validations' do
    before { stub_const 'User::REGISTRATION_FORM_MIN_TIME', 3.seconds }

    it { is_expected.to allow_values(nil, 10.seconds.ago).for(:registration_form_time) }
    it { is_expected.to_not allow_value(1.second.ago).for(:registration_form_time).against(:base) }
  end
end
