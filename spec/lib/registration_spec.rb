# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  describe '.mode' do
    subject { described_class.mode }

    it { is_expected.to be_a(ActiveSupport::StringInquirer) }

    context 'when mode is open' do
      before { Setting.registrations_mode = 'open' }

      it { is_expected.to be_open }
    end

    context 'when mode is approved' do
      before { Setting.registrations_mode = 'approved' }

      it { is_expected.to be_approved }
    end

    context 'when mode is none' do
      before { Setting.registrations_mode = 'none' }

      it { is_expected.to be_none }
    end
  end
end
