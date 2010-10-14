require 'active_support/json'

module ActiveResource
  module Formats
    module AthenaFormat
      ATHENA_ATTRIBUTES = %w( id name )

      extend self

      def extension
        "json"
      end

      def mime_type
        "application/json"
      end

      def encode(hash, options = nil)
        ActiveSupport::JSON.encode(encode_athena(hash.clone), options)
      end

      def decode(json)
        decode_athena(ActiveSupport::JSON.decode(json))
      end

      private 
        def decode_athena(payload)
          return unpack_props!(payload) unless payload.kind_of?(Array)
          payload.map { |p| unpack_props!(p) }
        end

        def encode_athena(hash)
          pack_props!(hash)
        end

        def pack_props!(hash)
          props = {}
          hash.each do |key, value|
            props[key] = hash.delete(key) unless ATHENA_ATTRIBUTES.include?(key)
          end
          hash["props"] = props
          hash
        end
        
        def unpack_props!(hash)
          hash.merge!(hash.delete("props"))
        end
    end
  end
end

