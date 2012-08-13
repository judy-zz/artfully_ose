require 'yaml'

ARTFULLY_CONFIG = YAML.load_file("#{Rails.root.to_s}/config/artfully.yml")[Rails.env]
