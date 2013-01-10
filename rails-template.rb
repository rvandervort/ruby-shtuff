
# ========================================================================
# Gem Declarations
# ========================================================================

# Misc
gem 'thin'
gem 'rb-readline'
gem 'squeel'         # Make AREL more fun

# Frontend-related
gem 'draper'
gem 'haml-rails'
gem 'jquery-rails'
gem 'rabl'          # JSON views, instead of to_json

if with_mobile = yes?("Mobile too?")
 gem 'mobylette'    # Mobile detection and handling
end


# Authentication
if with_devise = yes?("Authentication with devise ?")
  gem 'devise'
  gem 'cancan'    # Permissions

  if with_facebook = yes?("Omniauth for facebook?")
    gem 'omniauth-facebook'
  end
end

# Asset Pipeline
gem_group :assets do
  gem 'libv8'
  gem 'therubyracer'
  gem 'execjs'
end


if with_bootstrap = yes?("Use Twitter Bootstrap ?")
  gem_group :assets do  
    gem "less-rails"
    gem "twitter-bootstrap-rails"
  end
end

# Development / Testing Gems
gem_group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'guard'
  gem 'guard-rspec'
  gem 'rb-inotify'
end


# ========================================================================
# Setup
# ========================================================================
run "bundle install"
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

generate "rspec:install"
run 'guard init'
run 'guard init rspec'


# Rabl - no roots
initializer 'rabl.rb', <<-CODE
require 'rabl'
Rabl.configure do |config|
  config.include_json_root = false
end
CODE

if with_devise
  generate "devise:install"
  generate "devise User"
  rake "db:migrate"
  generate "cancan:ability"

  if with_facebook
    initializer 'omniauth.rb', <<-CODE
Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'],
                 :scope => 'email', :display => 'popup'
end
    CODE
  end
end

if with_bootstrap
  generate 'bootstrap:install less'
  layout = ask("Bootstrap layout ? (fixed|fluid): ")
  generate "bootstrap:layout application #{layout}"

  run 'rm app/views/layouts/applitcation.html.erb'
end

if with_facebook
  run 'mkdir app/controllers/users'

  # Create the callbacks controller
  file 'app/controllers/users/omniauth_callbacks_controller.rb', <<-CODE
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    # Replace with the actual authentication code here -- request.env["omniauth.auth"]
  end
end
  CODE

  # Create the route entries
  route <<-CODE
devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
devise_scope :user do
  match "/users/auth/facebook/callbacks", controller: "omniauth_callbacks", action: "facebook"
end
  CODE

end

# ========================================================================
# Cleanup
# ========================================================================
remove_file "public/index.html"


# ========================================================================
# GIT Setup
# ========================================================================
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"

say <<-eos
  ============================================================================
  Rails app  #{app_name} is ready to go !!
eos

if with_facebook
  say <<-eos
    - devise_for and devise_scope for omniauth_callbacks needed
  eos
end

