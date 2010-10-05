require 'role_model'

class User < ActiveRecord::Base

  include RoleModel
  roles_attribute :roles_mask
  roles :producer, :admin

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  before_save :add_default_role

  private
    def add_default_role
      self.roles << :producer if self.roles.blank?
    end
end
