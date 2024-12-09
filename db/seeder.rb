require 'sqlite3'
require 'bcrypt'

class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todos')
    db.execute('DROP TABLE IF EXISTS users')
  end

  def self.create_tables
    db.execute('CREATE TABLE todos (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  todos TEXT NOT NULL,
                  impScale INTEGER NOT NULL,
                  description TEXT NOT NULL
                )')

    db.execute('CREATE TABLE users (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  username TEXT UNIQUE NOT NULL,
                  password TEXT NOT NULL
                )')
  end

  def self.populate_tables
    # Lägg till Todo-uppgifter
    db.execute('INSERT INTO todos (todos, impScale, description) VALUES (?, ?, ?)', 
               ["Äta mat", 1, "Måste äta mat för att må bra"])
    db.execute('INSERT INTO todos (todos, impScale, description) VALUES (?, ?, ?)', 
               ["Träna", 3, "Gå till gymmet och träna"])
    db.execute('INSERT INTO todos (todos, impScale, description) VALUES (?, ?, ?)', 
               ["Handla mat", 2, "Gå till affären och handla"])

    # Lägg till en standardanvändare
    password_hashed = BCrypt::Password.create("189")
    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', 
               ["eirik", password_hashed])
  end

  private

  def self.db
    @db ||= SQLite3::Database.new('db/todos.sqlite').tap do |db|
      db.results_as_hash = true
    end
  end
end

Seeder.seed!
