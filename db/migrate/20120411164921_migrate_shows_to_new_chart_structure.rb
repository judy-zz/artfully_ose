class MigrateShowsToNewChartStructure < ActiveRecord::Migration
  def self.up
    Show.all.each do |show|
      new_chart = Chart.new({ :name => show.chart.name, 
                              :organization => show.chart.organization, 
                              :is_template => false,
                              :event => show.event }) #intentionally leave off the sections
      
      show.chart.sections.each do |section|
        new_section = section.dup!
        new_section.chart = new_chart
        new_section.save
        show.tickets.where(:section_id => section.id).each do |ticket|
          ticket.section = new_section
          ticket.save
        end
      end
      
      Chart.skip_callback(:create, :after, :create_first_section)
      show.chart = new_chart
      show.save      
      Chart.set_callback(:create, :after, :create_first_section)
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end