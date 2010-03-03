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

#PLUGINS
plugin 'rspec', :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :git => 'git://github.com/dchelimsky/rspec-rails.git'
#authlogit plugin
plugin 'authlogic', :git  => 'git://github.com/binarylogic/authlogic.git'


#GEMS
gem 'factory_girl'
gem 'webrat'

#routes
route "map.resources :user_sessions, :users, :static_articles"
route "map.root :controller => \"static_articles\" "
route "map.login \"login\", :controller => \"user_sessions\", :action => \"new\" "
route "map.logout \"logout\", :controller => \"user_sessions\", :action => \"destroy\" "




rake "gems:install"


#generates RSpec and Cucumber generators and tasks
generate :rspec
generate :cucumber
generate :session , "UserSession"
generate :rspec_model , "User login:string email:string crypted_password:string password_salt:string persistence_token:string"
generate :rspec_controller, 'User_sessions'
generate :rspec_controller, 'Users new edit'
generate :rspec_scaffold, "Static_article title:string content:text user_id:integer"


run 'rm -rf test'
run 'rm public/index.html'
run 'mkdir spec/factories'
run 'rm app/views/layouts/static_articles.html.erb'



#default layout file
file 'app/views/layouts/application.html.erb', <<-LAYOUT_FILE
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3c.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
  <head>
    <title>5dots - Simple Page</title>
    <%= stylesheet_link_tag 'application' %>
    <%= yield(:head) %>
  </head>
  <body>
     <div id="content_wrapper">
      <div id="user_menu">
        <% if current_user %>
            <%= link_to "Edit profile", edit_user_path(:current_user) %>
            <%= link_to "Logout", logout_path %>
        <% else %>
          <%= link_to "Register", new_user_path %>
          <%= link_to "Login", login_path %>
        <% end %>
      </div>
      <div id="flashes">
            <%- flash.each do |name, msg| -%>
              <%= content_tag :div, msg, :id => "flash_\#{name}" %>
            <%- end -%>
      </div>

      <div id="content">
           <%= yield %>
      </div>
      </div>

  </body>
</html>
LAYOUT_FILE

# css file for application:
file "public/stylesheets/application.css", <<-APP_CSS
body {
  background-color: #ccc;
  margin: 0;
  padding: 0;
}

div#content_wrapper {
  width: 960px;
  margin: 0 auto;
  background-color: white;
  padding-top:15px;
}
div#user_menu {
  border: 1px solid grey;
  float: right;
}
APP_CSS



# user file:
file 'app/models/user.rb', <<-USER
class User < ActiveRecord::Base
  acts_as_authentic
end
USER

#user controller
file 'app/controllers/users_controller.rb', <<-USER_CONTROLLER
class UsersController < ApplicationController
  def new
	@user = User.new
  end

 def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "Registration successful."
      redirect_to root_path
    else
      render :action => 'new'
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile updated succeful."
      redirect_to root_path
    else
      render :action => 'edit'
    end
  end

end
USER_CONTROLLER

#user views
file 'app/views/users/new.html.erb',<<-NEW_USER_ERB
<h1>New User</h1>
<%= render :partial => "form" %>
NEW_USER_ERB

file 'app/views/users/edit.html.erb',<<-EDIT_USER_ERB
<h1>EDIT User</h1>
<%= render :partial => "form" %>
EDIT_USER_ERB

file 'app/views/users/_form.html.erb', <<-USER_FORM
<% form_for @user do |f| %>
	<%= f.error_messages %>
<p>
	<%= f.label :login, "User name" %> <br/>
	<%= f.text_field :login %>
</p>
<p>
	<%= f.label :email, "Email" %><br/>
	<%= f.text_field :email %>
<p>
<p>
	<%=f.label :password, "Password" %><br/>
	<%=f.password_field :password %>
</p>
<p>
        <%=f.label :password_confirmation, "Password again" %><br/>
        <%=f.password_field :password_confirmation %>
</p>
<p>
<%= f.submit "Submit" %>
</p>
<% end %>
USER_FORM


# user session controller
file 'app/controllers/user_sessions_controller.rb', <<-USER_SESSION_CONTROLLER
class UserSessionsController < ApplicationController
    def new
      @user_session = UserSession.new
    end

    def create
      @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        flash[:notice] = "Successfully logged in"
        redirect_to root_url
      else
        render :action => :new
      end
    end

    def destroy
      current_user_session.destroy
      flash[:notice] = "Succesfully logged out"
      redirect_to root_url
    end
  end
USER_SESSION_CONTROLLER

file 'app/views/user_sessions/new.html.erb', <<-NEW_USER_SESSION_FORM
<h1>Login</h1>
<% form_for @user_session do |f| %>
  <%= f.error_messages %>
<p>
  <%= f.label :login, "Login" %> <br/>
  <%= f.text_field :login %>
</p>
<p>
  <%= f.label :password, "Password" %> <br/>
  <%= f.password_field :password %>
</p>
<p><%= f.submit "Login now!" %> </p>
<% end %>
NEW_USER_SESSION_FORM

file 'app/controllers/application_controller.rb', <<-APP_CONTROLLER
class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details


  filter_parameter_logging :password

helper_method :current_user, :current_user_session

private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end
end
APP_CONTROLLER


#comitting Test Facility to repository
git :add  => '.'
git :commit  => "-a -m 'Builded simple application from template' "

rake "db:migrate"

puts "###############################################"
puts "##                                           ##"
puts "##              S U C C E S S !              ##"
puts "##                                           ##"
puts "###############################################"





