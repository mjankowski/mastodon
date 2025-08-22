# frozen_string_literal: true

class VotingLimitsValidator < ActiveModel::Validator
  attr_reader :vote

  def validate(vote)
    @vote = vote

    vote.errors.add(:base, I18n.t('polls.errors.already_voted')) if additional_voting_not_allowed?
  end

  delegate :account,
           :choice,
           :persisted?,
           :poll_multiple?,
           :poll,
           to: :vote

  private

  def additional_voting_not_allowed?
    poll_multiple_and_already_voted? || poll_non_multiple_and_already_voted?
  end

  def poll_multiple_and_already_voted?
    poll_multiple? && already_voted_for_same_choice_on_multiple_poll?
  end

  def poll_non_multiple_and_already_voted?
    !poll_multiple? && already_voted_on_non_multiple_poll?
  end

  def already_voted_for_same_choice_on_multiple_poll?
    if persisted?
      account_votes_on_same_poll.where(choice:).where.not(poll_votes: { id: vote }).exists?
    else
      account_votes_on_same_poll.exists?(choice:)
    end
  end

  def already_voted_on_non_multiple_poll?
    if persisted?
      account_votes_on_same_poll.where.not(poll_votes: { id: vote }).exists?
    else
      account_votes_on_same_poll.exists?
    end
  end

  def account_votes_on_same_poll
    poll.votes.where(account:)
  end
end
