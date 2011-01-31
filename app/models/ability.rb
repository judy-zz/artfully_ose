class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role? :admin
      can :manage, :all

    elsif user.has_role? :producer

      # Tickets
      can :bulk_edit, :tickets

      # Events
      can :manage, AthenaEvent, :producer_pid => user.person.id
      cannot :destroy, AthenaEvent do |event|
        event.performances.collect{ |performance| cannot? :destroy, performance }.reduce(&:&)
      end

      # Performances
      can :manage, AthenaPerformance, :producer_pid => user.person.id
      cannot [ :edit, :destroy ], AthenaPerformance, :on_sale  => true
      cannot :destroy, AthenaPerformance, :tickets_created => true

      # Charts
      can :manage, AthenaChart, :producer_pid => user.person.id

    elsif user.roles.empty?
      cannot :manage, :all
    end

  end
end
