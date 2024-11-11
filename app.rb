require 'sinatra'
require 'sqlite3'

class App < Sinatra::Base
  def db_connection
    db = SQLite3::Database.new 'db/Todo.sqlite'
    db.results_as_hash = true
    db
  end

  # Visa alla uppgifter
  get '/' do
    db = db_connection
    @Todo = db.execute("SELECT * FROM Todo ORDER BY impScale ASC")
    erb :index
  end

  # Form för att skapa en ny uppgift
  get '/thing/new' do
    erb :new
  end

  # Skapa en ny uppgift i databasen
  post '/thing' do
    db = db_connection
    db.execute("INSERT INTO Todo (thing, impScale, description) VALUES (?, ?, ?)", 
    [params[:thing], params[:impScale], params[:description]])
    redirect '/'
  end

  # Visa en uppgift för redigering
  get '/thing/:id/edit' do
    db = db_connection
    @thing = db.execute("SELECT * FROM Todo WHERE id = ?", params[:id]).first
    erb :edit
  end

  # Uppdatera en uppgift
  post '/thing/:id' do
    db = db_connection
    db.execute("UPDATE Todo SET thing = ?, impScale = ?, description = ? WHERE id = ?", 
    [params[:thing], params[:impScale], params[:description]])
    redirect '/'
  end

  # Ta bort en uppgift
  post '/thing/:id/delete' do
    db = db_connection
    db.execute("DELETE FROM Todo WHERE id = ?", params[:id])
    redirect '/'
  end
end
