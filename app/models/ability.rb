class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    admin_abilities_for(user) if user.has_role? :admin
    ticketing_abilities_for(user) if user.current_organization.can? :access, :ticketing
    default_abilities_for(user)
  end

  def default_abilities_for(user)
    cannot [ :edit, :destroy ], AthenaPerformance, :on_sale? => true
    cannot [ :edit, :destroy ], AthenaPerformance, :built? => true

    cannot :destroy, AthenaEvent do |event|
      event.performances.any?{ |performance| cannot? :destroy, performance }
    end
  end

  def admin_abilities_for(user)
    can :administer, :all
    can :manage, :all
  end

  def ticketing_abilities_for(user)
    can :bulk_edit, :tickets

    can :manage, AthenaEvent do |event|
      user.current_organization.can? :manage, event
    end

    can [ :manage, :put_on_sale, :take_off_sale, :duplicate ], AthenaPerformance do |performance|
      user.current_organization.can? :manage, performance
    end

    can :manage, AthenaChart do |chart|
      user.current_organization.can? :manage, chart
    end

  end
end
