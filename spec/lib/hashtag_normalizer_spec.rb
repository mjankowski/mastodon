# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HashtagNormalizer do
  subject { described_class.new.normalize(string) }

  describe '#normalize' do
    context 'with full width latin characters' do
      let(:string) { 'Ｓｙｎｔｈｗａｖｅ' }

      it { is_expected.to eq('synthwave') }
    end

    context 'with half width katakana' do
      let(:string) { 'ｼｰｻｲﾄﾞﾗｲﾅｰ' }

      it { is_expected.to eq('シーサイドライナー') }
    end

    context 'with modified Latin characters' do
      let(:string) { 'BLÅHAJ' }

      it { is_expected.to eq('blahaj') }
    end

    context 'with invalid characters' do
      let(:string) { '#foo' }

      it { is_expected.to eq('foo') }
    end

    context 'with valid characters' do
      let(:string) { 'a·b' }

      it { is_expected.to eq('a·b') }
    end

    context 'with upper case characters' do
      let(:string) { 'LEGO' }

      it { is_expected.to eq('lego') }
    end
  end
end
