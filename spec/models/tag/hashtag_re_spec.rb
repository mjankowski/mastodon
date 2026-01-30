# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag::HASHTAG_RE do
  describe 'Valid matches' do
    subject { string.match(described_class).to_s }

    context 'when string is ﻿#ａｅｓｔｈｅｔｉｃ' do
      let(:string) { '﻿this is #ａｅｓｔｈｅｔｉｃ' }

      it { is_expected.to eq('#ａｅｓｔｈｅｔｉｃ') }
    end

    context 'when string is like ＃ｆｏｏ' do
      let(:string) { 'this is ＃ｆｏｏ' }

      it { is_expected.to eq('＃ｆｏｏ') }
    end

    context 'with digits at start' do
      let(:string) { 'hello #3d' }

      it { is_expected.to eq('#3d') }
    end

    context 'with digits in the middle' do
      let(:string) { 'hello #l33ts35k' }

      it { is_expected.to eq('#l33ts35k') }
    end

    context 'with digits at the end' do
      let(:string) { 'hello #world2016' }

      it { is_expected.to eq('#world2016') }
    end

    context 'with underscores at the beginning' do
      let(:string) { 'hello #_test' }

      it { is_expected.to eq('#_test') }
    end

    context 'with underscores at the end' do
      let(:string) { 'hello #test_' }

      it { is_expected.to eq('#test_') }
    end

    context 'with underscores in the middle' do
      let(:string) { 'hello #one_two_three' }

      it { is_expected.to eq('#one_two_three') }
    end

    context 'with middle dots' do
      let(:string) { 'hello #one·two·three' }

      it { is_expected.to eq('#one·two·three') }
    end

    context 'with ・unicode in ぼっち・ざ・ろっく correctly' do
      let(:string) { 'testing #ぼっち・ざ・ろっく' }

      it { is_expected.to eq('#ぼっち・ざ・ろっく') }
    end

    context 'with ZWNJ characters' do
      let(:string) { 'just add #نرم‌افزار and' }

      it { is_expected.to eq('#نرم‌افزار') }
    end

    context 'with middle dots at the end' do
      let(:string) { 'hello #one·two·three·' }

      it { is_expected.to eq('#one·two·three') }
    end

    context 'with hashtags immediately following the letter ß' do
      let(:string) { 'Hello toß #ruby' }

      it { is_expected.to eq('#ruby') }
    end

    context 'with hashtags containing uppercase characters' do
      let(:string) { 'Hello #rubyOnRails' }

      it { is_expected.to eq('#rubyOnRails') }
    end
  end

  describe 'Invalid matches' do
    subject { string.match(described_class) }

    context 'when URLs with anchors with non-hashtag characters' do
      let(:string) { 'Check this out https://medium.com/@alice/some-article#.abcdef123' }

      it { is_expected.to be_nil }
    end

    context 'when URLs with hashtag-like anchors' do
      let(:string) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)#Lawsuit' }

      it { is_expected.to be_nil }
    end

    context 'when URLs have hashtag-like anchors after a dot' do
      let(:string) { 'https://en.wikipedia.org/wiki/Google_LLC_v._Oracle_America,_Inc.#Decision' }

      it { is_expected.to be_nil }
    end

    context 'when URLs with hashtag-like anchors after a numeral' do
      let(:string) { 'https://gcc.gnu.org/bugzilla/show_bug.cgi?id=111895#c4' }

      it { is_expected.to be_nil }
    end

    context 'when URLs with hashtag-like anchors after a non-ascii character' do
      let(:string) { 'https://example.org/testé#foo' }

      it { is_expected.to be_nil }
    end

    context 'when URLs with hashtag-like anchors after an empty query parameter' do
      let(:string) { 'https://en.wikipedia.org/wiki/Ghostbusters_(song)?foo=#Lawsuit' }

      it { is_expected.to be_nil }
    end

    context 'when middle dots at the start' do
      let(:string) { 'hello #·one·two·three' }

      it { is_expected.to be_nil }
    end

    context 'when purely-numeric hashtags' do
      let(:string) { 'hello #0123456' }

      it { is_expected.to be_nil }
    end
  end
end
