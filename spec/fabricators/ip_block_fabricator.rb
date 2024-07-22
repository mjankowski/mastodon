# frozen_string_literal: true

Fabricator(:ip_block) do
  severity 'no_access'
  ip { sequence(:ip) { |i| "#{i}.#{i}.#{i}.#{i}" } }
end
