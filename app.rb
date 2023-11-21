require 'sinatra'
require 'json'
require './my_user_model'

enable :sessions

user_info1 = {firstname: 'hance', lastname: 'hance', age: 30, password: '2145', email: 'hance@example.com'}
user_id1 = User.create(user_info1)

user_info3 = {firstname: 'hance', lastname: 'hance', age: 20, password: '26645', email: 'hans@example.com'}
user_id3 = User.create(user_info3)


user_info2 = {firstname: 'Jane', lastname: 'Doe', age: 28, password: 'password456', email: 'jane.doe@example.com'}
user_id2 = User.create(user_info2)

user_info4 = { firstname: 'hane', lastname: 'hane', age: 30, password: '2145', email: 'hane@example.com'}
user_id4 = User.create(user_info4)

user_info5 = {firstname: 'hance', lastname: 'hance', age: 30, password: '2145', email: 'hance@example.com'}
user_id5 = User.create(user_info5)

user_info = {firstname: 'jone', lastname: 'Doe', age: 50, password: '2145', email: 'doe@example.com'}
user_id = User.create(user_info)

get '/' do
  users = User.all.first(5)
  html = File.read('views/index.html')
  users_html = ""
  users.each do |user|
    users_html += "<tr>
                <td>#{user.firstname}</td>
                <td>#{user.lastname}</td>
                <td>#{user.age}</td>
                <td>#{user.email}</td>
            </tr>"
  end
  html.sub!('<tr>
                    <td>XXXX</td>
                    <td>XXXX</td>
                    <td>XXXX</td>
                    <td>XXXX</td>
                </tr>', users_html)
  html
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
    age: request_payload['age'].to_i,
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

post '/sign_in' do

  request.body.rewind
  body = request.body.read

  if body.empty?
    halt 400, { error: 'Request body is empty.' }.to_json
  end

  begin
    data = JSON.parse(body)
  rescue JSON::ParserError
    halt 401, { error: 'Request body is not valid JSON.' }.to_json
  end

  user = User.find_by(email: data['email'])

  if user && user.authenticate(data['password'])
    session[:user_id] = user.id

    {
      id: user.id,
      firstname: user.firstname,
      lastname: user.lastname,
      age: user.age,
      email: user.email
    }.to_json
  else
      halt 401, { error: 'Invalid credentials.' }.to_json
  end
end

put '/users' do
  # Vérifiez si l'utilisateur est connecté
  if session[:user_id].nil?
    halt 401, { error: 'You must be logged in to perform this action.' }.to_json
  end

  request.body.rewind
  body = request.body.read

  if body.empty?
    halt 400, { error: 'Request body is empty.' }.to_json
  end

  begin
    data = JSON.parse(body)
  rescue JSON::ParserError
    halt 401, { error: 'Request body is not valid JSON.' }.to_json
  end

  user = User.find(session[:user_id])

  if user.nil?
    halt 404, { error: 'User not found.' }.to_json
  else
    user.password = data['new_password']
    if user.save
      {
        id: user.id,
        firstname: user.firstname,
        lastname: user.lastname,
        age: user.age,
        email: user.email
      }.to_json
    else
      halt 500, { error: 'An error occurred while updating the password.' }.to_json
    end
  end
end

delete '/sign_out' do
  # Vérifiez si l'utilisateur est connecté
  if session[:user_id].nil?
    halt 401, { error: 'You must be logged in to perform this action.' }.to_json
  end

  # Déconnectez l'utilisateur
  session.clear

  # Retournez un code de statut HTTP 204
  status 204
end

delete '/users' do
  # Vérifiez si l'utilisateur est connecté
  if session[:user_id].nil?
    halt 401, { error: 'You must be logged in to perform this action.' }.to_json
  end

  # Trouvez l'utilisateur actuel
  user = User.find(session[:user_id])

  if user.nil?
    halt 404, { error: 'User not found.' }.to_json
  else
    # Détruisez l'utilisateur
    user.destroy

    # Déconnectez l'utilisateur
    session.clear

    # Retournez un code de statut HTTP 204
    status 204
  end
end


set :port, 8080  # Port sur lequel le serveur écoutera   require 'sqlite3'