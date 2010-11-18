class AthenaPerformance < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'performances'
  self.collection_name = 'performances'
  
  schema do
    attribute 'eventId', :string
    attribute 'chartId', :string
  end

  # Note: This is used to provide a more ruby-friendly set of accessors that will still serialize properly.
  def self.aliased_attr_accessor(*accessors)
    attr_reader :attributes
    accessors.each do |attr|
      attr = attr.to_s.camelize(:lower)
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{attr}()                     @attributes['#{attr}'] end
        def #{attr}=(#{attr})             @attributes['#{attr}'] = #{attr} end
        def #{attr.underscore}()          @attributes['#{attr}'] end
        def #{attr.underscore}=(#{attr})  @attributes['#{attr}'] = #{attr} end
      RUBY_EVAL
    end
  end
  
  aliased_attr_accessor :event_id, :chart_id
  
  def chart
  end
  
  def chart=
  end
  
  def event
  end
  
  def event=
  end
end