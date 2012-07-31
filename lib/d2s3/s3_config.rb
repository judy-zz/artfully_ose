module D2S3
  class S3Config
    require 'yaml'

    cattr_reader :access_key_id, :secret_access_key, :bucket

    def self.load_config
      @@bucket            = config[RAILS_ENV].s3.bucket
      # @@bucket            = Artfully::Application.config.s3.bucket
      # @@access_key_id     = Artfully::Application.config.s3.access_key_id
      # @@secret_access_key = Artfully::Application.config.s3.secret_access_key
    end
  end
end
