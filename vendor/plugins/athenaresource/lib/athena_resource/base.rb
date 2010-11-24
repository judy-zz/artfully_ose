require 'athena_resource/formats'

module AthenaResource
  class Base < ActiveResource::Base
    class << self
      def format
        read_inheritable_attribute(:format) || AthenaResource::Formats::AthenaFormat
      end

      def collection_path(prefix_options = {}, query_options = nil)
        check_prefix_options(prefix_options)
        prefix_options, query_options = split_options(prefix_options) if query_options.nil?
        "#{prefix(prefix_options)}#{collection_name}/.#{format.extension}#{query_string(query_options)}"
      end

      private
        def check_prefix_options(prefix_options)
          p_options = HashWithIndifferentAccess.new(prefix_options)
          prefix_parameters.each do |p|
            raise(MissingPrefixParam, "#{p} prefix_option is missing") if p_options[p].blank?
          end
        end
    end

    def encode(attrs = nil, options = {})
      attrs ||= attributes
      return self.class.format.encode(attrs, options) if self.class.format.respond_to? :encode
      super(options)
    end
  end

  class Base < ActiveResource::Base
  end
end
