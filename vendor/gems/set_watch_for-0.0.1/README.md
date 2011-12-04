# set_watch_for

set_watch_for will create methods on your class that convert a field into a timezone held by another object.

## Usage

Consider that we have a class Show that belongs_to Event (that the show is a part of) and Organization (that is putting on the event).  Show has a property show_time which is the datetime of the show.  We may store the time in the database in UTC, but when the time is displayed to a buyer, we want it displayed local to the event.  There may also be some cases where we want the show_time displayed in the Organization's time zone.

  class Show
    belongs_to :event
    belongs_to :organization
  
    set_watch_for :show_time, :local_to => :organization
    set_watch_for :show_time, :local_to => :event
  end

This will create two methods on Show:

  show_time_local_to_event
  show_time_local_to_organization

The object specified by :local_to needs to have a property called time_zone which returns a string timezone ("Pacific Time (US & Canada)")

## Installation 

TODO