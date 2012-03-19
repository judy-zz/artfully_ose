class Store::StoreController < ActionController::Base
  layout "storefront"

  helper_method :current_cart
  def current_cart
    return @current_cart if @current_cart
    @current_cart ||= Cart.find_by_id(session[:order_id])
    create_current_cart if @current_cart.nil? or @current_cart.completed?
    @current_cart
  end

  private
    def create_current_cart
      @current_cart = Cart.create
      session[:order_id] = @current_cart ? @current_cart.id : nil
    end
end