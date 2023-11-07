require 'sinatra'
require './my_user_model'

enable :sessions

get '/' do
    @user = {
        firstname: 'John',
        lastname: 'Doe',
        age: 30,
        email: 'john@example.com'
      }
    
      File.read(File.join('views', 'index.html')).gsub(/\{\{(\w+)\}\}/) { @user[$1.to_sym] }
end

user_db = User.new('db.sql')


# Create a new user
new_user_id = user_db.create({
  firstname: 'John',
  lastname: 'Doe',
  age: 30,
  password: 'securepassword',
  email: 'john@example.com'
})


set :port, 8080  # Port sur lequel le serveur écoutera