class Ticket
  include HTTParty

  def self.base_uri
    'http://localhost'
  end

	def Ticket.find(*arguments)
		scope   = arguments.slice!(0)
		options = arguments.slice!(0) || {}
        
    case scope
			when :all	then find_all(options)
			else           find_single(scope, options)
    end   
	end
	
	def Ticket.find_single(scope, options)
    self.get(construct_uri(scope,options))
	end
	
	def Ticket.find_every(options)
    nil
	end

  def Ticket.schema(&block)
    @schema ||= Schema.find(:tickets)
  end

  def Ticket.construct_uri(scope, options)
    "#{base_uri}/tickets/#{scope}"
  end
end
