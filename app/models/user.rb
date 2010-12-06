class User < ActiveRecord::Base
  has_many :performances
  has_many :user_roles
  has_many :roles, :through => :user_roles
  has_many :orders

  after_create :create_record_in_athena_people

  belongs_to :organization

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  def has_role?(role)
    !!self.roles.find_by_name(role)
  end

  def to_producer
    self.roles << Role.producer unless self.roles.include? Role.producer
  end

  def to_admin
    self.roles << Role.admin unless self.roles.include? Role.admin
  end

  def customer
    @customer ||= find_customer
  end

  def customer=(customer)
    unless customer.nil? or customer.id.nil?
      @customer = customer
      update_attribute(:customer_id, customer.id)
      save
    end
  end

  delegate :credit_cards, :credit_cards=, :to => :customer
  alias delegated_credit_cards credit_cards
  def credit_cards
    customer.nil?? [] : delegated_credit_cards
  end

  def create_record_in_athena_people
    @person = AthenaPerson.new
    @person.email = self.email
    if @person.save
      self.athena_id = @person.id
      self.save
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
end