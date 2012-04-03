class User < ActiveRecord::Base
  has_many :shows
  has_many :orders
  has_many :imports

  has_many :memberships
  has_many :organizations, :through => :memberships
  validates_acceptance_of :user_agreement

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :suspendable, :invitable

  scope :logged_in_more_than_once, where("users.sign_in_count > 1")

  def self.generate_password
    Devise.friendly_token
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_agreement

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

  private
    def find_customer
      begin
        return AthenaCustomer.find(self.customer_id)
      rescue ActiveResource::ResourceNotFound
        update_attribute(:customer_id, nil) && save
        return nil
      end unless self.customer_id.nil?
    end
end
