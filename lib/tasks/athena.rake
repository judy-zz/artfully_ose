namespace :athena do
  desc "Migrate data from Athena to ActiveRecord"
  task :migrate => :environment do
    errors = []
    db_config = YAML::load(File.read(::Rails.root.to_s + "/db/mongo.yml"))
    mongo_config = db_config["staging"]
    db = Mongo::Connection.new(mongo_config['host'], mongo_config['port']).db(mongo_config['database'])
    
    unless mongo_config['username'].nil?
      auth = db.authenticate(mongo_config['username'], mongo_config['password'])
    end
    
    
    STDOUT.write "\t\t\tCOUNT\tMIGRATED\tERRORS\n"
    STDOUT.write "\t\t\t-----\t--------\t------\n"
    
    errors << migrate_collection("EVENTS", db.collection("event")) do |mongo_record|
      event = Event.new({
                :name => mongo_record['props']['name'],
                :venue => mongo_record['props']['venue'],
                :state => mongo_record['props']['state'],
                :city => mongo_record['props']['city'],
                :time_zone => mongo_record['props']['timeZone'],
                :producer => mongo_record['props']['producer'],
                :is_free => mongo_record['props']['isFree'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      
      event.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      event
    end  
    
    errors << migrate_collection("CHARTS", db.collection("chart")) do |mongo_record|
      chart = Chart.new({
                :name => mongo_record['props']['name'],
                :is_template => mongo_record['props']['isTemplate'],
                :organization_id => mongo_record['props']['organizationId'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      unless mongo_record['props']['eventId'].nil?
        chart.event = Event.find_by_old_mongo_id(mongo_record['props']['eventId'])
      end
      chart.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      chart
    end   
    
    errors << migrate_collection("SECTIONS", db.collection("section")) do |mongo_record|
      section = Section.new({
                :name => mongo_record['props']['name'],
                :capacity => mongo_record['props']['capacity'],
                :price => mongo_record['props']['price'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      section.chart = Chart.find_by_old_mongo_id(mongo_record['props']['chartId'])
      section
    end    
    
    errors << migrate_collection("PEOPLE", db.collection("person")) do |mongo_record|
      person = Person.new({
                :first_name => mongo_record['props']['firstName'],
                :last_name => mongo_record['props']['lastName'],
                :company_name => mongo_record['props']['companyName'],
                :website => mongo_record['props']['website'],
                :dummy => mongo_record['props']['dummy'],
                :email => mongo_record['props']['email'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      #tags
      #phones
      #addresses?
      #import/export fields
              
      person.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      person
    end 
    
    errors << migrate_collection("ADDRESS", db.collection("address")) do |mongo_record|
      address = Address.new({
                :address1 => mongo_record['props']['address1'],
                :address2 => mongo_record['props']['address2'],
                :city => mongo_record['props']['city'],
                :state => mongo_record['props']['state'],
                :zip => mongo_record['props']['zip'],
                :country => mongo_record['props']['country'],
                :created_at => mongo_record['props']['createdAt'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      address.person = Person.find_by_old_mongo_id(mongo_record['props']['personId'])
      address
    end  
    
    errors << migrate_collection("ORDERS", db.collection("order")) do |mongo_record|
      order = Order.new({
                :transaction_id => mongo_record['props']['transactionId'],
                :price => mongo_record['props']['orderTotal'],
                :created_at => mongo_record['props']['timestamp'],
                :service_fee => mongo_record['props']['serviceFee'],
                :fa_id => mongo_record['props']['faId'],
                :details => mongo_record['props']['details'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      order.person = Person.find_by_old_mongo_id(mongo_record['props']['personId'])
      
      #TODO: Will have to do this after all orders are imported
      #order.parent = Order..find_by_old_mongo_id(mongo_record['props']['personId'])
      
      order.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      order
    end   
    
    errors << migrate_collection("ORDER PARENTS", db.collection("order")) do |mongo_record|
      child_order = Order.find_by_old_mongo_id(mongo_record['_id'].to_s)
      unless mongo_record['props']['parentId'].nil?
        parent_order = Order.find_by_old_mongo_id(mongo_record['props']['parentId'])
        child_order.parent = parent_order
        puts child_order.id
        puts child_order.parent.id
      end
      child_order
    end   
       
    
    errors << migrate_collection("ACTIONS", db.collection("action")) do |mongo_record|
      action = Action.new({
                :type => mongo_record['props']['actionType'],
                :subtype => mongo_record['props']['actionSubType'],
                :occurred_at => mongo_record['props']['occurredAt'],
                :details => mongo_record['props']['details'],
                :created_at => mongo_record['props']['timestamp'],
                :starred => mongo_record['props']['starred'],
                :dollar_amount => mongo_record['props']['dollarAmount'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      #subjectId?        
      
      action.person = Person.find_by_old_mongo_id(mongo_record['props']['personId'])
      
      unless mongo_record['props']['creatorId'].nil? || mongo_record['props']['creatorId'].to_i == 0
        action.creator = User.find(mongo_record['props']['creatorId'].to_i)
      end
      
      action
    end     
    
    errors << migrate_collection("SHOWS", db.collection("performance"), false) do |mongo_record|
      show = Show.new({
                :datetime => mongo_record['props']['datetime'],
                :state => mongo_record['props']['state'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      show.event = Event.find_by_old_mongo_id(mongo_record['props']['eventId'])
      show.chart = Chart.find_by_old_mongo_id(mongo_record['props']['chartId'])
      show.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      show
    end        
    
    errors << migrate_collection("SETTLEMENTS", db.collection("settlement")) do |mongo_record|
      settlement = Settlement.new({
                :transaction_id => mongo_record['props']['transactionId'],
                :created_at => mongo_record['props']['createdAt'],
                :gross => mongo_record['props']['gross'],
                :realized_gross => mongo_record['props']['realizedGross'],
                :net => mongo_record['props']['net'],
                :items_count => mongo_record['props']['itemsCount'],
                :ach_response_code => mongo_record['props']['achResponseCode'],
                :fail_message => mongo_record['props']['failMessage'],
                :success => mongo_record['props']['success'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      unless mongo_record['props']['performanceId'].blank?
        settlement.show = Show.find(mongo_record['props']['performanceId'])    
      end   
      settlement.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      settlement
    end  

    errors.each do |error|
      puts error
    end
  end
  
  def update_display(row_label, count, progress, errors)
    if row_label.length < 8
      row_label = row_label + "\t"
    end
    STDOUT.write "#{row_label}\t\t#{count}\t#{progress}\t\t#{errors}\r"
  end
  
  def migrate_collection(row_label, db_collection, validate = true)
    errors = []
    count = db_collection.count()
    records = db_collection.find()
    i = 0
    records.each do |mongo_record|
      #begin
        new_model = yield(mongo_record)
        if new_model.save(:validate => validate)
          i+=1
        else
          errors << "Could not migrate #{row_label} #{mongo_record['_id'].to_s}: #{new_model.errors.first}"
        end
      #rescue => e
      #  errors << "Could not migrate #{row_label} #{mongo_record['_id'].to_s}: #{e.to_s}"
      #end
      update_display(row_label, count, i, errors.size)
    end
    STDOUT.write "\n"
    errors
  end
  
  def migrate_tickets(db)
    errors = []
    tickets = db.collection("ticket")
    ticket_count = tickets.count()
    all_tickets = tickets.find({"props.price" => {"$gt" => -1}}, {:limit => 20})
    all_tickets.each_with_index do |mongo_ticket, index|
      begin
        new_ticket = Ticket.new({
          :venue => mongo_ticket['props']['venue'],
          :state => mongo_ticket['props']['state'],
          :price => mongo_ticket['props']['price'],
          :sold_price => mongo_ticket['props']['soldPrice'],
          :sold_at => mongo_ticket['props']['soltAt'],
          
          #show
          :buyer_id => mongo_ticket['props']['buyerId'],
          
          #show
          :show_id => mongo_ticket['props']['showId'],
          :organization_id => mongo_ticket['props']['organizationId'],
          :old_mongo_id => mongo_ticket['_id'].to_s
          
          #will need to look up section
        })
        new_ticket.save
        update_display("TICKETS", ticket_count, index+1, errors.size)
      rescue
        errors << "Could not migrate #{mongo_ticket['_id'].to_s}"
      end
    end
    STDOUT.write "\n"
    errors
  end
end