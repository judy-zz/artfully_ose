module ApplicationHelper
  include LinkHelper
  include BulkEditHelper
  include TicketTableHelper

  def contextual_menu(&block)
    menu = ContextualMenu.new(self)
    block.call(menu)
    menu.render_menu
  end
end
