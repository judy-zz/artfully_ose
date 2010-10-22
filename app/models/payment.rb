class Payment < AthenaResource::Base

  schema do
    attribute 'amount', :string
  end
end
