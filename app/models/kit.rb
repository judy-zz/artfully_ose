class Kit < ActiveRecord::Base
  include ActiveRecord::Transitions
  belongs_to :user
  validates_presence_of :user

  after_initialize :set_state

  def set_state
    self.state = "new"
  end

  def self.acts_as_kit(options, &block)
    @kit_for = options.delete(:for) || User
    @with_approval = options.delete(:with_approval) || false

    state_machine do
      state :new
      state :activated, :enter => :on_activate
      state :cancelled

      event :activate do
        transitions :from => :new, :to => :activated, :guard => :activatable?
      end

      event :cancel do
        transitions :from => [:activated, :rejected ], :to => :cancelled
      end
    end

    class_eval(&block)
  end

  def self.activate_kit(options)
    requirements[:unless] << options.delete(:unless) if options.has_key?(:unless)
    requirements[:if] << options.delete(:if) if options.has_key?(:if)
  end

  def self.requirements
    @requirements ||= Hash.new { |h,k|  h[k] = [] }
  end

  def self.grant(options)
    grants[:roles] << options.delete(:role)
    grant_procs << options.delete(:by)
  end

  def self.grants
    @grants ||= Hash.new { |h,k|  h[k] = [] }
  end

  def self.grant_procs
    @grant_procs ||= []
  end

  def activatable?
    return false unless (new? or user.nil?)

    unlesses =  self.class.requirements[:unless].all? { |req| !self.send(req) }
    ifs      =  self.class.requirements[:if]    .all? { |req| self.send(req) }

    (unlesses.nil? or unlesses) and (ifs.nil? or ifs)
  end

  protected
    def on_activate
      self.class.grant_procs.map { |g| g.call(self) }
    end
end