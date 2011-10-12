class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    ticketing_abilities_for(user) if user.is_in_organization?
    paid_ticketing_abilities_for(user) if user.current_organization.can? :access, :paid_ticketing
    person_abilities_for(user) if user.is_in_organization?
    order_ablilities_for(user) if user.is_in_organization?
    default_abilities_for(user)
  end

  def default_abilities_for(user)
    cannot [ :edit, :destroy ], Show, :live? => true

    cannot :destroy, Event do |event|
      event.shows.any?{ |show| cannot? :destroy, show }
    end

    can :manage, Organization do |organization|
      user.current_organization.can?( :manage, organization ) && (user == organization.owner)
    end

    can :view, Organization do |organization|
      user.current_organization.can?( :view, organization )
    end

    can :manage, AthenaCreditCard do |card|
      user.credit_cards.any?{|c| c.id == card.id}
    end

    can :view, Settlement do |settlement|
      user.is_in_organization?
    end

    can :view, AthenaStatement do |statement|
      user.is_in_organization?
    end
  end

  def ticketing_abilities_for(user)
    can [:manage, :bulk_edit ], AthenaTicket do |ticket|
      user.current_organization.can? :manage, ticket
    end

    #This is the ability that the controller uses to authorize creating/editing an event
    can :manage, Event do |event|
      event.is_free? && (user.current_organization.can? :manage, event)
    end

    can :new, Event do |event|
      user.is_in_organization?
    end

    can :create, :paid_events do
      user.current_organization.can? :access, :paid_ticketing
    end

    can :create_tickets, Array do |sections|
      sections.none? {|s| s.price.to_i > 0} || (user.current_organization.can? :access, :paid_ticketing)
    end

    can [ :manage, :show, :hide, :duplicate ], Show do |show|
      user.current_organization.can? :manage, show
    end

    can :manage, Chart do |chart|
      user.current_organization.can? :manage, chart
    end
  end

  def paid_ticketing_abilities_for(user)
    #This is the ability that the controller uses to authorize creating/editing an event
    can :manage, Event do |event|
      user.current_organization.can? :manage, event
    end
  end

  def order_ablilities_for(user)
    can :manage, Order do |order|
      user.current_organization.can? :manage, order
    end
  end

  def person_abilities_for(user)
    can :manage, Person do |person|
      (user.current_organization.can? :manage, person)
    end

    can :manage, Segment do |segment|
      user.current_organization.can?(:manage, segment)
    end
  end

end
