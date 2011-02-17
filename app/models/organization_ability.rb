class OrganizationAbility
  include CanCan::Ability

  def initialize(organization)
    organization.kits.each do |kit|
      kit.abilities.arity < 1 ? instance_eval(&kit.abilities) : kit.abilities.call(self)
    end
  end
end