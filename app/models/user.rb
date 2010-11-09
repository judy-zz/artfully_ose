require 'role_model'

class User < ActiveRecord::Base

  has_many :performances

  include RoleModel
  # The order of the roles matter, so only append to the list.
  roles :admin, :patron, :producer

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  before_save :add_default_role

  private
    def add_default_role
      roles << :patron if roles.empty?
    end
end
