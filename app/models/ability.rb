class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
      
    if user.has_role? :admin
      can :manage, :all

    elsif user.has_role? :producer
      can :bulk_edit, :tickets

      can [ :manage ], AthenaEvent do |athenaEvent|
        athenaEvent.producer_pid == user.id.to_s
      end

      can [ :manage ], AthenaPerformance do |athenaPerformance|
        AthenaEvent.find( athenaPerformance.event_id ).producer_pid == user.id.to_s
      end
      can [ :create ], AthenaPerformance

      can [ :manage ], AthenaChart do |athenaChart|
        athenaChart.producer_pid == user.id.to_s
      end

      cannot [ :destroy ], AthenaPerformance, :tickets_created => true
      cannot [ :edit, :destroy ], AthenaPerformance, :on_sale  => true

      cannot [ :destroy ], AthenaEvent do |athenaEvent|
        cannot_delete = false
        athenaEvent.performances.each { |performance|
          cannot_delete = true if cannot?(:destroy, performance)
        }
        cannot_delete
      end

    else # user.roles == [],  user has no role
      can :bulk_edit, :tickets

      can [ :manage ], AthenaEvent do |athenaEvent|
        athenaEvent.producer_pid == user.id.to_s
      end

      can [ :manage ], AthenaPerformance do |athenaPerformance|
        AthenaEvent.find( athenaPerformance.event_id ).producer_pid == user.id.to_s
      end
      can [ :create ], AthenaPerformance

      can [ :manage ], AthenaChart do |athenaChart|
        athenaChart.producer_pid == user.id.to_s
      end

      cannot [ :destroy ], AthenaPerformance, :tickets_created => true
      cannot [ :edit, :destroy ], AthenaPerformance, :on_sale  => true

      cannot [ :destroy ], AthenaEvent do |athenaEvent|
        cannot_delete = false
        athenaEvent.performances.each { |performance|
          cannot_delete = true if cannot?(:destroy, performance)
        }
        cannot_delete
      end
    end

  end
end
