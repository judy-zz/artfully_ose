class OrganizationAbility
  include CanCan::Ability

  def initialize(organization)
    organization.kits.each do |kit|
      kit.abilities.arity < 1 ? instance_eval(&kit.abilities) : kit.abilities.call(self)
    end

#    TODO: Use these when ids on ATHENA are actually integers
#    can :manage, AthenaEvent, :organization_id => organization.id
#    can :manage, AthenaPerformance, :organization_id => organization.id
#    can :manage, AthenaChart, :organization_id => organization.id

    can :manage, AthenaEvent do |event|
      event.organization_id.to_i == organization.id
    end

    can :manage, AthenaPerformance do |performance|
      performance.organization_id.to_i == organization.id
    end

    can :manage, AthenaChart do |chart|
      chart.organization_id.to_i == organization.id
    end

    can :manage, AthenaPerson do |person|
      person.organization_id.to_i == organization.id
    end

    can :manage, AthenaOrder do |order|
      order.organization_id.to_i == organization.id
    end

  end
end