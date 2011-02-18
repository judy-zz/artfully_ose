class Store::StoreController < ActionController::Base
  layout "store"

  helper_method :current_order
  def current_order
    return @current_order if @current_order
    @current_order ||= Order.find_by_id(session[:order_id])
    create_current_order if @current_order.nil? or @current_order.completed?
    @current_order
  end

  private
    def create_current_order
      @current_order = Order.new
      @current_order.save!
      session[:order_id] = @current_order ? @current_order.id : nil
    end
end