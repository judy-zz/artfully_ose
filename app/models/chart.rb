class Chart < ActiveRecord::Base
  include Ticket::Foundry
  foundry :using => :sections, :with => lambda { { :venue => event.venue } }

  belongs_to :event
  belongs_to :organization
  has_many :shows
  has_many :sections, :order => 'price DESC'

  validates :name, :presence => true, :length => { :maximum => 255 }

  def as_json(options = {})
    super({:methods => ['sections']}.merge(options))
  end

  scope :template, where(:is_template => true)

  # copy! is when they're editing charts and want to create a copy of
  # this chart to modify further (weekday and weekend charts)
  # This method will copy chart.is_template
  def copy!
    duplicate(:without => "id", :with => { :name => "#{name} (Copy)" })
  end

  def dup!
    duplicate(:without => "id", :with => { :is_template => false })
  end

  def assign_to(event)
    raise TypeError, "Expecting an Event" unless event.kind_of? Event
    assigned = self.dup!
    assigned.event = event
    assigned.save
  end

  def self.get_default_name(prefix)
    prefix + ', default chart'
  end

  def self.default_chart_for(event)
    raise TypeError, "Expecting an Event" unless event.kind_of? Event
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
    attrs = self.attributes.reject { |key, value| rejections.include?(key) }.merge(additions)

    self.class.new(attrs).tap do |copy|
      copy.sections = self.sections.collect { |section| section.dup! }
    end
  end

end