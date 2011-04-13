class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    admin_abilities_for(user) if user.has_role? :admin
    ticketing_abilities_for(user) if user.current_organization.can? :access, :ticketing
    person_abilities_for(user)
    order_ablilities_for(user)
    default_abilities_for(user)
  end

  def default_abilities_for(user)
    cannot [ :edit, :destroy ], AthenaPerformance, :on_sale? => true
    cannot [ :edit, :destroy ], AthenaPerformance, :off_sale? => true
    cannot [ :edit, :destroy ], AthenaPerformance, :built? => true

    cannot :destroy, AthenaEvent do |event|
      event.performances.any?{ |performance| cannot? :destroy, performance }
    end

    can :manage, Organization do |organization|
      user.current_organization.can? :manage, organization
    end

    can :manage, AthenaCreditCard do |card|
      user.credit_cards.any?{|c| c.id == card.id}
    end
  end

  def admin_abilities_for(user)
    can :administer, :all
    can :manage, :all
  end

  def ticketing_abilities_for(user)
    can [:manage, :bulk_edit ], AthenaTicket do |ticket|
      user.current_organization.can? :manage, ticket
    end

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

  def order_ablilities_for(user)
    can :manage, AthenaOrder do |order|
      user.current_organization.can? :manage, order
    end
  end

  def person_abilities_for(user)
    can :manage, AthenaPerson do |person|
      user.current_organization.can? :manage, person
    end
  end

end
