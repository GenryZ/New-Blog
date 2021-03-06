#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
	@db = SQLite3::Database.new 'blog.db'
	@db.results_as_hash = true
end

before do 
	init_db
end

configure do 
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts 
(
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content      TEXT,
    author		TEXT
)'
	@db.execute 'CREATE TABLE IF NOT EXISTS Comments 
(
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    created_date DATE,
    content      TEXT,
    post_id		INTEGER
)'

end

get '/' do
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
end

get '/new' do 
	erb :new
end

post '/new' do
	author = params[:author]
	if author == ''
		@error = "Enter author"
		return erb :new
	end
  	content = params[:content]
  	if content.length <= 0 
  		@error = "Type post text"
  		return erb :new
  	end
  	@db.execute 'insert into Posts (content, created_date, author) values (?, datetime(), ?)', [content, author]
  	
#Redirect on main paig 
	redirect to '/'
end
get '/details/:post_id' do 
	#Получаем переменною из url
	post_id = params[:post_id]
	#Получаем список постов
	#(у нас будет тллько один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	#Выбираем один пост в переменную row
	@row = results[0] #choise one first element array results first row (strochka)
	
	#Выбираем комментарии
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	#Возвращаем представление 
	erb :details
end

#Обработчик пост-запроса details
post '/details/:post_id' do 
	post_id = params[:post_id]
	content = params[:content]
	if content.length <= 0
		@error = 'Type some comments'
		return erb :back
	end
	@db.execute 'insert into Comments 
	(
		content,
		created_date,
		 post_id
	 ) 
	values 

	(?, datetime(), ?)', [content, post_id]

	redirect to ('/details/' + post_id)
end

