class AddSubjectToAction < ActiveRecord::Migration
  def self.up
    Action.all.each do |a|
      unless a.subject_id.nil?
        begin
          a.subject = Order.find(a.subject_id)
          a.save
        rescue
        end
      end
    end
  end

  def self.down
  end
end
