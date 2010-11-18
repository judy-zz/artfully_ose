class AthenaEvent < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'events'
  self.collection_name = 'events'
  
  schema do
    attribute 'name', :string
    attribute 'venue', :string
    attribute 'producer', :string
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
  
  aliased_attr_accessor :chart_id
  
  def chart
    @chart ||= AthenaChart.find(chart_id)
  end
  
  def chart=(chart)
    @chart = chart
    chart_id = chart.id
  end
  
end