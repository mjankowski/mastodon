# frozen_string_literal: true

class HashtagNormalizer
  def normalize(str)
    str.then { unicode_normalize(it) }
       .then { lowercase(it) }
       .then { ascii_fold(it) }
       .then { remove_invalid_characters(it) }
  end

  private

  def remove_invalid_characters(str)
    str.gsub(Tag::HASHTAG_INVALID_CHARS_RE, '')
  end

  def ascii_fold(str)
    ASCIIFolding.new.fold(str)
  end

  def lowercase(str)
    str.downcase.to_s
  end

  def unicode_normalize(str)
    str.unicode_normalize(:nfkc)
  end
end
