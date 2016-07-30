
# ========================================================================
# Gem Declarations
# ========================================================================

# Misc
gem 'thin'

# Frontend-related
gem 'haml-rails'
gem 'jbuilder'

# Authentication
if with_devise = yes?("Authentication with devise ?")
  gem 'devise'
  gem 'cancan'    # Permissions
end

# Asset Pipeline
gem_group :assets do
  gem 'libv8'
  gem 'therubyracer'
  gem 'execjs'
end


if with_bootstrap = yes?("Use Twitter Bootstrap ?")
  gem 'bootstrap-sass'
end

if with_react = yes?("Use ReactJS (react-rails) ?")
  gem 'react-rails'
end

# Development / Testing Gems
gem_group :development, :test do
  gem 'pry'
  gem 'rspec-rails'
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
end

if with_bootstrap
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

# ========================================================================
# Cleanup
# ========================================================================
rake 'haml:erb2haml'
remove_file "public/index.html"


say <<-eos
  ============================================================================
  Rails app  #{app_name} is ready to go !!
eos
