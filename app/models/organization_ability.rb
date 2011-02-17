class OrganizationAbility
  include CanCan::Ability

  def initialize(organization)
    organization.kits.each do |kit|
      kit.abilities.arity < 1 ? instance_eval(&kit.abilities) : kit.abilities.call(self)
    end

    can :manage, AthenaEvent, :organization_id => organization.id
    can :manage, AthenaPerformance, :organization_id => organization.id
    can :manage, AthenaChart, :organization_id => organization.id
  end
end