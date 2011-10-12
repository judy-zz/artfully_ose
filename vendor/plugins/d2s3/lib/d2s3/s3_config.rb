module D2S3
  class S3Config
    require 'yaml'

    cattr_reader :access_key_id, :secret_access_key, :bucket

    def self.load_config
      @@bucket            = ENV["S3_BUCKET"]
      @@access_key_id     = ENV["ACCESS_KEY_ID"]
      @@secret_access_key = ENV["SECRET_ACCESS_KEY"]
    end
  end
end
