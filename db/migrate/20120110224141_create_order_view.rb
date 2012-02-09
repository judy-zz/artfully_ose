class CreateOrderView < ActiveRecord::Migration
  def self.up
    execute "CREATE VIEW order_view AS " + 
            "SELECT o.id, o.created_at, o.updated_at, o.transaction_id, o.price, o.service_fee, o.fa_id, o.organization_id, " + 
            "o.person_id, orgs.name as organization_name, p.first_name as person_first_name, " + 
            "p.last_name as person_last_name FROM orders o " + 
            "LEFT JOIN people p " + 
            "ON o.person_id = p.id " + 
            "LEFT JOIN organizations orgs " + 
            "ON o.organization_id = orgs.id;"
  end

  def self.down
  end
end
