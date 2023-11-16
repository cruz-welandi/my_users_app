require 'sqlite3'

class User

    def initialize(bd)
        @db = SQLite3::Database.new('db.sql')
        create_table
    end

    def create_table
        @db.execute <<-SQL
          CREATE TABLE IF NOT EXISTS Users(
            id INTEGER PRIMARY KEY,
            firstname TEXT,
            lastname TEXT,
            age INTEGER,
            password TEXT,
            email TEXT
          );
        SQL
    end

    def create_user(firstname, lastname, age, password)
        @db.execute("INSERT INTO Users (firstname, lastname, age, password) VALUES (?, ?, ?, ?)", firstname, lastname, age, password)
    end

    def create(user_info)
        @db.execute("INSERT INTO Users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)", user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
        return @db.last_insert_row_id
    end

    def find(user_id)
        user = @db.get_first_row("SELECT * FROM Users WHERE id = ?", user_id)
        return nil if user.nil?
        {id: user[0], firstname: user[1], lastname: user[2], age: user[3], password: user[4], email: user[5]}
    end

    def all
        users = @db.execute("SELECT * FROM Users")
        users.map do |user|
          {id: user[0], firstname: user[1], lastname: user[2], age: user[3], password: user[4], email: user[5]}
        end
    end

    def update(user_id, attribute, value)
        @db.execute("UPDATE Users SET #{attribute} = ? WHERE id = ?", value, user_id)
        find(user_id)
    end

    def destroy(user_id)
        @db.execute("DELETE FROM Users WHERE id = ?", user_id)
    end

end