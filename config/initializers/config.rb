require 'yaml'

ACH::CONFIG = YAML.load_file("#{Rails.root.to_s}/config/ach.yml")[Rails.env]