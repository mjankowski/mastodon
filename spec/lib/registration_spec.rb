# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Registration do
  describe '.mode' do
    subject { described_class.mode }

    it { is_expected.to be_a(ActiveSupport::StringInquirer) }
  end
end
