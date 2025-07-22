# frozen_string_literal: true

require 'csv'

module Admin
  class ExportDomainAllowsController < BaseController
    include Admin::ExportControllerConcern

    before_action :authorize_domain_allow_create, only: [:new, :import]
    with_options only: :import do
      before_action :set_import
      before_action :validate_import
    end

    rescue_from ActionController::ParameterMissing do
      redirect_to admin_instances_path, flash: { error: t('admin.export_domain_allows.no_file') }
    end

    def new
      @import = Admin::Import.new
    end

    def export
      authorize :instance, :index?
      send_export_file
    end

    def import
      @import.csv_rows.each do |row|
        domain = row['#domain'].strip
        next if DomainAllow.allowed?(domain)

        domain_allow = DomainAllow.new(domain: domain)
        log_action :create, domain_allow if domain_allow.save
      end

      redirect_to admin_instances_path, notice: t('admin.domain_allows.created_msg')
    end

    private

    def authorize_domain_allow_create
      authorize :domain_allow, :create?
    end

    def set_import
      @import = Admin::Import.new(import_params)
    end

    def validate_import
      render :new unless @import.validate
    end

    def export_filename
      'domain_allows.csv'
    end

    def export_headers
      %w(#domain)
    end

    def export_data
      CSV.generate(headers: export_headers, write_headers: true) do |content|
        DomainAllow.allowed_domains.each do |domain|
          content << [domain]
        end
      end
    end
  end
end
