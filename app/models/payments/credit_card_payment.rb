class CreditCardPayment < ::Payment
  payment_method [:credit_card, :credit_card_swipe, :credit_card_manual, :cc, :credit]
  
  #ActiveMerchant::Billing::CreditCard
  attr_accessor :credit_card 
  
  def initialize(params = {})
    self.credit_card    ||= ActiveMerchant::Billing::CreditCard.new
    self.customer       ||= Person.new
    build(params) unless params.blank?
  end
  
  def per_item_processing_charge
    lambda { |item| item.realized_price * 0.035 }
  end
  
  #
  # We may be able to get some milage out of a repo called active_attr: https://github.com/cgriego/active_attr
  #
  def build(params)
    [:amount, :user_agreement, :transaction_id].each do |field| 
      self.instance_variable_set("@#{field.to_s}", params[field])
    end
    
    unless params[:credit_card].nil?
      params[:credit_card].each do |key, value| 
        self.credit_card.send("#{key}=", value)
      end
    end
    
    unless params[:customer].nil?
      self.customer.first_name  = params[:customer][:first_name]
      self.customer.last_name   = params[:customer][:last_name]
      self.customer.email       = params[:customer][:email]
      self.customer.phones      << Phone.new(:number => params[:customer][:phone]) unless params[:customer][:phone].blank?
      
      self.customer.address = Address.new(:address1 => params[:customer][:address][:address1],
                                          :city     => params[:customer][:address][:city],
                                          :state    => params[:customer][:address][:state],
                                          :zip      => params[:customer][:address][:zip])
    end
  end
  
  def gateway
    @gateway ||= ActiveMerchant::Billing::BraintreeGateway.new(
        :merchant_id => Rails.configuration.braintree.merchant_id,
        :public_key  => Rails.configuration.braintree.public_key,
        :private_key => Rails.configuration.braintree.private_key
      )
  end
  
  def requires_authorization?
    amount > 0
  end

  def requires_settlement?
    true
  end
  
  #purchase submits for auth and passes a flag to merchant to settle immediately
  def purchase(options={})
    ::Rails.logger.debug("Sending purchase request to Braintree")
    response = gateway.purchase(self.amount, credit_card, options)
    ::Rails.logger.debug("Received response: #{response.message}")
    ::Rails.logger.debug(response.inspect)
    self.transaction_id = response.authorization
    response
  end
  
  def authorize(options={})
    response = gateway.authorize(self.amount, credit_card, options)
    self.transaction_id = response.authorization
    response
  end
  
  def capture(response, options={})
    gateway.capture(self.amount, response.authorization, options)
  end
  alias :settle :capture
end