# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachment::Extensions do
  describe '.supported_file_extensions' do
    it 'returns list of extensions' do
      expect(MediaAttachment.supported_file_extensions)
        .to all(be_a(String).and(match(/\.*/)))
    end
  end
end
