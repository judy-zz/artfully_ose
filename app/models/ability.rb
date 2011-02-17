class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role? :admin
      can :administer, :all
      can :manage, :all

    elsif user.has_role? :producer
      can :bulk_edit, :tickets
      can :manage, AthenaEvent
      can [ :manage, :put_on_sale, :take_off_sale, :duplicate ], AthenaPerformance
      can :manage, AthenaChart

    elsif user.roles.empty?
      cannot :manage, :all
    end

    cannot [ :edit, :destroy ], AthenaPerformance, :on_sale? => true
    cannot [ :edit, :destroy ], AthenaPerformance, :built? => true

    cannot :destroy, AthenaEvent do |event|
      event.performances.any?{ |performance| cannot? :destroy, performance }
    end
  end
end
