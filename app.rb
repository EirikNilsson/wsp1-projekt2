require 'sinatra'
require 'sqlite3'
require 'bcrypt'

class App < Sinatra::Base
  def db_connection
    db = SQLite3::Database.new 'db/todo.sqlite'
    db.results_as_hash = true
    db
  end

  configure do
    enable :sessions
    set :session_secret, SecureRandom.hex(64)
  end

  # Startsida
  get '/' do
    if session[:user_id]
      erb(:"admin/index")
    else
      erb :index
    end
  end

  # Skapa en hashsumma för ett lösenord (för testning)
  post '/testpwcreate' do
    plain_password = params[:plainpassword]
    password_hashed = BCrypt::Password.create(plain_password)
    p password_hashed
  end

  # Admin-sida
  get '/admin' do
    if session[:user_id]
      erb(:"admin/index")
    else
      p "/admin : Access denied."
      status 401
      redirect '/unauthorized'
    end
  end

  # Sidan för obehöriga
  get '/unauthorized' do
    erb(:unauthorized)
  end

  # Hantera inloggning
  post '/login' do
    request_username = params[:username]
    request_plain_password = params[:password]

    # Använd db_connection för att ansluta till databasen
    db = db_connection

    user = db.execute("SELECT * FROM users WHERE username = ?", request_username).first

    unless user
      p "/login : Invalid username."
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
      redirect '/todo'
    else
      p "/login : Invalid password."
      status 401
      redirect '/unauthorized'
    end
  end

  # Hantera utloggning
  get '/logout' do
    p "/logout : Logging out"
    session.clear
    redirect '/'
  end

  # Visa alla uppgifter
  get '/todo' do
    db = db_connection
    @todo = db.execute("SELECT * FROM todo ORDER BY impScale ASC")
    erb(:"admin/index")
  end

  # Form för att skapa en ny uppgift
  get '/thing/new' do
    erb :new
  end

  # Skapa en ny uppgift i databasen
  post '/thing' do
    db = db_connection
    db.execute("INSERT INTO todo (thing, impScale, description) VALUES (?, ?, ?)", 
    [params[:thing], params[:impScale], params[:description]])
    redirect '/todo'
  end

  # Visa en uppgift för redigering
  get '/thing/:id/edit' do
    db = db_connection
    @thing = db.execute("SELECT * FROM todo WHERE id = ?", params[:id]).first
    erb :edit
  end

  # Uppdatera en uppgift
  post '/thing/:id' do
    db = db_connection
    puts "Received params: #{params.inspect}" 
    db.execute("UPDATE todo SET thing = ?, impScale = ?, description = ? WHERE id = ?", 
    [params[:thing], params[:impScale], params[:description], params[:id]])
    redirect '/todo'
  end

  # Ta bort en uppgift
  post '/thing/:id/delete' do
    db = db_connection
    db.execute("DELETE FROM todo WHERE id = ?", params[:id])
    redirect '/todo'
  end
end
