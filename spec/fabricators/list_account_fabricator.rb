# frozen_string_literal: true

Fabricator(:list_account) do
  list
  account

  # initialize_with do
  #   resolved_class.new(list: list, account: list.account)
  # end
end
