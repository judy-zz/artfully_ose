class PhonesController < ApplicationController
  def create
    @person = AthenaPerson.find(params[:person_id])
    authorize! :edit, @person
    @person.phones << AthenaPerson::Phone.deserialize(params[:phone_number])
    @person.save
    redirect_to person_url(@person)
  end

  def destroy
    @person = AthenaPerson.find(params[:person_id])
    authorize! :edit, @person
    @person.phones.delete_if { |phone| phone.id.eql?(params[:id]) }
    logger.info(@person.phones.select { |phone| phone.id == params[:id] })
    logger.info(@person.phones.collect(&:id))
    @person.save
    redirect_to person_url(@person)
  end
end