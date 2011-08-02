namespace :admin do
  desc "Promote a user to admin"
  task :promote, [ :email ] => [ :environment ] do |t, args|
    user = User.find_by_email(args[:email])
    if user.nil?
      puts "Unable to find a user for #{args[:email]}."
    else
      user.roles << :admin
      user.save
    end
  end

  desc "Create a new user with a default password of password"
  task :new_user, [ :email, :password ] => [ :environment ] do |t, args|
    args.with_defaults(:password => "password")
    user = User.new( :email => args[:email], :password => args[:password] )
    user.save!
  end

  desc "Create a new user and promote them to admin, default password is password"
  task :new_admin, [ :email, :password ] => [ :environment, :new_user, :promote ]

end
