class ChartsController < ApplicationController
  def index
    authorize! :view, Chart
    @charts = current_organization.charts.template
  end

  def new
    authorize! :view, Chart
    @chart = current_organization.charts.build(params[:chart])
  end

  def create
    if params[:chart_id].blank?
      new_chart(params)
    else
      copy_chart(params)
    end
  end

  def show
    @charts = current_organization.charts.template
    @chart = Chart.find(params[:id])
    authorize! :view, @chart
  end

  def edit
    @chart = Chart.find(params[:id])
    authorize! :edit, @chart
  end

  def update
    @chart = Chart.find(params[:id])
    authorize! :edit, @chart
    
    #
    # HACK: The move to bootstrap left us with currency submission in the form os "DD.CC" which 
    # Artfully interpreted as DD.00.  
    # This hack converts DD.CC to DDCC
    #   
    params[:chart][:sections_attributes].each do |index, section_hash|
      new_price = (section_hash['price'].to_f * 100).to_i
      
      puts "#{section_hash['price']} > #{new_price}"
      section_hash['price'] = new_price
    end
    
    @chart.update_attributes(params[:chart])
    redirect_to prices_event_url(@chart.event)
  end

  def destroy
    @chart = Chart.find(params[:id])
    authorize! :destroy, @chart
    @chart.destroy
    redirect_to charts_url
  end

  private

  def new_chart(params)
    @chart = current_organization.charts.build(params[:chart].merge(:is_template => true))

    if @chart.save
      redirect_to @chart
    else
      render :new
    end
  end

  def copy_chart(params)
    @source_chart = Chart.find(params[:chart_id])
    authorize! :view, Chart
    @chart = @source_chart.copy!
    @chart.save
    redirect_to chart_url(@chart)
  end
end