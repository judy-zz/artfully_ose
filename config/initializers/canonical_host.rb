Rails.application.config.middleware.insert_before ActiveRecord::QueryCache, Rack::CanonicalHost do
  case ENV['RACK_ENV'].to_sym
    when :production then 'www.artfullyhq.com'
  end
end