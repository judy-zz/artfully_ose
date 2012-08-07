class User < ActiveRecord::Base

  include Ext::DeviseConfiguration

  has_many :shows
  has_many :orders
  has_many :imports

  has_many :memberships
  has_many :organizations, :through => :memberships
  validates_acceptance_of :user_agreement

  scope :logged_in_more_than_once, where("users.sign_in_count > 1")

  after_create :metric_created
  after_create { delay.push_to_mailchimp }

  def self.generate_password
    Devise.friendly_token
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_agreement, :newsletter_emails

  def is_in_organization?
    @is_in_organization ||= memberships.any?
  end

  def current_organization
    @current_organization ||= (is_in_organization? ? memberships.first.organization : Organization.new)
  end

  def membership_in(organization)
    memberships.where(:organization_id => organization.id).limit(1).first
  end
  
  def self.like(query = "")
    return if query.blank?
    q = "%#{query}%"
    self.joins("LEFT OUTER JOIN memberships ON memberships.user_id = users.id").joins("LEFT OUTER JOIN organizations ON organizations.id = memberships.organization_id").where("email like ? or organizations.name like ?", q, q)
  end

  def push_to_mailchimp
    if newsletter_emails
      g = Gibbon.new
      result = g.list_subscribe({:id => ENV["MC_LIST_ID"], :email_address => email, :double_optin => false, :send_welcome => false})
      update_attribute(:mailchimp_message, ((result == true) ?  "success" : result['error']) )
      result
    else
      return false
    end
  end

  private

    def metric_created
      RestfulMetrics::Client.add_metric(ENV["RESTFUL_METRICS_APP"], "user_created", 1)
    end

end
