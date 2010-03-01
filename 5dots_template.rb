#5dots rails template
#What do you need to succes run this template:
# 1. Installed Git SCM
# Installed gems:
# - Rspec
# - Rspec-rails
# - Cucumber
# - Cucumber-rails
# - Factory girl
# - Webrat

#initialize git repository
git :init

#adding .gitignore files to /tmp and /log folders, to prevent adding files from
#that folder to repository
run "touch tmp/.gitignore"
run "touch log/.gitignore"
run "touch vendor/.gitignore"
run "cp config/database.yml config/database.yml.example"

#making .gitignore file in RAILS_ROOT
file '.gitignore', <<-GITIGNORE_FILE
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
db/*.db
db/schema.rb
doc/app
doc/api
.idea/
vendor/
config/database.yml
coverage/*
GITIGNORE_FILE

#adding all files to repository
git :add  => "."

#first commit to save changes

git :commit   => "-a -m 'Initial commit' "

#installing rspec, rpspec-rails, cucumber and factory_girl as a testing platform,
#

plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'

gem 'factory_girl'
gem 'webrat'

rake "gems:install"

#removing standard 'test' folder.
run 'rm -rf test'


#generates RSpec and Cucumber generators and tasks
generate :rspec
generate :cucumber

#making folder for factories
run 'mkdir spec/factories'

#comitting Test Facility to repository
git :add  => '.'
git :commit  => "-a -m 'Building Testing Facility' "




