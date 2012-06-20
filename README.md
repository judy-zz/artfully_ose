== Artful.ly glossary

* _User_ - A singe row in the users table.
* _Organization_ - Organizations are made up of many users.  Right now, users can only be part of one organization.  Eventually they'll be allowed to join more than one organization.  They're joined through the memberships table.
* _Kit_ - A piece of functionality.  "Paid ticketing kit", "Reseller Kit"  Activating kits unlocks functionality in the app and may require approval by FA admins and/or monthly charges.
* _Producer_ - An organization who produces events and sells tickets to their own events
* _Reseller_ - An organization who sells tickets to events that they do not produce.
* _Person_ - A person record in an organization's CRM database.  Person records are unique by email and organization_id.
* _Patron_ - A person who is buying/bought a ticket