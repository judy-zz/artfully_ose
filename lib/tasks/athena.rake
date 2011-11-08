require "benchmark"

namespace :athena do
  desc "Migrate data from Athena to ActiveRecord"
  task :migrate => :environment do
    errors = []
    puts RAILS_ENV
    #mysql_config = YAML::load(File.read(::Rails.root.to_s + "/config/database.yml"))[RAILS_ENV]
    
    db_config = YAML::load(File.read(::Rails.root.to_s + "/db/mongo.yml"))
    mongo_config = db_config["staging"]
    db = Mongo::Connection.new(mongo_config['host'], mongo_config['port']).db(mongo_config['database'])
  
    unless mongo_config['username'].nil?
      auth = db.authenticate(mongo_config['username'], mongo_config['password'])
    end
    STDOUT.write "\t\t\tCOUNT\tMIGRATED\tERRORS\n"
    STDOUT.write "\t\t\t-----\t--------\t------\n"
    time = Benchmark.measure do
       errors << migrate_collection("EVENTS", db.collection("event").find()) do |mongo_record|
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
           
       errors << migrate_collection("CHARTS", db.collection("chart").find()) do |mongo_record|
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
           
       errors << migrate_collection("SECTIONS", db.collection("section").find()) do |mongo_record|
         section = Section.new({
                   :name => mongo_record['props']['name'],
                   :capacity => mongo_record['props']['capacity'],
                   :price => mongo_record['props']['price'],
                   :old_mongo_id => mongo_record['_id'].to_s
                 })
         section.chart = Chart.find_by_old_mongo_id(mongo_record['props']['chartId'])
         section
       end    
          
      errors << migrate_collection("PEOPLE", db.collection("person").find()) do |mongo_record|
        person = Person.new({
                  :first_name => mongo_record['props']['firstName'],
                  :last_name => mongo_record['props']['lastName'],
                  :company_name => mongo_record['props']['companyName'],
                  :website => mongo_record['props']['website'],
                  :dummy => mongo_record['props']['dummy'],
                  :email => mongo_record['props']['email'],
                  :old_mongo_id => mongo_record['_id'].to_s
                })
        unless mongo_record['props']['tags'].nil?
          Array.wrap(mongo_record['props']['tags']).each do |tag|
            person.tag_list << tag
          end
        end
      
        person.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
        person
      end 
          
      #person must be saved before phones are added
      errors << migrate_collection("PEOPLE PHONES", db.collection("person").find()) do |mongo_record|  
        person = Person.find_by_old_mongo_id(mongo_record['_id'].to_s)
        unless mongo_record['props']['phones'].nil?
          Array.wrap(mongo_record['props']['phones']).each do |phone|
            phone = Phone.from_athena(phone)
            phone.person = person
            phone.save
          end
        end
      
        person
      end
          
      errors << migrate_collection("ADDRESS", db.collection("address").find()) do |mongo_record|
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
          
      errors << migrate_collection("ORDERS", db.collection("order").find()) do |mongo_record|
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
      
        order.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
        order
      end   
          
      #This is a hacky way to reset the created_at field on order to the former timestamp field
      records = db.collection("order").find()
      # mysql_db = Sequel.connect(:adapter=>mysql_config['adapter'],
      #                     :host=>mysql_config['host'], 
      #                     :database=>mysql_config['database'], 
      #                     :user=>mysql_config['username'], 
      #                     :password=>mysql_config['password'])
      mysql_db = Sequel.connect(ENV['DATABASE_URL'])
      dataset = mysql_db[:orders]
      records.each do |mongo_record|      
        order_dataset = dataset.filter(:old_mongo_id=>mongo_record['_id'].to_s)
        order_dataset.update(:created_at => mongo_record['props']['timestamp'])
      end 
          
      errors << migrate_collection("ORDER PARENTS", db.collection("order").find()) do |mongo_record|
        child_order = Order.find_by_old_mongo_id(mongo_record['_id'].to_s)
        unless mongo_record['props']['parentId'].nil?
          parent_order = Order.find_by_old_mongo_id(mongo_record['props']['parentId'])
          child_order.parent = parent_order
        end
        child_order
      end 
        
          
      errors << migrate_collection("ACTIONS", db.collection("action").find()) do |mongo_record|
        action = Action.new({
                  :subtype => mongo_record['props']['actionSubtype'],
                  :occurred_at => mongo_record['props']['occurredAt'],
                  :details => mongo_record['props']['details'],
                  :created_at => mongo_record['props']['timestamp'],
                  :dollar_amount => mongo_record['props']['dollarAmount'],
                  :old_mongo_id => mongo_record['_id'].to_s
                })
        action.starred = (mongo_record['props']['starred'] == true ? true : false)
        action.type = (mongo_record['props']['actionType'] + "Action")
        action.person = Person.find_by_old_mongo_id(mongo_record['props']['personId'])
              
        #subjectId: breaks down like this
        #actionType subjectId is
        #---------- ------------
        #Hear       Person
        #Give       Person (or nothing, sometimes these aren't even mongoIds)
        #Get        Order
      
        unless mongo_record['props']['subjectId'].nil?
          if (action.type == "Hear" || action.type == "Give")
            action.subject_id = action.person.id
            action.subject_type = 'Person'
          elsif action.type == "Get"
             action.subject_id = Order.find_by_old_mongo_id(mongo_record['props']['subjectId']).id
             action.subject_type = 'Order'
          end
        end
      
        unless mongo_record['props']['creatorId'].nil? || mongo_record['props']['creatorId'].to_i == 0
          action.creator = User.find(mongo_record['props']['creatorId'].to_i)
        end
        action.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
      
        action
      end     
          
      errors << migrate_collection("SHOWS", db.collection("performance").find(), false) do |mongo_record|
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
          
      errors << migrate_collection("SETTLEMENTS", db.collection("settlement").find()) do |mongo_record|
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
          settlement.show = Show.find_by_old_mongo_id(mongo_record['props']['performanceId'])    
        end   
        settlement.organization = Organization.find(mongo_record['props']['organizationId'].to_i)
        settlement
      end  
          
      db.collection("ticket").find("props.eventId" => "4e972df12b039dff53e7bc76")
      errors << migrate_collection("TICKETS", db.collection("ticket").find()) do |mongo_record|
        ticket = Ticket.new({
                  :venue => mongo_record['props']['venue'],
                  :state => mongo_record['props']['state'],
                  :price => mongo_record['props']['price'],
                  :sold_price => mongo_record['props']['soldPrice'],
                
                  :sold_at => mongo_record['props']['soldAt'],
                  :old_mongo_id => mongo_record['_id'].to_s
                })
        #buyer
        ticket.buyer = Person.find_by_old_mongo_id(mongo_record['props']['buyerId'])
        #show
        ticket.show = Show.find_by_old_mongo_id(mongo_record['props']['performanceId']) 
        #section_id
        ticket.section = ticket.show.chart.sections.where(:name => mongo_record['props']['section']).first
              
        ticket.organization = Organization.find(mongo_record['props']['organizationId'].to_i)     
        ticket
      end 
          
      errors << migrate_collection("ITEMS", db.collection("item").find()) do |mongo_record|
        item = Item.new({
                  :state => mongo_record['props']['state'],
                  :price => mongo_record['props']['price'],
                  :realized_price => mongo_record['props']['realizedPrice'],
                  :net => mongo_record['props']['net'],
                  :fs_project_id => mongo_record['props']['fsProjectId'],
                  :nongift_amount => mongo_record['props']['nongiftAmount'],
                  :is_noncash => mongo_record['props']['isNoncash'],
                  :is_stock => mongo_record['props']['isStock'],
                  :is_anonymous => mongo_record['props']['isAnonymous'],
                  :fs_available_on => mongo_record['props']['fsAvailableOn'],
                  :reversed_at => mongo_record['props']['reversedAt'],
                  :reversed_note => mongo_record['props']['reversedNote'],
                  :old_mongo_id => mongo_record['_id'].to_s
                })
        item.product_type = (mongo_record['props']['productType'] == 'AthenaTicket' ? 'Ticket' : mongo_record['props']['productType'])
        
        #If product_type == Ticket, then find the ticket
        #product_type == Donation had no id, so do nothing
        if item.product_type == 'Ticket'
          item.product = Ticket.find_by_old_mongo_id(mongo_record['props']['productId'])
        end
      
        item.order = Order.find_by_old_mongo_id(mongo_record['props']['orderId'])
        item.settlement = Settlement.find_by_old_mongo_id(mongo_record['props']['settlementId']) unless mongo_record['props']['settlementId'].nil?
        item.show = Show.find_by_old_mongo_id(mongo_record['props']['performanceId']) unless mongo_record['props']['performanceId'].nil?      
        item
      end 
    end
    
    errors.each do |error|
      puts error
    end
    
    puts time
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
    records = db_collection
    i = 0
    new_models = []
    records.each do |mongo_record|
      new_models << yield(mongo_record)
      i+=1
      if (i % 100) == 0
        new_models.first.class.import new_models, :validate => validate
        update_display(row_label, count, i, errors.size)
        new_models = []
      end
    end
    
    new_models.first.class.import new_models, :validate => validate unless new_models.empty?
    update_display(row_label, count, i, errors.size)
    STDOUT.write "\n"
    errors
  end
end