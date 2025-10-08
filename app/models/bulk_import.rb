# frozen_string_literal: true

class BulkImport < ApplicationRecord
  self.inheritance_column = false

  ARCHIVE_PERIOD = 1.week
  CONFIRM_PERIOD = 10.minutes

  belongs_to :account
  has_many :rows, class_name: 'BulkImportRow', inverse_of: :bulk_import, dependent: :delete_all

  after_save :finalize_import, if: [:state_previously_changed?, :state_finished?]

  enum :type, {
    following: 0,
    blocking: 1,
    muting: 2,
    domain_blocking: 3,
    bookmarks: 4,
    lists: 5,
  }

  enum :state, {
    unconfirmed: 0,
    scheduled: 1,
    in_progress: 2,
    finished: 3,
  }, prefix: true

  validates :type, presence: true

  scope :archival_completed, -> { where(created_at: ..ARCHIVE_PERIOD.ago) }
  scope :confirmation_missed, -> { state_unconfirmed.where(created_at: ..CONFIRM_PERIOD.ago) }

  def failure_count
    processed_items - imported_items
  end

  def processing_complete?
    processed_items == total_items
  end

  def self.progress!(bulk_import_id, imported: false)
    # Use `increment_counter` so that the incrementation is done atomically in the database
    BulkImport.increment_counter(:processed_items, bulk_import_id)
    BulkImport.increment_counter(:imported_items, bulk_import_id) if imported

    # Since the incrementation has been done atomically, concurrent access to `bulk_import` is now benign
    bulk_import = BulkImport.find(bulk_import_id)
    bulk_import.state_finished! if bulk_import.processing_complete?
  end

  def finalize_import
    touch :finished_at
  end
end
