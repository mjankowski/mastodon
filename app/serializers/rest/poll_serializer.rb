# frozen_string_literal: true

class REST::PollSerializer < REST::BaseSerializer
  class OptionSerializer < REST::BaseSerializer
    attributes :title, :votes_count
  end

  attributes :expires_at,
             :multiple,
             :votes_count,
             :voters_count

  has_many :loaded_options, as: :options, serializer: OptionSerializer
  has_many :emojis, serializer: REST::CustomEmojiSerializer

  attribute :id do
    poll.id.to_s
  end

  attribute :expired do
    poll.expired?
  end

  attribute :voted, if: :current_user? do
    poll.voted?(current_user.account)
  end

  attribute :own_votes, if: :current_user? do
    poll.own_votes(current_user.account)
  end
end
