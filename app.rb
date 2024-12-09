require 'sinatra'
require 'sqlite3'
require 'bcrypt'

class App < Sinatra::Base
  def db_connection
    db = SQLite3::Database.new 'db/todos.sqlite'
    db.results_as_hash = true
    db
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  get '/' do
    if session[:user_id]
      erb(:"admin/index")
    else
      erb :index
    end
  end

  get '/signup' do
    erb :newuser 
  end


  post '/signup' do
    username = params[:username]
    plain_password = params[:password]
    password_hashed = BCrypt::Password.create(plain_password)
    db = db_connection
    db.execute("INSERT INTO users (username, password) VALUES (?, ?)", [username, password_hashed])
    redirect '/' 
  end

  post '/testpwcreate' do
    plain_password = params[:plainpassword]
    password_hashed = BCrypt::Password.create(plain_password)
    p password_hashed
  end

  get '/admin' do
    if session[:user_id]
      erb(:"admin/index")
    else
      status 401
      redirect '/unauthorized'
    end
  end

  get '/unauthorized' do
    erb(:unauthorized)
  end

  post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]

    # Använd db_connection för att ansluta till databasen
    db = db_connection

    user = db.execute("SELECT * FROM users WHERE username = ?", request_username).first

    unless user
      status 401
      redirect '/unauthorized'
    end

    db_id = user["id"].to_i
    db_password_hashed = user["password"].to_s

    # Skapa ett BCrypt-objekt från det hasade lösenordet från db
    bcrypt_db_password = BCrypt::Password.new(db_password_hashed)

    # Kontrollera om plaintext-lösenordet matchar det hasade lösenordet
    if bcrypt_db_password == request_plain_password
      session[:user_id] = db_id
      redirect '/todos'
    else
      status 401
      redirect '/unauthorized'
    end
  end

  # Hantera utloggning
  get '/logout' do
    session.clear
    redirect '/'
  end

  # Visa alla uppgifter
  get '/todos' do
    db = db_connection
    @todos = db.execute("SELECT * FROM todos ORDER BY impScale ASC")
    erb(:"admin/index")
  end

  # Form för att skapa en ny uppgift
  get '/todos/new' do
    erb :new
  end

  # Skapa en ny uppgift i databasen
  post '/todos' do
    db = db_connection
    db.execute("INSERT INTO todos (todos, impScale, description) VALUES (?, ?, ?)", 
    [params[:todos], params[:impScale], params[:description]])
    redirect '/todos'
  end


  # Visa en uppgift för redigering
  get '/todos/:id/edit' do
    db = db_connection
    @todos = db.execute("SELECT * FROM todos WHERE id = ?", params[:id]).first
    erb :edit
  end

  # Uppdatera en uppgift
  post '/todos/:id' do
    db = db_connection
    puts "Received params: #{params.inspect}" 
    db.execute("UPDATE todos SET todos = ?, impScale = ?, description = ? WHERE id = ?", 
    [params[:todos], params[:impScale], params[:description], params[:id]])
    redirect '/todos'
  end

  # Ta bort en uppgift
  post '/todos/:id/delete' do
    db = db_connection
    db.execute("DELETE FROM todos WHERE id = ?", params[:id])
    redirect '/todos'
  end
end

