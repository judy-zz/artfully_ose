class User < ActiveRecord::Base
  include RoleModel
  # Always append new roles if you add more.
  roles :admin

  has_many :performances
  has_many :orders

  has_many :memberships
  has_many :organizations, :through => :memberships
  validates_acceptance_of :user_agreement, :message => "Please accept the User Agreement"

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :suspendable

  def self.generate_password
    Devise.friendly_token
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :user_agreement

  def is_in_organization?
    organizations.any?
  end

  def is_admin?
    has_role? :admin
  end

  def current_organization
    (memberships.any? and memberships.first.organization) || Organization.new
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
