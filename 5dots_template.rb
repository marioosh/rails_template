#5dots rails template

#initialize git repository
git :init

#adding .gitignore files to /tmp and /log folders, to prevent adding files from
#that folder to repository
run "touch tmp/.gitignore"
run "touch log/.gitignore"

#making .gitignore file in RAILS_ROOT
file '.gitignore', <<-GITIGNORE_FILE
.DS_Store
log/*.log
tmp/**/*
db/*.sqlite3
doc/app
doc/api
.idea/
GITIGNORE_FILE

#adding all files to repository
git :add  => "."

#first commit to save changes

git :commit   => "-a -m 'Initial commit' "