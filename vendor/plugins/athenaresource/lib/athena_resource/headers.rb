module AthenaResource
  module Headers
    extend ActiveSupport::Concern

    included do
      headers["User-agent"] = "artful.ly"
    end

    module ClassMethods
      def headers
        @headers ||= (superclass.headers.try(:dup) || {})
      end
    end

  end
end

