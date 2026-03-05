# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'User::EmailAddress' do
  describe 'Validations' do
    subject { Fabricate.build :user }

    it { is_expected.to_not allow_value('john@').for(:email) }
    it { is_expected.to allow_value('admin@localhost').for(:email) }

    context 'when record has already been saved' do
      subject { Fabricate.build :user, email: 'invalid-email' }

      before { subject.save(validate: false) }

      it { is_expected.to be_valid }
    end

    describe 'Email domains denylist integration' do
      before { subject.confirmed_at = nil }

      around do |example|
        original = Rails.configuration.x.email_domains_denylist
        Rails.configuration.x.email_domains_denylist = 'mvrht.com'
        example.run
        Rails.configuration.x.email_domains_denylist = original
      end

      context 'when user email domain is not on the denylist' do
        it { is_expected.to allow_value('foo@host.example').for(:email) }
      end

      context 'when user email domain is on the denylist' do
        it { is_expected.to_not allow_values('foo@mvrht.com', 'foo@mvrht.com.topdomain.tld').for(:email) }
      end
    end

    describe 'Email domains allowlist integration' do
      before { subject.confirmed_at = nil }

      around do |example|
        original = Rails.configuration.x.email_domains_allowlist
        Rails.configuration.x.email_domains_allowlist = 'mastodon.space'
        example.run
        Rails.configuration.x.email_domains_allowlist = original
      end

      context 'when user email domain is not on the allowlist' do
        it { is_expected.to_not allow_value('foo@example.com', 'foo@mastodon.space.userdomain.com').for(:email) }
      end

      context 'when user email domain is on the allowlist' do
        it { is_expected.to allow_value('foo@mastodon.space').for(:email) }
      end

      context 'when interacting with the denylist' do
        around do |example|
          original = Rails.configuration.x.email_domains_denylist
          example.run
          Rails.configuration.x.email_domains_denylist = original
        end

        context 'with a subdomain on the denylist' do
          before { Rails.configuration.x.email_domains_denylist = 'denylisted.mastodon.space' }

          it { is_expected.to_not allow_value('foo@denylisted.mastodon.space').for(:email) }
        end
      end
    end
  end

  describe 'Scopes' do
    describe '.matches_email' do
      let!(:specified) { Fabricate :user, email: 'specified@host.example' }
      let!(:unspecified) { Fabricate :user, email: 'unspecified@host.example' }

      it 'returns users whose email starts with the string' do
        expect(described_class.matches_email('specified'))
          .to contain_exactly(specified)
          .and not_include(unspecified)
      end
    end
  end

  describe '#email_domain' do
    subject { described_class.new(email: email).email_domain }

    context 'when value is nil' do
      let(:email) { nil }

      it { is_expected.to be_nil }
    end

    context 'when value is blank' do
      let(:email) { '' }

      it { is_expected.to be_nil }
    end

    context 'when value has valid domain' do
      let(:email) { 'user@host.example' }

      it { is_expected.to eq('host.example') }
    end

    context 'when value has no split' do
      let(:email) { 'user$host.example' }

      it { is_expected.to be_nil }
    end

    context 'when value is utter gibberish' do
      let(:email) { '@@@@@@@@' }

      it { is_expected.to be_nil }
    end
  end
end
