# frozen_string_literal: true

class REST::PrivacyPolicySerializer < REST::BaseSerializer
  attribute :updated_at do
    privacy_policy.updated_at.iso8601
  end

  attribute :content do
    markdown.render(format(privacy_policy.text, domain: Rails.configuration.x.local_domain))
  end

  private

  def markdown
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, escape_html: true, no_images: true)
  end
end
