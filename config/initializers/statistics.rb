# frozen_string_literal: true

[
  %w(Todos app/lib),
  %w(Presenters app/presenters),
  %w(Policies app/policies),
  %w(Serializers app/serializers),
  %w(Services app/services),
  %w(Validators app/validators),
  %w(Workers app/workers),
].each do |name, directory|
  Rails::CodeStatistics.register_directory(name.titleize, directory)
end
