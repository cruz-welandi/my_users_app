require 'sqlite3'

class User
  attr_accessor :id, :firstname, :lastname, :age, :password, :email

  def initialize(id:, firstname:, lastname:, age:, password:, email:)
    @id = id
    @firstname = firstname
    @lastname = lastname
    @age = age
    @password = password
    @email = email
  end

  def self.create(user_info)
    user_info[:id] ||= nil
    user = new(**user_info)

    db = SQLite3::Database.new 'db.sql'
    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        firstname TEXT,
        lastname TEXT,
        age INTEGER,
        password TEXT,
        email TEXT
      );
    SQL
    db.execute "INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)", [user.firstname, user.lastname, user.age, user.password, user.email]

    # Récupérez l'ID du dernier enregistrement inséré
    user.id = db.last_insert_row_id
    user
  end

  def self.find(id)
    db = SQLite3::Database.new 'db.sql'
    result = db.execute "SELECT * FROM users WHERE id = ?", [id]
    if result.empty?
      nil
    else
      new(id: result[0][0], firstname: result[0][1], lastname: result[0][2], age: result[0][3], password: result[0][4], email: result[0][5])
    end
  end

  def self.all
    db = SQLite3::Database.new 'db.sql'
    results = db.execute "SELECT * FROM users"
    results.map do |row|
      new(id: row[0], firstname: row[1], lastname: row[2], age: row[3], password: row[4], email: row[5])
    end
  end

def self.update(id, attribute, value)
    db = SQLite3::Database.new 'db.sql'
    db.execute "UPDATE users SET #{attribute} = ? WHERE id = ?", [value, id]
end

def self.destroy(id)
    db = SQLite3::Database.new 'db.sql'
    db.execute "DELETE FROM users WHERE id = ?", [id]
end

end