class CreateOrderView < ActiveRecord::Migration
  def self.up
    execute "CREATE OR REPLACE VIEW order_view AS " + 
            "SELECT o.id, o.transaction_id, o.price, o.service_fee, o.organization_id, " + 
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
