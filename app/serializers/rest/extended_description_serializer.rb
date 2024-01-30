# frozen_string_literal: true

class REST::ExtendedDescriptionSerializer < REST::BaseSerializer
  attribute :updated_at do
    extended_description.updated_at&.iso8601
  end

  attribute :content do
    if extended_description.text.present?
      markdown.render(extended_description.text)
    else
      ''
    end
  end

  private

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end
end
