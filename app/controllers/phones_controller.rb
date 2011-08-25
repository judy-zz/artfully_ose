class PhonesController < ApplicationController
  def create
    @person = AthenaPerson.find(params[:person_id])
    authorize! :edit, @person
    @person.phones << AthenaPerson::Phone.new(params[:type], params[:number])
    @person.save
    redirect_to person_url(@person)
  end

  def destroy
    @person = AthenaPerson.find(params[:person_id])
    authorize! :edit, @person
    @person.phones.delete_if { |phone| phone.id.eql?(params[:id]) }
    @person.save
    redirect_to person_url(@person)
  end
end