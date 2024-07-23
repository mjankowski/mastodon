# frozen_string_literal: true

require 'rails_helper'

describe DomainAllow do
  describe 'Validations' do
    it { is_expected.to validate_presence_of(:domain) }

    it 'is invalid if the same normalized domain already exists' do
      _domain_allow = Fabricate(:domain_allow, domain: 'にゃん')

      expect(subject)
        .to_not allow_values(
          'xn--r9j5b5b'
        )
        .for(:domain)
    end
  end
end
