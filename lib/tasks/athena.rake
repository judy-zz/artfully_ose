require 'sunspot/spec/extension'

namespace :athena do
  desc "Migrate data from Athena to ActiveRecord"
  task :migrate => :environment do
    errors = []
    db_config = YAML::load(File.read(::Rails.root.to_s + "/db/mongo.yml"))
    mongo_config = db_config["local"]
    db = Mongo::Connection.new(mongo_config['host'], mongo_config['port']).db(mongo_config['database'])
    
    unless mongo_config['username'].nil?
      auth = db.authenticate(mongo_config['username'], mongo_config['password'])
    end
    
    
    STDOUT.write "\t\t\tCOUNT\tMIGRATED\tERRORS\n"
    STDOUT.write "\t\t\t-----\t--------\t------\n"
    
    errors << migrate_collection("EVENTS", db.collection("event")) do |mongo_record|
      Event.new({
                :name => mongo_record['props']['name'],
                :venue => mongo_record['props']['venue'],
                :state => mongo_record['props']['state'],
                :city => mongo_record['props']['city'],
                :time_zone => mongo_record['props']['timeZone'],
                :producer => mongo_record['props']['producer'],
                :is_free => mongo_record['props']['isFree'],
                :organization_id => mongo_record['props']['organizationId'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
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
                :email => mongo_record['props']['email'],
                :old_mongo_id => mongo_record['_id'].to_s
              })
      person.organization = Organization.find(mongo_record['props']['organizationId'])
      person
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
  
  def migrate_collection(row_label, db_collection)
    errors = []
    count = db_collection.count()
    records = db_collection.find()
    i = 0
    records.each do |mongo_record|
      begin
        new_model = yield(mongo_record)
        if new_model.save
          i+=1
        else
          errors << "Could not migrate #{row_label} #{mongo_record['_id'].to_s}: #{new_model.errors.first}"
        end
      rescue => e
        errors << "Could not migrate #{row_label} #{mongo_record['_id'].to_s}: #{e.to_s}"
      end
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