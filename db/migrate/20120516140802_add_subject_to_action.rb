class AddSubjectToAction < ActiveRecord::Migration
  def self.up
    Action.all.each do |a|
      unless a.subject_id.nil?
        o = Order.find(a.subject_id)
        unless o.nil?
          a.subject = o
          a.save
        end
      end
    end
  end

  def self.down
  end
end
