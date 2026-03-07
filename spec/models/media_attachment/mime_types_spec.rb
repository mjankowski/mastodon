# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachment::MimeTypes do
  describe '.supported_mime_types' do
    it 'returns list of types' do
      expect(MediaAttachment.supported_mime_types)
        .to all(be_a(String).and(match(%r{.*/.*})))
    end
  end
end
