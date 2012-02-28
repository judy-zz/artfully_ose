RestfulMetrics::Client.async = true
RestfulMetrics::Client.disabled = true if ENV["RESTFUL_METRICS_APP"].blank?
RestfulMetrics::Client.set_credentials ENV["RESTFUL_METRICS_API_KEY"]
