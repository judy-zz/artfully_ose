class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role? :admin
      can :manage, :all
    elsif user.has_role? :producer
      can :manage, [ AthenaPerformance ]
      cannot [ :destroy ], AthenaPerformance, :tickets_created => true
      cannot [ :edit, :destroy ], AthenaPerformance, :on_sale => true
    end
  end
end
