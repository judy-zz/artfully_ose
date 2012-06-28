# Artful.ly

## Artful.ly glossary

* _User_ - A singe row in the users table.
* _Organization_ - Organizations are made up of many users.  Right now, users can only be part of one organization.  Eventually they'll be allowed to join more than one organization.  They're joined through the memberships table.
* _Kit_ - A piece of functionality.  "Paid ticketing kit", "Reseller Kit"  Activating kits unlocks functionality in the app and may require approval by FA admins and/or monthly charges.
* _Producer_ - An organization who produces events and sells tickets to their own events
* _Reseller_ - An organization who sells tickets to events that they do not produce.
* _Person_ - A person record in an organization's CRM database.  Person records are unique by email and organization_id.
* _Patron_ - A person who is buying/bought a ticket

## Schema installation

* Upgrading to Devise 2.0 meant we had to go back and modify ancient migrations.  These haven't been fully tested on a fresh install, so you may run into problems with the user.rb and admin.rb models missing columns.

## Dependencies

* ATHENA Payments - You can download ATHENA here: http://github.com/fracturedatlas/ATHENA.  If that's too much trouble you can point to our demo ATHENA.  See `config/environments/demo.rb` 

* Solr - We use solr for indexing.  Starting the app with `foreman start` will spin up a local solr instance.  You'll only need this if you're working with people or checkout.

* S3 - If you're going to be uploading images or working with imports, you'll need valid S3 keys: `ACCESS_KEY_ID, SECRET_ACCESS_KEY, S3_BUCKET=artfully-demo`

## Admins

Admins are their own model.  To create an admin, call `bundle exec rake admin:create["admin@artfullyhq.com","password"]`  That will create an addmin with the specified user and password.  Admins login at

    http://localhost:port/admin
    