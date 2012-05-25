class AddEveryoneToMailchimp < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      puts "pushing #{u.id}"
      u.push_to_mailchimp
    end
  end

  def self.down
  end
end
