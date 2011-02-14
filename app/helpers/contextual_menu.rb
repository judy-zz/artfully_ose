class ContextualMenu

  class MenuItem
    attr_accessor :text, :path, :options

    def initialize(text, path, options, menu)
      self.text, self.path, self.options = text, path, options
      @menu = menu
    end

    def render
      icon = options.delete(:icon)

      content_tag :span, :class => css_class, :id => css_id do
        link_to path, options do
          content_tag :p do
            "#{image_tag (icon) unless icon.nil?} #{text}".html_safe
          end
        end
      end
    end

    def css_id
      return "firstMenuSm lastMenuSm" if options[:first] and options[:last]
      return "firstMenuSm" if options[:first]
      return "lastMenuSm" if options[:last]
    end

    def css_class
      return "menuSmSection middleMenuSm" unless options[:first] or options[:last]
      "menuSmSection"
    end

    def is_first
      options[:first] = true
    end

    def is_last
      options[:last] = true
    end

    def method_missing(*args, &block)
      @menu.send(*args, &block)
    end
  end


  def initialize(template)
    @template = template
  end

  def render_menu
    content_tag :div, render_items, :class => "menuSm"
  end

  def item_to(text, path, options = {})
    items << MenuItem.new(text, path, options, self)
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  private
    def render_items
      items.first.is_first
      items.last.is_last
      items.collect(&:render).join.html_safe
    end

    def items
      @items ||= []
    end

    def locals(text, path, options)
      locals = { :text => text, :path => path }
      locals[:icon] = options.delete(:icon) if options.has_key?(:icon)
      locals[:options] = options || []
      locals
    end
end