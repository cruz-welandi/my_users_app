require 'sqlite3'

class User

    def initialize(bd)
        @db = SQLite3::Database.new('db.sql')
        create_table
    end

    def create(user_info)
        sql = 'INSERT INTO users (firstname, lastname, age, password, email) VALUES (?, ?, ?, ?, ?)'
        @db.execute(sql, user_info[:firstname], user_info[:lastname], user_info[:age], user_info[:password], user_info[:email])
        
        last_insert_row_id = @db.last_insert_row_id
        return last_insert_row_id if last_insert_row_id > 0
        return nil
    end

    def find(user_id)
        sql = 'SELECT * FROM users WHERE id = ?'
        user = @db.get_first_row(sql, user_id)
        user ? user_hash(user) : nil
    end

    def all
        sql = 'SELECT * FROM users'
        users = @db.execute(sql)
        users.map { |user| user_hash(user) }
    end

    def update(user_id, attribute, value)
        valid_attributes = %w[first_name last_name age password email]
        unless valid_attributes.include?(attribute)
          return "Invalid attribute"
        end

        sql = "UPDATE users SET #{attribute} = ? WHERE id = ?"
        @db.execute(sql, value, user_id)

        user = find(user_id)
        user ? user : nil
    end

    def destroy(user_id)
        sql = 'DELETE FROM users WHERE id = ?'
        @db.execute(sql, user_id)
    end

    private

    def create_table
        @db.execute <<~SQL
          CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY,
            firstname TEXT,
            lastname TEXT,
            age INTEGER,
            password TEXT,
            email TEXT
          );
        SQL
    end

    def user_hash(user)
        {
          id: user[0],
          firstname: user[1],
          lastname: user[2],
          age: user[3],
          password: user[4],
          email: user[5]
        }
    end

end