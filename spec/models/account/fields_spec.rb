# frozen_string_literal: true

RSpec.describe Account::Fields do
  subject { Fabricate.build :account }

  describe 'Validations' do
    context 'when account is local' do
      subject { Fabricate.build :account, domain: nil }

      it { is_expected.to allow_value(fields_empty_name_value).for(:fields) }
      it { is_expected.to_not allow_values(fields_over_limit, fields_empty_name).for(:fields) }

      def fields_empty_name_value
        Array.new(4) { { 'name' => '', 'value' => '' } }
      end

      def fields_over_limit
        Array.new(described_class::DEFAULT_FIELDS_SIZE + 1) { { 'name' => 'Name', 'value' => 'Value', 'verified_at' => '01/01/1970' } }
      end

      def fields_empty_name
        [{ 'name' => '', 'value' => 'Value', 'verified_at' => '01/01/1970' }]
      end
    end
  end
end
