module Ticket::Reporting
  extend ActiveSupport::Concern

  module InstanceMethods
    def glance
      @glance ||= Ticket::Glance.new(self)
    end
  end
end