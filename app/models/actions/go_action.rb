class GoAction < Action
  def action_type
    "Go"
  end
  
  def verb
    "attended"
  end
  
  def self.for(show, person)
    GoAction.new(:person => person, :occurred_at => show.datetime).tap do |go_action|
      go_action.subject = show
      go_action.details = "attended #{show.event}"
    end
  end
  
  def sentence
    details
  end
end