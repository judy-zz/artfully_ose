Rails.application.config.middleware.insert_before ActiveRecord::QueryCache, Rack::CanonicalHost do
  if ENV['RACK_ENV'].present?
    case ENV['RACK_ENV'].to_sym
      when :production then 'www.artfullyhq.com'
    end
  end
end
