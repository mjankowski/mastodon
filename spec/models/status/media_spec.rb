# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Status::Media do
  subject { Fabricate.build :status }

  describe 'Associations' do
    it { is_expected.to have_many(:media_attachments).dependent(:nullify) }
  end

  describe 'Scopes' do
    describe '.without_empty_attachments' do
      subject { Status.without_empty_attachments }

      let!(:status_attachments_nil) { Fabricate :status, ordered_media_attachment_ids: nil }
      let!(:status_attachments_empty) { Fabricate :status, ordered_media_attachment_ids: [] }
      let!(:status_attachments_present) { Fabricate :status, ordered_media_attachment_ids: [123, 456] }

      it 'returns records without empty array ordered attachments' do
        expect(subject)
          .to include(status_attachments_nil)
          .and include(status_attachments_present)
          .and not_include(status_attachments_empty)
      end
    end
  end

  describe '#with_media?' do
    subject { Fabricate.build :status }

    context 'when media associated' do
      before { subject.ordered_media_attachment_ids = [Fabricate(:media_attachment, status: subject).id] }

      it { is_expected.to be_with_media }
    end

    context 'when no media associated' do
      it { is_expected.to_not be_with_media }
    end
  end

  describe '#ordered_media_attachments' do
    let(:status) { Fabricate(:status) }

    let(:first_attachment) { Fabricate(:media_attachment) }
    let(:second_attachment) { Fabricate(:media_attachment) }
    let(:last_attachment) { Fabricate(:media_attachment) }
    let(:extra_attachment) { Fabricate(:media_attachment) }

    before do
      stub_const('Status::Media::MEDIA_ATTACHMENTS_LIMIT', 3)

      # Add attachments out of order
      status.media_attachments << second_attachment
      status.media_attachments << last_attachment
      status.media_attachments << extra_attachment
      status.media_attachments << first_attachment
    end

    context 'when ordered_media_attachment_ids is not set' do
      it 'returns up to MEDIA_ATTACHMENTS_LIMIT attachments' do
        expect(status.ordered_media_attachments.size).to eq Status::MEDIA_ATTACHMENTS_LIMIT
      end
    end

    context 'when ordered_media_attachment_ids is set' do
      before do
        status.update!(ordered_media_attachment_ids: [first_attachment.id, second_attachment.id, last_attachment.id, extra_attachment.id])
      end

      it 'returns up to MEDIA_ATTACHMENTS_LIMIT attachments in the expected order' do
        expect(status.ordered_media_attachments).to eq [first_attachment, second_attachment, last_attachment]
      end
    end
  end
end
