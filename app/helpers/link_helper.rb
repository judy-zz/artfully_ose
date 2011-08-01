module LinkHelper
  def active?(section)
    "active" if content_for(:_active_section) == section.to_s
  end

  def active_section
    content_for(:_active_section)
  end

  def in_section(section)
    content_for(:_active_section, section)
  end
end