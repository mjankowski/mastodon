# frozen_string_literal: true

module User::Approval
  extend ActiveSupport::Concern

  def approve!
    return if approved?

    update!(approved: true)

    # Handle condition when approving and confirming at the same time
    reload unless confirmed?
    prepare_new_user! if confirmed?
  end
end
