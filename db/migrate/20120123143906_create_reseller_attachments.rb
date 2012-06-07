class CreateResellerAttachments < ActiveRecord::Migration

  def self.up
    create_table :reseller_attachments do |t|
      t.has_attached_file :image
      t.references :reseller_profile
      t.references :event, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :reseller_attachments
  end

end
