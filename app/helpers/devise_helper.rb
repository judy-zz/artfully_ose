module DeviseHelper
  def devise_error_messages!
    resource.errors.full_messages.map { |msg| content_tag(:div, msg, :class => "flash error") }.join.html_safe
  end
end