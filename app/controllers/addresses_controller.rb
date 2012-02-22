class AddressesController < ApplicationController
  before_filter :find_person

  def create
    address = @person.build_address(params[:address])
    if address.save
      flash[:notice] = "Successfully added an address for #{@person.first_name} #{@person.last_name}."
    else
      flash[:error] = "There was a problem creating this address."
    end
    redirect_to person_path(@person)
  end

  def update
    now = DateTime.now.in_time_zone(current_user.current_organization.time_zone)
    o_addr = Marshal.load(Marshal.dump(@person.address))
    n_addr = params[:address]
    if @person.address.update_attributes(params[:address])
      for f in [:address1, :address2, :city, :state, :zip, :country]
        if o_addr[f] != n_addr[f]
          @person.notes.create({ :occurred_at => now, :text => "#{f} updated, old #{f} was: (#{o_addr[f]})" })
        end
      end
      flash[:notice] = "Successfully updated the address for #{@person.first_name} #{@person.last_name}."
    else
      flash[:error] = "There was a problem updating this address."
    end
    redirect_to person_path(@person)
  end

  def destroy
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
  end
end