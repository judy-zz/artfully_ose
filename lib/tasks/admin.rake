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
end
