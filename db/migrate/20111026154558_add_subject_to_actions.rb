class AddSubjectToActions < ActiveRecord::Migration
  def self.up
    add_column(:actions, :subject_id, :integer)
    add_column(:actions, :subject_type, :string)
  end

  def self.down
    remove_column(:actions, :subject_id)
    remove_column(:actions, :subject_type)
  end
end
