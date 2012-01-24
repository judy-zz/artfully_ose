class AddBlurbToResellerAttachment < ActiveRecord::Migration

  def self.up
    add_column :reseller_attachments, :comment, :text
    rename_column :reseller_attachments, :event_id, :attachable_id
    rename_column :reseller_attachments, :event_type, :attachable_type
  end

  def self.down
    remove_column :reseller_attachments, :comment
    rename_column :reseller_attachments, :attachable_id, :event_id
    rename_column :reseller_attachments, :attachable_type, :event_type
  end

end
