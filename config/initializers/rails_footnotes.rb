if defined?(Footnotes) && Rails.env.development?
  Footnotes.run! # first of all
  Footnotes::Filter.notes += [:requests]
  # ... other init code
end
