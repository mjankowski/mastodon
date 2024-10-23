# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HistoricalData::Checker, :migrations do
  before(:all) { self.use_transactional_tests = false } # rubocop:disable RSpec/BeforeAfterAll

  after(:all)  { self.use_transactional_tests = true } # rubocop:disable RSpec/BeforeAfterAll

  let(:release_versions) do
    [
      HistoricalData::VersionTwoZeroZero,
      HistoricalData::VersionTwoFourZero,
      HistoricalData::VersionTwoFourThree,
      HistoricalData::VersionThreeThreeZero,
    ]
  end

  around do |example|
    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Tasks::DatabaseTasks.purge_current

      example.run
    end
  end

  context 'with one-step migrations' do
    before do
      populate_release_snapshots
      migrate_to_version(nil) # Go current
    end

    it 'leaves data in the expected consistent state' do
      subject.validate

      expect(subject.errors)
        .to be_empty
    end
  end

  context 'with two-step migrations' do
    before do
      while_skipping do
        populate_release_snapshots
        migrate_to_version(nil) # Go to current within skipping post-deploy block
      end

      migrate_to_version(nil) # Go current outside block
    end

    it 'leaves data in the expected consistent state' do
      subject.validate

      expect(subject.errors)
        .to be_empty
    end
  end

  private

  def populate_release_snapshots
    release_versions.each do |release|
      migrate_to_version(release::MIGRATION_TARGET)

      Rails.logger.info { "Populating data for release #{release}" }
      release.new.populate
    end
  end

  def migrate_to_version(version)
    Rails.logger.info { "Migrating to version #{version}" }

    ActiveRecord::Tasks::DatabaseTasks
      .migration_connection
      .migration_context
      .migrate(version)
  end

  def while_skipping(&block)
    ClimateControl.modify SKIP_POST_DEPLOYMENT_MIGRATIONS: 'true', &block
  end
end
