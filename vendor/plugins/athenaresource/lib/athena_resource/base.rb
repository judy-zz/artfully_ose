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

      #Can be used when searching for a range because you can't dupe keys in a hash
      #For example: datetime=lt2011-03-02&datetime=gt2010-05-05
      def query(query_str)

        #Neither CGI::Escape nor URI.escape worked here
        #CGI::escape escaped everything and ATHENA threw 400
        #URI.escape failed to change the + to %2B which is really the only thing I wanted it to do
        query_str.gsub!(/\+/,'%2B')

        connection.get(self.collection_path + "?" + query_str, self.headers)
      end

      # This method will translate find_by_some_object_id into ...?someObjectId=9
      def method_missing(method_id, *arguments)
        if method_id.to_s =~ /find_by_(\w+)/
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

    include Headers
  end
end
