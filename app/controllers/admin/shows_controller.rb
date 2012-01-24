class Admin::ShowsController < Admin::AdminController
  def index
    @start = DateTime.now - 1.weeks
    @stop  = DateTime.now + 3.days

    shows_in_range = Show.in_range(@start, @stop)
    @shows = shows_in_range.sort{|a,b| b.datetime <=> a.datetime }
  end
end