class Role < ActiveRecord::Base
  has_many :user_roles
  has_many :users , :through => :user_roles


  class << self
    def producer
      Role.limit(1).where(:name => "producer").first
    end

    def admin
      Role.limit(1).where(:name => "admin").first
    end
  end
end
