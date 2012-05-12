class GetAction < Action
  def action_type
    "Get"
  end
  
  def verb
    "purchased"
  end
  
  def full_details
    details + " ding!"
  end
end