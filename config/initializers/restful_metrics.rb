RestfulMetrics::Client.async = true
RestfulMetrics::Client.disabled = true if Rails.env != 'production'
RestfulMetrics::Client.disabled = true if ENV["RESTFUL_METRICS_APP"].blank?
