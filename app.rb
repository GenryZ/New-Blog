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
    content      TEXT
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

  	content = params[:content]
  	if content.length <= 0 
  		@error = "Type post text"
  		return erb :new
  	end
  	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
  	
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
	#Возвращаем представление 
	erb :details
end

#Обработчик пост-запроса details
post '/details/:post_id' do 
	post_id = params[:post_id]
	content = params[:content]
	erb "You typed comment #{content} for post #{post_id}"
end

