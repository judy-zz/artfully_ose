class Kit < ActiveRecord::Base

  include ActiveRecord::Transitions
  belongs_to :organization
  validates_presence_of :organization

  scope :visible, where(Kit.arel_table[:state].eq("activated").or(Kit.arel_table[:state].eq('pending')))

  class_attribute :requires_approval, :ability_proc

  def self.acts_as_kit(options, &block)
    self.requires_approval = options.delete(:with_approval) || false
    setup_state_machine
    class_eval(&block)
  end

  def self.activate_kit(options)
    requirements[:unless] << options.delete(:unless) if options.has_key?(:unless)
    requirements[:if] << options.delete(:if) if options.has_key?(:if)
  end

  def self.requirements
    @requirements ||= Hash.new { |h,k|  h[k] = [] }
  end

  def self.when_active(&block)
    self.ability_proc = Proc.new(&block)
  end

  def self.subklasses
    @subklasses ||= [ TicketingKit, RegularDonationKit, SponsoredDonationKit ].freeze
  end

  def self.pad_with_new_kits(kits = [])
    types = kits.collect(&:type)
    padding = subklasses.reject{ |klass| types.include? klass.to_s }.collect(&:new)
    kits + padding
  end

  def abilities
    activated? ? self.class.ability_proc : Proc.new {}
  end

  def has_alternatives?
    alternatives.any?
  end

  def alternatives
    []
  end

  def requirements_met?
    check_requirements
  end

  def activatable?
    return false if organization.nil?

    if needs_approval
      submit_for_approval!
      return false
    end

    check_requirements
  end

  class DuplicateError < StandardError
  end

  protected

  private
    def check_requirements
      check_unlesses and check_ifs
    end

    def self.setup_state_machine
      state_machine do
        state :new
        state :pending
        state :activated
        state :cancelled

        event :activate do
          transitions :from => [:new, :pending], :to => :activated, :guard => :activatable?
        end

        event :cancel do
          transitions :from => [:activated, :rejected ], :to => :cancelled
        end
      end

      if requires_approval
        state_machine do
          event :submit_for_approval do
            transitions :from => :new, :to => :pending
          end
        end
      end
    end

    def check_unlesses
      return true if self.class.requirements[:unless].empty?
      self.class.requirements[:unless].all? { |req| !self.send(req) }
    end

    def check_ifs
      return true if self.class.requirements[:if].empty?
      self.class.requirements[:if].all? { |req| self.send(req) }
    end

    def needs_approval
      self.class.requires_approval and new?
    end
end