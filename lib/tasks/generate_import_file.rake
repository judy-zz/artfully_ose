# This script generates a CSV import file for
# testing user import functionality.

# USAGE: `ruby generate_import_file.rb NUM` 
#   - NUM is the number of users you want
#     to generate.



namespace :generate do
  desc "This script generates a CSV import file for testing user import functionality."
  task :import_file => :environment do
    require 'faker'

    I18n.reload!

    File.open("#{Rails.root}/tmp/import.csv", "w") do |f|
      f.puts "Email,First name,Last name,Company name,Address 1,Address 2,City,State,Zip,Country,Phone1 type,Phone1 number,Phone2 type,Phone2 number,Phone3 type,Phone3 number,Website,Twitter handle,Facebook url,Linked in url,Tags,Person Type"

      number_of_rows = ENV['PEOPLE'].to_i || 5

      number_of_rows.times do
        first_name = Faker::Name.first_name
        last_name  = Faker::Name.last_name
        f.puts [
          Faker::Internet.email,
          first_name,
          last_name,
          Faker::Company.name,
          Faker::Address.street_address,
          Faker::Address.secondary_address,
          Faker::Address.city,
          Faker::Address.us_state,
          Faker::Address.zip_code,
          "USA",
          "Home",
          Faker::PhoneNumber.phone_number,
          "Cell",
          Faker::PhoneNumber.phone_number,
          "Work",
          Faker::PhoneNumber.phone_number,
          Faker::Internet.domain_name,
          "#{first_name.downcase}.#{last_name.downcase}",
          "facebook.com/#{first_name.downcase}.#{last_name.downcase}",
          "linkedin.com/user/#{first_name.downcase}.#{last_name.downcase}",
          Faker::Lorem.words(5).join("|"),
          Faker::Lorem.words(1)
        ].join(',')
        # f.write '\n'
      end

    end
  end

end