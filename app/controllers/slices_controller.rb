class SlicesController < ArtfullyOseController
  before_filter :load_statement

  def index
  end

  def data
    data = []
    # @statement.payment_method_rows.values.each do |row|
    #   data << Slice.new(row.payment_method, ["#AA0000","#00AA00","#000099"].sample, row.tickets) unless row.tickets == 0
    # end

    payment_method_proc = Proc.new do |items|
      payment_method_map = {}
      items.each do |item|
        puts item.inspect
        item_array = payment_method_map[item.order.payment_method]
        item_array ||= []
        item_array << item
        payment_method_map[item.order.payment_method] = item_array
      end
      payment_method_map
    end

    ticket_type_proc = Proc.new do |items|
      ticket_type_map = {}
      items.each do |item|
        puts item.inspect
        item_array = ticket_type_map[item.product.section.name]
        item_array ||= []
        item_array << item
        ticket_type_map[item.product.section.name] = item_array
      end
      ticket_type_map
    end

    # NO LONGER ARRAY OF ARRAYS.  JUST ARRAY OF BLOCKS THAT YIELD ARRAYS [one, two, three]
    data = Slicer.slice(nil, @show.items.all, [ticket_type_proc], 0)
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