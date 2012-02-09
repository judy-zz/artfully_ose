class NotesController < ApplicationController
  before_filter :find_person

  def create
    @person.notes.create(params[:note])
    redirect_to @person
  end

  def destroy
    Note.destroy(params[:id])
    redirect_to notes_url(@note)
  end

  private

  def find_person
    @person = Person.find(params[:person_id])
    authorize! :edit, @person
  end

  # Adding this on spec
  def index
  end
end

