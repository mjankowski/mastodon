# frozen_string_literal: true

Fabricator(:status) do
  account { Fabricate.build(:account) }
  text 'Lorem ipsum dolor sit amet'

  after_build do |status|
    status.uri = rand(16**64).to_s(16).rjust(64, '0').chars.to_a.join if !status.account.local? && status.uri.nil?
  end
end
