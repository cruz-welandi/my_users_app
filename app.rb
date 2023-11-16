require 'sinatra'
require 'json'
require './my_user_model'

users = User.new('db.sql')
enable :sessions

user_info1 = {firstname: 'hance', lastname: 'hance', age: 30, password: '2145', email: 'hance@example.com'}
user_id1 = users.create(user_info1)

user_info2 = {firstname: 'Jane', lastname: 'Doe', age: 28, password: 'password456', email: 'jane.doe@example.com'}
user_id2 = users.create(user_info2)

get '/users' do
  content_type :json
  all_users = users.all
  all_users.each { |user| user.delete(:password) } # Supprime le mot de passe de chaque utilisateur
  all_users.to_json
end

post '/users' do
    content_type :json
    user_info = JSON.parse(request.body.read)
    user_id = users.create(user_info)
    user = users.find(user_id)
    user.delete(:password) # Supprime le mot de passe avant de renvoyer l'utilisateur
    user.to_json
end

post '/sign_in' do
  content_type :json
  user_info = JSON.parse(request.body.read)
  user = users.find_by_email(user_info["email"])
  if user && user[:password] == user_info["password"]
    session[:user_id] = user[:id] # Crée une session avec l'identifiant de l'utilisateur
    user.delete(:password) # Supprime le mot de passe avant de renvoyer l'utilisateur
    user.to_json
  else
    status 401 # Code d'erreur pour une authentification non réussie
    {error: "Invalid email or password"}.to_json
  end
end

set :port, 8080  # Port sur lequel le serveur écoutera   require 'sqlite3'