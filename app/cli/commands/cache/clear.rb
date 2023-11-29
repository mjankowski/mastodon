# frozen_string_literal: true

module Commands
  module Cache
    class Clear
      def clear_rails_cache
        Rails
          .cache
          .clear
      end
    end
  end
end
