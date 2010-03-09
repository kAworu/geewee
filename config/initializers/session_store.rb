# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_geewee_session',
  :secret      => '30817e3d8f52864b26407e3068c319664d00f0e00b2aa60756f88e296333fb5fdda56fb30e967fd15af25e78c4edfc6dbc15842d5efcf59ced8f223d1552d9bf'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
