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
gem 'declarative_authorization', :source => 'http://gemcutter.org'


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
generate :rspec_model, "Role name:string display_name:string"
generate :rspec_model, "UsersRole user_id:integer role_id:integer"


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
            <%= link_to "Edit profile", edit_user_path(current_user) %>
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



# user model file:
file 'app/models/user.rb', <<-USER
class User < ActiveRecord::Base
  attr_accessible :login, :email, :password, :password_confirmation, :roles, :role_ids

  acts_as_authentic

  has_many :users_roles
  has_many :roles, :through => :users_roles
  has_many :static_articles

  accepts_nested_attributes_for :roles

  def role_symbols
    roles.map do |role|
      role.name.underscore.to_sym
    end
  end

  def has_role?(role_name)
    self.role_symbols.include?(role_name)
  end
end
USER

#role model file
file 'app/models/role.rb', <<-ROLE
class Role < ActiveRecord::Base
  attr_accessible :name, :display_name

  has_many :users_roles
  has_many :users , :through => :users_roles
end
ROLE

#users_role model file
file 'app/models/users_role.rb',<<-USERS_ROLE
class UsersRole <ActiveRecord::Base
  attr_accessible :role_id, :user_id

  belongs_to :user
  belongs_to :role
end
USERS_ROLE

#user controller
file 'app/controllers/users_controller.rb', <<-USER_CONTROLLER
class UsersController < ApplicationController
  filter_resource_access
  def new
	@user = User.new
  end

 def create
    @user = User.new(params[:user])
    @user.roles << Role.find_by_name("user")
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
<h1>Register</h1>
<%= render :partial => "form" %>
NEW_USER_ERB

file 'app/views/users/edit.html.erb',<<-EDIT_USER_ERB
<h1>Edit profile</h1>
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
    filter_resource_access
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

before_filter :set_current_user

helper_method :current_user, :logged_in?


def logged_in?
  current_user
end

def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
end

protected
   def permission_denied
    flash[:error] = "Permission Denied"
    redirect_to login_url
  end

 def set_current_user
   Authorization.current_user = current_user
 end

private
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end


end
APP_CONTROLLER

#default seed data
file 'db/seeds.rb', <<-SEED_DATA
puts "default roles"
Role.create!(:name => "user", :display_name =>"Użytkownik")
Role.create!(:name => "admin", :display_name =>"Administrator")
puts "Roles loaded!/n"
SEED_DATA

file 'config/authorization_rules.rb',<<-AUTHORIZATION_RULES
authorization do
  role :guest do
    has_permission_on [:user_sessions], :to => [:new, :create]
    has_permission_on [:users], :to => [:new, :create]
    has_permission_on :static_articles, :to  => :read
  end

  role :user do
     includes :guest
      has_permission_on :user_sessions, :to => :delete
      has_permission_on :static_articles, :to  => :create
      has_permission_on :users, :to => [:edit, :update] do
         if_attribute :id  => is {user.id}
      end
      has_permission_on :static_articles, :to => [:edit, :update] do
        if_attribute :user_id => is {user.id}
      end
  end
  role :admin do
    has_permission_on [:users, :user_sessions, :static_articles ], :to => :all
  end


end
privileges do
  privilege :all, :includes => [:create, :read, :update, :delete]
  privilege :read, :includes => [:index, :show]
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
AUTHORIZATION_RULES

file 'app/controllers/static_articles_controller.rb', <<-ARTICLES_CONTROLLER
class StaticArticlesController < ApplicationController
filter_resource_access
  def index
    @static_articles = StaticArticle.all
  end

  def show
  end

  def new
    @static_article = StaticArticle.new
  end

  def edit
  end

  def create
    params[:static_article][:user_id] = current_user.id
    @static_article = StaticArticle.new(params[:static_article])

      if @static_article.save
        flash[:notice] = 'StaticArticle was successfully created.'
        redirect_to(@static_article)
      else
        render :action => "new"
      end
end

  def update
     if @static_article.update_attributes(params[:static_article])
        flash[:notice] = 'Article was successfully updated.'
        redirect_to(@static_article)

      else
        render :action => "edit"
      end

  end
  def destroy
    @static_article.destroy
	redirect_to(static_articles_url)
  end
end
ARTICLES_CONTROLLER

file 'app/views/static_articles/show.html.erb', <<-SHOW_ARTICLE_VIEW
<p>
  <b>Title:</b>
  <%=h @static_article.title %>
</p>

<p>
  <b>Content:</b>
  <%=h @static_article.content %>
</p>

<p>
  <b>Author:</b>
  <%=h @static_article.user.login %>
</p>

<% if permitted_to? :edit, @static_article %>
<%= link_to 'Edit', edit_static_article_path(@static_article) %> |
<% end %>
<%= link_to 'Back to List', static_articles_path %>
SHOW_ARTICLE_VIEW

file 'app/views/static_articles/index.html.erb', <<-ARTICLE_INDEX_VIEW
      <h1>Listing articles</h1>

<table>
  <tr>
    <th>Title</th>
    <th>Content</th>
    <th>Author</th>
  </tr>

<% @static_articles.each do |static_article| %>
  <tr>
    <td><%=h static_article.title %></td>
    <td><%=h static_article.content %></td>
    <td><%=h static_article.user.login %></td>

    <td><%= link_to 'Show', static_article %></td>
<% if permitted_to? :edit, static_article %>
    <td><%= link_to 'Edit', edit_static_article_path(static_article) %></td>
<% end %>
<% if permitted_to? :destroy, static_article %>
    <td><%= link_to 'Destroy', static_article, :confirm => 'Are you sure?', :method => :delete %></td>
<% end %>
  </tr>
<% end %>
</table>

<br />
  <% if permitted_to? :create, StaticArticle.new %>
<%= link_to 'New Article', new_static_article_path %>
<% end %>
ARTICLE_INDEX_VIEW

file 'app/views/static_articles/edit.html.erb', <<-EDIT_ARTICLE_VIEW
<h1>Editing Article</h1>
<%= render :partial => "form" %>


<%= link_to 'Show', @static_article %> |
<%= link_to 'Back', static_articles_path %>
EDIT_ARTICLE_VIEW

file 'app/views/static_articles/new.html.erb', <<-NEW_ARTICLE_VIEW
<h1>New Article</h1>

<%= render :partial  => "form"  %>

<%= link_to 'Back', static_articles_path %>
NEW_ARTICLE_VIEW

file 'app/views/static_articles/_form.html.erb', <<-ARTICLE_PARTIAL
<% form_for(@static_article) do |f| %>
  <%= f.error_messages %>

  <p>
    <%= f.label :title %><br />
    <%= f.text_field :title %>
  </p>
  <p>
    <%= f.label :content %><br />
    <%= f.text_area :content %>
  </p>

  <p>
    <%= f.submit 'Update' %>
  </p>
<% end %>
ARTICLE_PARTIAL

file 'app/models/static_article.rb', <<-ARTICLE_MODEL
class StaticArticle < ActiveRecord::Base
  belongs_to :user
end
ARTICLE_MODEL

#comitting Test Facility to repository
git :add  => '.'
git :commit  => "-a -m 'Build simple application from template' "

rake "db:migrate"
rake "db:seed"

puts "###############################################"
puts "##                                           ##"
puts "##              S U C C E S S !              ##"
puts "##                                           ##"
puts "###############################################"





