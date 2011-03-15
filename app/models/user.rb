class User < ActiveRecord::Base
  has_many :performances
  has_many :user_roles
  has_many :roles, :through => :user_roles
  has_many :orders

  has_many :memberships
  has_many :organizations, :through => :memberships

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :suspendable

  def self.generate_password
    Devise.friendly_token
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def has_role?(role)
    !!self.roles.find_by_name(role)
  end

  def add_role(role)
    self.roles << Role.find_by_name(role) unless has_role?(role)
  end

  def to_admin
    self.roles << Role.admin unless self.roles.include? Role.admin
  end

  def current_organization
    organizations.first || Organization.new
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
    customer.nil?? [] : delegated_credit_cards
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
