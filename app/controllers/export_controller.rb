class ExportController < ApplicationController

  def contacts
    @organization = current_user.current_organization
    @people = AthenaPerson.find_by_organization(@organization)
    @filename = "Artfuly-People-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    render :csv => @people, :filename => @filename
  end

  def donations
    @organization = current_user.current_organization
    @filename = "Artfuly-Donations-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    @csv_string = FasterCSV.generate do |csv|
      csv << [ "Donation Date", "Gift Amount", "Non-gift Amount" ]
      @organization.all_donations do |order, item|
        csv << [ order.timestamp, item.price, item.nongift_amount ]
      end
    end
    send_data @csv_string, :filename => @filename, :type => "text/csv", :disposition => "attachment"
  end

  def ticket_sales
    @organization = current_user.current_organization
    @filename = "Artfuly-Donations-Export-#{DateTime.now.strftime("%m-%d-%y")}.csv"
    @csv_string = FasterCSV.generate do |csv|
      csv << [ "Date of Purchase", "Price" ]
      @organization.all_ticket_sales do |order, item|
        csv << [ order.timestamp, item.price ]
      end
    end
    send_data @csv_string, :filename => @filename, :type => "text/csv", :disposition => "attachment"
  end

end
