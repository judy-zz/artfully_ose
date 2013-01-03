class ReportsController < ApplicationController
  def discounts
    @orders = OrderView.artfully.includes(:items)
  end
end