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
