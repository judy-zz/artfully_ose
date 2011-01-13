module LinkHelper

  ICONS = {
    :edit =>    "icons/actions_small/Pencil.png",
    :delete =>  "icons/actions_small/Trash.png",
    :view =>    "icons/actions_small/Note.png",
    :copy =>    "icons/actions_small/Copy.png"
  }.freeze

  def table_icon_link_to(type, path, options = {})
    options[:title] ||= type.to_s.capitalize
    (options[:class] ||= "") << ' table_icon'

    text = ICONS[type] || type

    link_to image_tag(text, :alt => options[:title]), path, options
  end
end