class Store::StoreController < ActionController::Base
  layout "store"

  helper_method :current_cart
  def current_cart(reseller_id = nil)
    return @current_cart if @current_cart
    @current_cart ||= Cart.find_by_id(session[:order_id])
    create_current_cart(reseller_id) if @current_cart.nil? or @current_cart.completed?
    @current_cart
  end

  private
    def create_current_cart(reseller_id)
      if reseller_id.blank?
        @current_cart = Cart.create
      else
        @current_cart = Reseller::Cart.create( {:reseller => Organization.find(reseller_id)} )
      end
      session[:order_id] = @current_cart ? @current_cart.id : nil
    end
end