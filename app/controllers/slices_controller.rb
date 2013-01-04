class SlicesController < ArtfullyOseController
  before_filter :load_statement

  def index
  end

  def data
    respond_to do |format|
      format.json { render :partial => "data.json" }
    end
  end

  def load_statement
    @show = Show.includes(:event => :venue, :items => :order).find(params[:statement_id])
    authorize! :view, @show
    @event = @show.event
    @shows = @event.shows.includes(:event => :venue)
    @statement = Statement.for_show(@show, @show.imported?)
  end
end