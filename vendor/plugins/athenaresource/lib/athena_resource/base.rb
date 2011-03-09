require 'athena_resource/formats'

module AthenaResource
  class Base < ActiveResource::Base

    # Enable ActiveModel callbacks for models
    extend ActiveModel::Callbacks
    define_model_callbacks :create, :save, :validation

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

    def create
      run_callbacks :create do
        super
      end
    end

    def save
      run_callbacks :save do
        super
      end
    end

    def valid?
      run_callbacks :validation do
        super
      end
    end

    def encode(options = {})
      attrs = options.delete(:attributes) || attributes
      return self.class.format.encode(attrs, options) if self.class.format.respond_to? :encode
      super(options)
    end
  end

  class Base < ActiveResource::Base
  end
end
