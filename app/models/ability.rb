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
      can :manage, AthenaEvent, :producer_pid => user.athena_id
      cannot :destroy, AthenaEvent do |event|
        event.performances.any?{ |performance| cannot? :destroy, performance }
      end

      # Performances
      #can :manage, AthenaPerformance, :producer_pid => user.athena_id

      #Currently athana_performance doesn't have a producer_pid assigned to it, so we use the event's producer_pid
      can [ :manage ], AthenaPerformance do |athena_performance|
        AthenaEvent.find( athena_performance.event_id ).producer_pid == user.athena_id
      end

      cannot [ :edit, :destroy ], AthenaPerformance, :on_sale  => true
      cannot :destroy, AthenaPerformance, :tickets_created => true

      # Charts
      can :manage, AthenaChart, :producer_pid => user.athena_id

    elsif user.roles.empty?
      cannot :manage, :all
    end

  end
end
