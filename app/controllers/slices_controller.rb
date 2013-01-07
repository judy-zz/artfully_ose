class SlicesController < ArtfullyOseController
  before_filter :load_statement

  def index
  end

  def data
    data = []
    # @statement.payment_method_rows.values.each do |row|
    #   data << Slice.new(row.payment_method, ["#AA0000","#00AA00","#000099"].sample, row.tickets) unless row.tickets == 0
    # end

    fifty = Proc.new do |tickets|
      price_map = {:greater_than_fifty => 0, :less_than_fifty => 0}
      tickets.each do |ticket|
        puts ticket.price
        ticket.price > 5000 ? price_map[:greater_than_fifty] = price_map[:greater_than_fifty] + 1 : price_map[:less_than_fifty] = price_map[:less_than_fifty] + 1
      end
      price_map
    end

    # NO LONGER ARRAY OF ARRAYS.  JUST ARRAY OF BLOCKS THAT YIELD ARRAYS [one, two, three]
    data = Slicer.slice(nil, @show.tickets.all, [fifty], 0)
    #data = Slicer.slice(nil, nil, [["A","B"], ["1", "2", "3"], ["XX", "YY", "ZZ"]], 0)

    respond_to do |format|
      #format.json { render :partial => "data.json" }
      format.json { render :json => Array.wrap(data) }
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