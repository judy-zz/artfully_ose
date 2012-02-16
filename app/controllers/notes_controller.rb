class NotesController < ApplicationController
  before_filter :find_person

  def new
    @note = Note.new
    @note.occurred_at = DateTime.now.in_time_zone(current_user.current_organization.time_zone)
    render :layout => false
  end

  def create
    @person.notes.create(params[:note])
    redirect_to @person
  end

  def destroy
    Note.destroy(params[:id])
    redirect_to notes_url(@note)
  end

  def edit
    @note = Note.find(params[:id])
    @person = Person.find(params[:person_id])
    render :layout => false
  end

  def update
    @person = Person.find params[:person_id]
    @note = Note.find params[:id]

    if @note.update_attributes(params[:note])
      flash[:notice] = "Note updated successfully!"
      redirect_to person_url(@person)
    else
      flash[:alert] = "There was a problem editing your note, please contact support if the problem persists."
      redirect_to :back
    end
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize! :edit, @person
  end
end

