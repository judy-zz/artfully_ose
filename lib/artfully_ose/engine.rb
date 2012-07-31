module ArtfullyOse
  class Engine < ::Rails::Engine
    initializer "artfully_ose.braintree_config" do |app|      
      puts "ArtfullyOse: Initializing Braintree config"
      BraintreeConfig = Struct.new(:merchant_id, :public_key, :private_key)
      app.config.braintree = BraintreeConfig.new
      app.config.braintree.merchant_id   = ENV['BRAINTREE_MERCHANT_ID']
      app.config.braintree.public_key    = ENV['BRAINTREE_PUBLIC_KEY']
      app.config.braintree.private_key   = ENV['BRAINTREE_PRIVATE_KEY']
    end
    
    initializer "artfully_ose.s3_config" do |app|      
      puts "ArtfullyOse: Initializing S3 config"
      S3Config = Struct.new(:bucket, :access_key_id, :secret_access_key)
      app.config.s3 = S3Config.new
      app.config.s3.bucket               = ENV['S3_BUCKET']
      app.config.s3.access_key_id        = ENV['S3_ACCESS_KEY_ID']
      app.config.s3.secret_access_key    = ENV['S3_SECRET_ACCESS_KEY']
    end
  end
end
