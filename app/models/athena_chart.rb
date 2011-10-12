class AthenaChart < AthenaResource::Base
  self.site = Artfully::Application.config.stage_site
  self.element_name = 'charts'
  self.collection_name = 'charts'

  validates :name, :presence => true, :length => { :maximum => 255 }

  schema do
    attribute 'name',             :string
    attribute 'is_template',      :string
    attribute 'event_id',         :string
    attribute 'performance_id',   :string
    attribute 'organization_id',  :string
  end

  def as_json(options = {})
    super({ :methods => [ "sections" ]}.merge(options))
  end

  def sections
    @sections ||= find_sections
  end

  def sections=(sections)
    raise TypeError, "Expecting an Array" unless sections.kind_of? Array
    @sections = sections
  end

  # copy! is when they're editing charts and want to create a copy of
  # this chart to modify further (weekday and weekend charts)
  # This method will copy chart.is_template
  def copy!
    duplicate(:without => "id", :with => { :name => "#{name} (Copy)" })
  end

  def dup!
    duplicate(:without => "id", :with => { :is_template => false })
  end

  def save
    success = super
    sections.each do |section|
      section.chart_id = self.id
      section.save
    end
    success
  end

  def event
    @event ||= AthenaEvent.find(event_id)
  end

  def event=(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @event, self.event_id = event, event.id
  end

  def assign_to(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    assigned = self.dup!
    assigned.event = event
    assigned.save
  end

  def self.find_by_event(event)
    find_by_event_id(event.id)
  end

  def self.find_by_organization(organization)
    find_by_organization_id(organization.id)
  end

  def self.find_templates_by_organization(organization)
    self.find(:all, :params => { :organizationId => "eq#{organization.id}", :isTemplate => 'eqtrue' })
  end

  def self.get_default_name(prefix)
    prefix + ', default chart'
  end

  def self.default_chart_for(event)
    raise TypeError, "Expecting an AthenaEvent" unless event.kind_of? AthenaEvent
    @chart = self.new
    @chart.name = self.get_default_name(event.name)
    @chart.event_id = event.id
    @chart
  end
  
  def has_paid_sections?
    !self.sections.drop_while{|s| s.price.to_i == 0}.empty?
  end

  private
    def duplicate(options = {})
      rejections = Array.wrap(options[:without])
      additions = options[:with] || {}

      self.class.new(self.attributes.reject { |key, value| rejections.include?(key) } ).tap do |copy|
        copy.load(additions)
        copy.sections = self.sections.collect { |section| section.dup! }
      end
    end

    def find_sections
      return [] if new_record?
      secs = AthenaSection.find(:all, :params => { :chartId => "eq#{id}" })
      secs.each do |section|
        section.chart = self
      end
      secs.sort { |a,b| b.price.to_f <=> a.price.to_f }
    end
end