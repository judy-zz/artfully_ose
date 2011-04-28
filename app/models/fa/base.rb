class FA::Base < ActiveResource::Base
  self.site = "http://api.fracturedatlas.org"

  self.auth_type = :digest
  self.user = 'artful.ly'
  self.password = '36659e2cd56b2cef6b4e2b4c4196e2df'
end