class Admin < ActiveRecord::Base
  devise :database_authenticatable, :trackable, :validatable, :timeoutable, :lockable, :recoverable
  attr_accessible :email, :password, :password_confirmation
end
