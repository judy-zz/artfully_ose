module ApplicationHelper
  include LinkHelper
  include BulkEditHelper
  include TicketTableHelper

  def contextual_menu(&block)
    menu = ContextualMenu.new(self)
    block.call(menu)
    menu.render_menu
  end

  def number_as_cents(cents)
    number_to_currency(cents.to_i / 100.00)
  end
end
