class ExportController < ApplicationController

  def contacts
    @organization = current_user.current_organization
    @people = @organization.people
    @filename = "Artfully-People-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    render :csv => @people, :filename => @filename
  end

  def donations
    @organization = current_user.current_organization
    @filename = "Artfully-Donations-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    @csv_string = FasterCSV.generate do |csv|
      csv << [ "Donation Date", "Gift Amount", "Non-gift Amount" ]
      @organization.donations.each do |item|
        csv << [ item.order.created_at, item.price, item.nongift_amount ]
      end
    end
    send_data @csv_string, :filename => @filename, :type => "text/csv", :disposition => "attachment"
  end

  def ticket_sales
    @organization = current_user.current_organization
    @filename = "Artfully-Ticket-Sales-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    @csv_string = FasterCSV.generate do |csv|
      csv << [ "Date of Purchase", "Price" ]
      @organization.ticket_sales.each do |item|
        csv << [ item.order.created_at, item.price ]
      end
    end
    send_data @csv_string, :filename => @filename, :type => "text/csv", :disposition => "attachment"
  end

end
