# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  describe '.mode' do
    subject { described_class.mode }

    context 'when registrations mode setting is open' do
      before { Setting.registrations_mode = 'open' }

      it { is_expected.to be_open }
    end

    context 'when registrations mode setting is approved' do
      before { Setting.registrations_mode = 'approved' }

      it { is_expected.to be_approved }
    end

    context 'when registrations mode setting is none' do
      before { Setting.registrations_mode = 'none' }

      it { is_expected.to be_none }
    end
  end
end
