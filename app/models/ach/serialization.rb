module ACH::Serialization
  def serializable_hash
    Hash[self.class::MAPPING.collect{ |method, key| [key, send(method)] }]
  end

  def serialize
    serializable_hash.to_query
  end
end