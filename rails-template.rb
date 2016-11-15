
# ========================================================================
# Gem Declarations
# ========================================================================

# Authentication
if with_devise = yes?("Authentication with devise ?")
  gem 'devise'
  gem 'cancan'    # Permissions
end


# Frontend-related
gem 'haml-rails'
gem 'jbuilder'

# Asset Stuff
gem 'libv8'
gem 'therubyracer'
gem 'execjs'


if with_bootstrap = yes?("Use Twitter Bootstrap ?")
  gem 'bootstrap-sass'
end

if with_react = yes?("Use ReactJS (react-rails) ?")
  gem 'react-rails'
end

if with_sapnwrfc = yes?("Use SAPNWRFC for SAP Connections?")
  gem 'sapnwrfc'
end

# Development / Testing Gems
gem_group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
  gem 'turnip'
end


# ========================================================================
# Setup
# ========================================================================
run "bundle install"
rake "db:create", :env => 'development'
rake "db:create", :env => 'test'

generate "rspec:install"

if with_devise
  generate "devise:install"
  generate "devise User"
  rake "db:migrate"
  generate "cancan:ability"
  generate "devise:views"


  append_file "db/seeds.rb", <<-CODE
[User].each(&:delete_all)
User.create(email: "test@test.com", password: "testme123")
  CODE

  # TODO: The seeds file could contain more than just
  # the user accounts, so this should be refactored
  if yes?("Devise : generate test@test.com user?")
    rake 'db:seed'
  end
end

if with_bootstrap

  # Go get the rails application template
  run 'rm app/views/layouts/application.html.erb'
  run 'curl https://raw.githubusercontent.com/rvandervort/ruby-shtuff/master/application.hmtl.haml > app/views/layouts/application.html.haml'

  # Bootstrap Stylesheets
  run 'mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss'
  append_file 'app/assets/stylesheets/application.scss', <<-CODE
@import "bootstrap-sprockets";
@import "bootstrap";
  CODE

  gsub_file 'app/assets/stylesheets/application.scss', '*= require_tree .', '*'
  gsub_file 'app/assets/stylesheets/application.scss', '*= require_self', '*'


  # Bootstrap Javascript
  append_file 'app/assets/javascripts/application.js', <<-CODE
//= require bootstrap-sprockets
  CODE
end

if with_react
  generate 'react:install'

  append_file 'app/assets/javascripts/application.js', <<-CODE
//= require react
//= require react_ujs
//= require components
  CODE

  application "config.react.addons = true"
end

if yes?("generate dashboard controller and routes?")
  generate 'controller', 'dashboard', 'index'
  if yes?('set dashboard#index to root?')
    route "root to: 'dashboard#index'"
  end
end

if with_sapnwrfc
  # Generate an initializer
  initializer 'sapnwrfc.rb', <<-CODE
require 'sapnwrfc'
SAPNW::Base.config_location = "\#{Rails.root}/config/sapnwrfc.yml"
SAPNW::Base.load_config
CODE

  # Generate a blank config file
  file 'config/sapnwrfc.yml', <<-CODE
ashost: [enter sap host]
sysnr: [enter SAP system number]
client: [enter SAP client]
user: [enter SAP rfc user]
passwd: [enter SAP rfc user's password]
lang: EN
trace: 0
CODE

end

# No helpers, view_specs, or helper_specs
application <<-CODE
config.generators do |g|
  g.helper = false
  g.view_specs = false
  g.helper_specs = false
end
CODE

# Setup testing
append_file '.rspec', <<-CODE
--color
--require turnip/rspec
CODE

# ========================================================================
# Cleanup
# ========================================================================
run 'yes | bundle exec rake haml:erb2haml'
remove_file "public/index.html"


say <<-eos
  ============================================================================
  Rails app  #{app_name} is ready to go !!
eos
