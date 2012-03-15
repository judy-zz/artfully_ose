namespace :fafs do
  desc "Fix fafs donations pointing to the wrong donor"
  task :fix => :environment  do |t, args|
    orders = Order.joins(:person)
                   .where(:people => {:email => nil})
                   .where('fa_id is not null')
                   .where('orders.old_mongo_id is null')
                   
    org_orders = {}  
                
    orders.each do |order|
      org_orders[order.organization_id] = [] if org_orders[order.organization_id].nil?
      org_orders[order.organization_id] << order
    end
    
    org_orders.each do |org_id, orders|
      puts "ORG #{org_id} has #{orders.size} orders to fix out of #{Order.where(:organization_id => org_id).size} total"
      item_count = 0
      order_count = 0  
      orders.each do |order|
        order.items.each do |item|
          item.destroy
          item_count=item_count+1
        end
          order_count=order_count+1
        order.destroy
      end
      puts "#{item_count} items deleted"
      puts "#{order_count} orders deleted"
      puts "Importing fafs donations"
      Donation::Importer.import_all_fa_donations(Organization.find(org_id))
      puts "done"
      puts "----------------"
    end
  end
end