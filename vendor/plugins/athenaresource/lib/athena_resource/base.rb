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

      def parameterize(params = {})
        Hash[params.collect{|key, value| [key.camelize(:lower),value] }]
      end

      def search_index(search_query, organization, limit=10)
        if search_query.blank?
          search_query = ''
        else
          search_query.concat(' AND ')
        end

        search_query.concat("organizationId:").concat("#{organization.id}")
        find(:all, :params => { '_q' => search_query, '_limit' => limit})
      end

      # This method will translate find_by_some_object_id into ...?someObjectId=9
      def method_missing(method_id, *arguments)
        if method_id =~ /find_by_(\w+)/
          arg = arguments[0]
          term = $1.camelcase(:lower)

          find(:all, :params => { term => arg })
        else
          super
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
end
