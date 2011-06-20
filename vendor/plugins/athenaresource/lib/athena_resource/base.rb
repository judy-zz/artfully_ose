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
    
    #
    # This method will translate find_by_some_object_id into ...?someObjectId=9
    # when passed either someObject or someObject.id
    #
      def method_missing(method_id, *arguments)
        if match = /find_by_([_a-zA-Z]\w*)/.match(method_id.to_s)
          arg = arguments[0]
          term = match[1]

          #Handles case where someObject is passed in, turning it into ...?someObjectId=9
          #Can't use respond_to?('id') because 1.8 allows Object.id
          #If they sent an AthenaResource::Base or ActiveRecord::Base
          if( arguments[0].kind_of?(ActiveRecord::Base) || arguments[0].kind_of?(AthenaResource::Base) )
            term  = term + 'Id' unless term.end_with? 'Id'
            arg = arguments[0].id
          end

          #Handles case where someObject.id is passed, turning it into ...?someObjectId=9
          if( term.end_with? '_id' )
            term["_id"] = "Id"
          end

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
