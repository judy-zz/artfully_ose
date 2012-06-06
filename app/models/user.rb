class User < ActiveRecord::Base

  has_many :shows
  has_many :orders
  has_many :imports

  has_many :memberships
  has_many :organizations, :through => :memberships
  validates_acceptance_of :user_agreement

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :suspendable, :invitable

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

  def customer
    @customer ||= find_customer
  end

  def customer=(customer)
    unless customer.nil? or customer.id.nil?
      @customer, self.customer_id = customer, customer.id
      save
    end
  end

  delegate :credit_cards, :credit_cards=, :to => :customer
  alias delegated_credit_cards credit_cards
  def credit_cards
    customer.nil? ? [] : delegated_credit_cards
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

    def find_customer
      begin
        return AthenaCustomer.find(self.customer_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute(:customer_id, nil) && save
        return nil
      end unless self.customer_id.nil?
    end

    def metric_created
      RestfulMetrics::Client.add_metric(ENV["RESTFUL_METRICS_APP"], "user_created", 1)
    end

end
