# frozen_string_literal: true

require 'csv'

module Admin
  class ExportDomainBlocksController < BaseController
    include Admin::ExportControllerConcern

    before_action :authorize_domain_block_create, only: [:new, :import]
    with_options only: :import do
      before_action :set_import
      before_action :validate_import
    end

    rescue_from ActionController::ParameterMissing do
      flash.now[:alert] = I18n.t('admin.export_domain_blocks.no_file')
      @import = Admin::Import.new
      render :new
    end

    def new
      @import = Admin::Import.new
    end

    def export
      authorize :instance, :index?
      send_export_file
    end

    def import
      @global_private_comment = I18n.t('admin.export_domain_blocks.import.private_comment_template', source: @import.data_file_name, date: I18n.l(Time.now.utc))
      @form = Form::DomainBlockBatch.new
      @domain_blocks = import_domain_blocks
      @warning_domains = instances_from_imported_blocks.pluck(:domain)
    end

    private

    def authorize_domain_block_create
      authorize :domain_block, :create?
    end

    def set_import
      @import = Admin::Import.new(import_params)
    end

    def validate_import
      render :new unless @import.validate
    end

    def import_domain_blocks
      @import.csv_rows.filter_map do |row|
        next if already_blocked?(row)

        domain_block_from_row(row).tap do |domain_block|
          if domain_block.invalid?
            flash.now[:alert] = alert_for_block(domain_block)
            next
          end
        end
      rescue ArgumentError => e
        flash.now[:alert] = I18n.t('admin.export_domain_blocks.invalid_domain_block', error: e.message)
        next
      end
    end

    def already_blocked?(row)
      domain = row['#domain'].strip
      DomainBlock.rule_for(domain).present?
    end

    def alert_for_block(domain_block)
      t 'admin.export_domain_blocks.invalid_domain_block',
        error: domain_block.errors.full_messages.join(', ')
    end

    def domain_block_from_row(row)
      domain = row['#domain'].strip

      DomainBlock.new(
        domain: domain,
        obfuscate: row.fetch('#obfuscate', false),
        private_comment: @global_private_comment,
        public_comment: row['#public_comment'],
        reject_media: row.fetch('#reject_media', false),
        reject_reports: row.fetch('#reject_reports', false),
        severity: row.fetch('#severity', :suspend)
      )
    end

    def instances_from_imported_blocks
      Instance.with_domain_follows(@domain_blocks.map(&:domain))
    end

    def export_filename
      'domain_blocks.csv'
    end

    def export_headers
      %w(#domain #severity #reject_media #reject_reports #public_comment #obfuscate)
    end

    def export_data
      CSV.generate(headers: export_headers, write_headers: true) do |content|
        DomainBlock.with_limitations.order(id: :asc).each do |instance|
          content << [instance.domain, instance.severity, instance.reject_media, instance.reject_reports, instance.public_comment, instance.obfuscate]
        end
      end
    end
  end
end
