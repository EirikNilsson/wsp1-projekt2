require 'sqlite3'

class Seeder
  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS Todo')
  end

  def self.create_tables
    db.execute('CREATE TABLE Todo (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  thing TEXT NOT NULL,
                  impScale INTEGER,
                  description TEXT
                )')
  end

  def self.populate_tables
    db.execute('INSERT INTO Todo (thing, impScale, description) VALUES (?, ?, ?)', "Äta mat", 1, "Måste äta mat för att må bra")
  end

  private

  def self.db
    @db ||= SQLite3::Database.new('db/Todo.sqlite').tap do |db|
      db.results_as_hash = true
    end
  end
end

Seeder.seed!
