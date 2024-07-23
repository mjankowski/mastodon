# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WebauthnCredential do
  describe 'validations' do
    subject { Fabricate.build(:webauthn_credential) }

    it { is_expected.to validate_presence_of(:external_id) }
    it { is_expected.to validate_presence_of(:public_key) }
    it { is_expected.to validate_presence_of(:nickname) }
    it { is_expected.to validate_presence_of(:sign_count) }

    it { is_expected.to validate_uniqueness_of(:external_id) }
    it { is_expected.to validate_uniqueness_of(:nickname).scoped_to(:user_id) }

    it 'is invalid if sign_count is negative or non-number or greater than limit' do
      expect(subject)
        .to_not allow_values(
          'invalid sign_count',
          -1,
          described_class::SIGN_COUNT_LIMIT * 2
        )
        .for(:sign_count)
    end
  end
end
