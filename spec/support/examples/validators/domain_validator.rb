# frozen_string_literal: true

RSpec.shared_examples 'Domain Validation' do
  describe 'Validations for domain attribute' do
    context 'with a valid domain' do
      it { is_expected.to allow_value('host.example').for(:domain) }
    end

    context 'with a domain that is too long' do
      before { stub_const 'DomainValidator::MAX_DOMAIN_LENGTH', 5 }

      it { is_expected.to_not allow_value('host.test').for(:domain) }
    end

    context 'with a domain with an empty segment' do
      it { is_expected.to_not allow_value('.example.com').for(:domain) }
    end

    context 'with a domain with an invalid character' do
      it { is_expected.to_not allow_value('*.example.com').for(:domain) }
    end

    context 'with a domain that would fail parsing' do
      it { is_expected.to_not allow_value('/').for(:domain) }
    end
  end
end
