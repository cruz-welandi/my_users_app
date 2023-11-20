require 'sinatra'
require 'json'
require './my_user_model'

enable :sessions

user_info1 = {id: 1, firstname: 'hance', lastname: 'hance', age: 30, password: '2145', email: 'hance@example.com'}
user_id1 = User.create(user_info1)

#user_info2 = {firstname: 'Jane', lastname: 'Doe', age: 28, password: 'password456', email: 'jane.doe@example.com'}
#user_id2 = User.create(user_info2)

get '/' do
  send_file 'views/index.html'
end

get '/users' do
  content_type :json
  all_users = User.all
  users_without_passwords = all_users.map do |user|
    {
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      age: user.age,
      email: user.email
    }
  end
  users_without_passwords.to_json
end

post '/users' do


  # Réinitialiser le pointeur de lecture du corps de la requête
  request.body.rewind

  # Analyser le corps de la requête JSON
  begin
    request_payload = Rack::Utils.parse_nested_query(request.body.read)
  rescue JSON::ParserError => e
    # Retourner une réponse 400 Bad Request si le format JSON est invalide
    halt 400, { error: 'Format JSON invalide.' }.to_json
  end

  # Créer un nouvel utilisateur avec les données fournies
  new_user = User.create(
    firstname: request_payload['firstname'],
    lastname: request_payload['lastname'],
    age: request_payload['age'],
    password: request_payload['password'],
    email: request_payload['email']
  )

  # Vérifier si la création de l'utilisateur a réussi
  if new_user
    # Construire la réponse avec les informations de l'utilisateur (sans le mot de passe)
    response_data = {
      id: new_user.id,
      firstname: new_user.firstname,
      lastname: new_user.lastname,
      age: new_user.age,
      email: new_user.email
    }

    # Renvoyer la réponse en format JSON
    response_data.to_json
  else
    # En cas d'échec, retourner une réponse 500 Internal Server Error
    halt 500, { error: 'Erreur lors de la création de l\'utilisateur.' }.to_json
  end
end

=begin
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

put '/users' do
  content_type :json

  # Vérifiez si l'utilisateur est connecté
  if session[:user_id]
    user_info = JSON.parse(request.body.read)
    user = users.find(session[:user_id])

    if user
      # Mettez à jour le mot de passe de l'utilisateur
      user[:password] = user_info["new_password"]

      # Supprimez le mot de passe avant de renvoyer l'utilisateur
      user.delete(:password)

      # Renvoyez l'utilisateur mis à jour
      user.to_json
    else
      status 404
      {error: "User not found"}.to_json
    end
  else
    status 401
    {error: "You must be logged in to perform this action"}.to_json
  end
end


delete '/sign_out' do
  # Vérifiez si l'utilisateur est connecté
  if session[:user_id]
    # Déconnectez l'utilisateur
    session.clear
    # Renvoyez un code de statut HTTP 204 (No Content)
    status 204
  else
    status 401
    {error: "Vous devez être connecté pour effectuer cette action"}.to_json
  end
end


delete '/users' do
  # Vérifiez si l'utilisateur est connecté
  if session[:user_id]
    # Trouvez l'utilisateur actuel
    user = users.find(session[:user_id])
    if user
      # Déconnectez l'utilisateur
      session.clear
      # Supprimez l'utilisateur
      users.delete(user)
      # Renvoyez un code de statut HTTP 204 (No Content)
      status 204
    else
      status 404
      {error: "Utilisateur non trouvé"}.to_json
    end
  else
    status 401
    {error: "Vous devez être connecté pour effectuer cette action"}.to_json
  end
end
=end

set :port, 8080  # Port sur lequel le serveur écoutera   require 'sqlite3'