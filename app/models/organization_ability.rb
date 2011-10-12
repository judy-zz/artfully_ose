class OrganizationAbility
  include CanCan::Ability

  def initialize(organization)
    organization.kits.each do |kit|
      kit.abilities.arity < 1 ? instance_eval(&kit.abilities) : kit.abilities.call(self)
    end

#    TODO: Use these when ids on ATHENA are actually integers
#    can :manage, Event, :organization_id => organization.id
#    can :manage, Show, :organization_id => organization.id
#    can :manage, Chart, :organization_id => organization.id

    can :manage, Event do |event|
      event.organization_id.to_i == organization.id
    end

    can :manage, Show do |performance|
      performance.organization_id.to_i == organization.id
    end

    can :manage, AthenaTicket do |ticket|
      can? :manage, Event.find(ticket.event_id)
    end

    can :manage, Chart do |chart|
      chart.organization_id.to_i == organization.id
    end

    can :manage, Person do |person|
      person.organization_id.to_i == organization.id
    end

    can :manage, Segment do |segment|
      segment.organization_id.to_i == organization.id
    end

    can :manage, Order do |order|
      order.organization_id.to_i == organization.id
    end

    can :manage, Organization do |org|
      org.id.to_i == organization.id
    end



  end
end