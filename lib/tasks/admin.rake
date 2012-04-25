namespace :admin do

  desc "Create a new Admin"
  task :create, [ :email, :password ] => [ :environment ] do |t, args|
    if Admin.find_by_email(args[:email]).present?
      puts "An admin already exists with that email address."
    else
      admin = Admin.new(:email => args[:email], :password => args[:password])
      if admin.save
        puts "Created a new admin with email address #{args[:email]}"
      else
        puts "Trouble creating a new admin: "
        puts admin.errors.full_messages.to_sentence
      end
    end
  end

  namespace :messages do
    desc "Add an admin message which will appear on every user's dashboard during the specified dates"
    task :add, [ :message, :start, :end ] => [ :environment ] do |t, args|
      if args[:message].blank? || args[:start].blank? || args[:end].blank?
        puts "Please specify the message and the start and end dates."
      else
        AdminMessage.create! \
          :message   => args[:message],
          :starts_on => Date.parse(args[:start]),
          :ends_on   => Date.parse(args[:end])
        puts "Message added."
      end
    end

    desc "Remove all admin messages"
    task :clear => :environment do
      count = AdminMessage.count
      AdminMessage.destroy_all
      puts "Removed #{count} messages"
    end
  end

end
