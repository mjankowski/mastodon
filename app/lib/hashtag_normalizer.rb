# frozen_string_literal: true

class HashtagNormalizer
  def normalize(str)
    normalize_width(str)
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

  def normalize_width(str)
    str.unicode_normalize(:nfkc)
  end
end
