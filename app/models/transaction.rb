class Transaction < AthenaResource::Base

  schema do
    attribute 'tickets',      :string
    attribute 'lockExpires',  :string
    attribute 'lockedByApi',  :string
    attribute 'lockedByIp',   :string
    attribute 'status',       :string
  end

end
