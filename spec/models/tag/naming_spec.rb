# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag::Naming do
  describe 'Normalizations' do
    subject { Fabricate.build :tag }

    it { is_expected.to normalize(:display_name).from('#HelloWorld').to('HelloWorld') }
    it { is_expected.to normalize(:display_name).from('Hello❤️World').to('HelloWorld') }

    it { is_expected.to normalize(:name).from('#hello_world').to('hello_world') }
    it { is_expected.to normalize(:name).from('hello world').to('helloworld') }
    it { is_expected.to normalize(:name).from('.abcdef123').to('abcdef123') }
  end

  describe 'Validations' do
    subject { Fabricate.build :tag }

    describe 'name' do
      context 'with a new record' do
        subject { Fabricate.build :tag, name: 'original' }

        it { is_expected.to allow_value('changed').for(:name) }
      end

      context 'with an existing record' do
        subject { Fabricate :tag, name: 'original' }

        it { is_expected.to_not allow_value('changed').for(:name).with_message(previous_name_error_message) }
        it { is_expected.to allow_value('ORIGINAL').for(:name) }
      end
    end

    describe 'display_name' do
      context 'with a new record' do
        subject { Fabricate.build :tag, name: 'original', display_name: 'OriginalDisplayName' }

        it { is_expected.to allow_value('ChangedDisplayName').for(:display_name) }
      end

      context 'with an existing record' do
        subject { Fabricate :tag, name: 'original', display_name: 'OriginalDisplayName' }

        it { is_expected.to_not allow_value('ChangedDisplayName').for(:display_name).with_message(previous_name_error_message) }
        it { is_expected.to allow_value('ORIGINAL').for(:display_name) }
      end
    end

    def previous_name_error_message
      I18n.t('tags.does_not_match_previous_name')
    end

    describe 'when skipping normalizations' do
      subject { Tag.new }

      before { subject.attributes[:name] = name }

      context 'with a # in string' do
        let(:name) { '#hello_world' }

        it { is_expected.to_not be_valid }
      end

      context 'with a . in string' do
        let(:name) { '.abcdef123' }

        it { is_expected.to_not be_valid }
      end

      context 'with a space in string' do
        let(:name) { 'hello world' }

        it { is_expected.to_not be_valid }
      end
    end

    it { is_expected.to allow_value('ａｅｓｔｈｅｔｉｃ').for(:name) }
  end

  describe '#formatted_name' do
    subject { tag.formatted_name }

    let(:tag) { Fabricate.build :tag, name:, display_name: }

    context 'when tag has name' do
      let(:name) { 'foo' }
      let(:display_name) { nil }

      it { is_expected.to eq('#foo') }
    end

    context 'when tag has name and display_name' do
      let(:name) { 'foobar' }
      let(:display_name) { 'FooBar' }

      it { is_expected.to eq('#FooBar') }
    end
  end

  describe '#display_name' do
    subject { tag.display_name }

    let(:tag) { Fabricate.build :tag, name:, display_name: }

    context 'when tag has name' do
      let(:name) { 'foo' }
      let(:display_name) { nil }

      it { is_expected.to eq('foo') }
    end

    context 'when tag has name and display_name' do
      let(:name) { 'foobar' }
      let(:display_name) { 'FooBar' }

      it { is_expected.to eq('FooBar') }
    end
  end

  describe '.find_or_create_by_names' do
    context 'when called with a block' do
      let(:upcase_string) { 'abcABCａｂｃＡＢＣやゆよ' }
      let(:downcase_string) { 'abcabcａｂｃａｂｃやゆよ' }
      let(:args) { [upcase_string, downcase_string] }

      it 'runs the block once per normalized tag regardless of duplicates' do
        expect { |block| Tag.find_or_create_by_names(args, &block) }
          .to yield_control.once
      end
    end

    context 'when passed an array' do
      it 'creates multiples tags' do
        expect { Tag.find_or_create_by_names(%w(tips tags toes)) }
          .to change(Tag, :count).by(3)
      end
    end

    context 'when passed a string' do
      it 'creates a single tag' do
        expect { Tag.find_or_create_by_names('test') }
          .to change(Tag, :count).by(1)
      end
    end

    context 'with a simultaneous insert condition' do
      it 'handles simultaneous inserts of the same tag in different cases without error' do
        tag_name_upper = 'Rails'
        tag_name_lower = 'rails'

        multi_threaded_execution(2) do |index|
          Tag.find_or_create_by_names(index.zero? ? tag_name_upper : tag_name_lower)
        end

        tags = Tag.where('lower(name) = ?', tag_name_lower.downcase)
        expect(tags.count).to eq(1)
        expect(tags.first.name.downcase).to eq(tag_name_lower.downcase)
      end
    end
  end

  describe '.matches_name' do
    it 'returns tags for multibyte case-insensitive names' do
      upcase_string   = 'abcABCａｂｃＡＢＣやゆよ'
      downcase_string = 'abcabcａｂｃａｂｃやゆよ'

      tag = Fabricate(:tag, name: downcase_string)
      expect(Tag.matches_name(upcase_string)).to eq [tag]
    end

    it 'uses the LIKE operator' do
      result = %q[SELECT "tags".* FROM "tags" WHERE LOWER("tags"."name") LIKE LOWER('100abc%')]
      expect(Tag.matches_name('100%abc').to_sql).to eq result
    end
  end

  describe '.matching_name' do
    context 'with single argument' do
      it 'returns tags for multibyte case-insensitive names' do
        upcase_string   = 'abcABCａｂｃＡＢＣやゆよ'
        downcase_string = 'abcabcａｂｃａｂｃやゆよ'

        tag = Fabricate(:tag, name: downcase_string)
        expect(Tag.matching_name(upcase_string)).to eq [tag]
      end
    end

    context 'with multiple name values' do
      subject { Tag.matching_name(args) }

      let!(:one) { Fabricate :tag, name: 'one' }
      let!(:two) { Fabricate :tag, name: 'two' }

      let(:args) { %w(one two) }

      it { is_expected.to contain_exactly(one, two) }
    end
  end
end
