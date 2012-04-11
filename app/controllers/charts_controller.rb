class ChartsController < ApplicationController
  def update
    @chart = Chart.find(params[:id])
    authorize! :edit, @chart
    @chart.update_attributes_from_params(params[:chart])
    flash[:notice] = "Prices saved!"
    redirect_to prices_event_url(@chart.event)
  end
end