module ACH
  module Serialization
    def serializable_hash
      Hash[self.class::MAPPING.collect{ |method, key| [key, send(method).to_s] }]
    end

    def serialize
      serializable_hash.to_query
    end
  end
end