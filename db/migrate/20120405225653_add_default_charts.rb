class AddDefaultCharts < ActiveRecord::Migration
  def self.up
    Event.all.each do |event|
      if event.charts.empty?
        puts "Adding default chart for #{event.id}"
        event.charts.build(:organization_id => event.organization, :name => event.name, :is_template => false)
        event.save
        puts "Added chart #{event.default_chart.id}"
      end
    end
  end

  def self.down
  end
end
