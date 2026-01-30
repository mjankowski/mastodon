# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account::MENTION_RE do
  describe 'Valid matches' do
    subject { string.match(described_class)[1] }

    context 'with username in the middle of a sentence' do
      let(:string) { 'Hello to @alice from me' }

      it { is_expected.to eq('alice') }
    end

    context 'with username at beginning of status' do
      let(:string) { '@alice Hey how are you?' }

      it { is_expected.to eq('alice') }
    end

    context 'with full username' do
      let(:string) { '@alice@example.com' }

      it { is_expected.to eq('alice@example.com') }
    end

    context 'with full username with dot at the end' do
      let(:string) { 'Hello @alice@example.com.' }

      it { is_expected.to eq('alice@example.com') }
    end

    context 'with dot-prepended username' do
      let(:string) { '.@alice I want everybody to see this' }

      it { is_expected.to eq('alice') }
    end

    context 'with username after the letter ß' do
      let(:string) { 'Hello toß @alice from me' }

      it { is_expected.to eq('alice') }
    end

    context 'with username including uppercase characters' do
      let(:string) { 'Hello to @aLice@Example.com from me' }

      it { is_expected.to eq('aLice@Example.com') }
    end
  end

  describe 'Invalid matches' do
    subject { string.match(described_class) }

    context 'with an email address' do
      let(:string) { 'Drop me an e-mail at alice@example.com' }

      it { is_expected.to be_nil }
    end

    context 'with a URL' do
      let(:string) { 'Check this out https://medium.com/@alice/some-article#.abcdef123' }

      it { is_expected.to be_nil }
    end

    context 'with a URL with query string' do
      let(:string) { 'https://example.com/?x=@alice' }

      it { is_expected.to be_nil }
    end
  end
end
