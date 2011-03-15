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
end