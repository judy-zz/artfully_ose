require 'active_support/json'

module ActiveResource
  module Formats
    module AthenaFormat
      extend self

      def extension
        "json"
      end

      def mime_type
        "application/json"
      end

      def encode(hash, options = {})
        rejections = options.delete :rejections || []
        hash = hash.reject { | k , v | rejections.include? k } unless rejections.nil?

        results = encode_athena(hash)
        results = ActiveSupport::JSON.encode(results, options) unless options.delete(:skip_serialization)

        results
      end

      def decode(json)
        decode_athena(ActiveSupport::JSON.decode(json))
      end

      private
        def decode_athena(payload)
          if payload.is_a? Array
            payload.collect { |element| underscore_keys(element) }
          else
            underscore_keys(payload)
          end
        end

        def underscore_keys(payload)
          if payload.is_a? Hash
            underscored_payload = {}
            payload.each do |key, value|
              if value.kind_of? Hash
                underscored_payload[key.underscore] = underscore_keys(value)
              elsif value.kind_of? Array
                underscored_payload[key.underscore] = value.collect { |v| underscore_keys(v) }
              else
                underscored_payload[key.underscore] = value
              end
            end
            underscored_payload
          else
            if payload.respond_to? :attributes
              underscore_keyes(payload.attributes)
            else
              payload
            end
          end
        end

        def encode_athena(hash)
          camelize_keys(hash)
        end

        def camelize_keys(hash_or_model)
          if hash_or_model.respond_to? :encode and hash_or_model.respond_to? :attributes
            return hash_or_model.encode(:skip_serialization => true)
          end

          if hash_or_model.is_a? Hash
            camelized_hash = {}

            hash_or_model.each do |key, value|
              camelized_hash[key.camelize(:lower)] = camelize_keys(value) if value.kind_of? Hash
              camelized_hash[key.camelize(:lower)] = value.collect{ |value| camelize_keys(value) } if value.kind_of? Array
              camelized_hash[key.camelize(:lower)] = camelize_keys(value)
            end

            camelized_hash
          else
            hash_or_model
          end
        end
    end
  end
end

