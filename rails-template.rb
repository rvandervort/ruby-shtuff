
# ========================================================================
# Gem Declarations
# ========================================================================

# Misc
gem 'thin'
gem 'rb-readline'

# Frontend-related
gem 'draper'
gem 'haml-rails'
gem 'jquery-rails'
gem 'rabl'

if with_mobile = yes?("Mobile too?")
 gem 'mobylette'
end


# Authentication
if with_devise = yes?("Authentication ?")
  gem 'devise'
  gem 'cancan'
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


if with_devise
  generate "devise:install"
  generate "devise User"
  rake "db:migrate"
  generate "cancan:ability"
end

if with_bootstrap
  generate 'bootstrap:install less'
  layout = ask("Bootstrap layout ? (fixed|fluid): ")
  generate "bootstrap:layout application #{layout}"
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

