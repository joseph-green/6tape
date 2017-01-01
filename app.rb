require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/reloader'
require 'sinatra/namespace'
require 'data_mapper'
require 'dm-types'
require 'dm-timestamps'



enable :sessions
DataMapper.setup(:default,"sqlite3://#{Dir.pwd}/6tape.db")

class Tape

	include DataMapper::Resource

	has n, :songs

	property :id, Serial
	property :tape_name, String
	property :tape_description, Text
	property :artist, String
	property :spotify_url, Text
	property :soundcloud_url, Text
	property :release_date, DateTime
	
	

end

class Song

	include DataMapper::Resource

	belongs_to :tape

	property :id, Serial
	property :song_name, Text
	property :track_number, Numeric
	

end

class Admin

	include DataMapper::Resource

	property :id, Serial
	property :username, String
	property :password, String

end

DataMapper.finalize.auto_upgrade!

helpers do 

	def authorize
		halt 401 unless session[:admin]
	end

	def retrieve_tape(id)
		begin
			tape = Tape.get(id.to_i)
			return tape
		rescue ObjectNotFoundError
			redirect to("/?error=Tape+not+found")
		end

	end
end




get '/' do

	#loads all the tapes
	@tapes = Tape.all(:limit => 6,:order => [ :id.desc ]);
	
	#loads the home page
	erb :root

end


get '/new' do

	#checks for admin
	authorize

	#loads the form for creating a new tape
	erb :new_tape

end

post '/new' do

	#checks for admin
	authorize

	#creates the Tape object
	@tape = Tape.new(
		:tape_name => params[:tape_name],
		:tape_description => params[:tape_description],
		:artist => params[:artist],
		:spotify_url => params[:spotify_url],
		:soundcloud_url => params[:soundcloud_url],
		:release_date => Date.new(params[:release_year].to_i,params[:release_month].to_i,params[:release_day].to_i)
		)

	#iterates through each song, creates a Song object, and adds it to Tape object
	params[:songs].each_with_index do |song,i|
		@song = Song.new(
			:song_name => song,
			:track_number => (i + 1),
			:tape => @tape
			)
		@tape.songs << @song
	end

	#saves Tape object; redirects to home page
	if @tape.save
		redirect to("/")
	else
		redirect to("/new?error=Did+not+save")
	end

end

get "/:id" do |id|

	#retrieve Tape from database
	@tape = retrieve_tape(id)

	#load the page
	erb :play

end

get "/:id/edit" do |id|

	#checks for admin
	authorize

	#retrieve Tape from database
	@tape = retrieve_tape(id)

	#loads form for updating
	erb :edit_tape

end

post "/:id/edit" do |id|

	#checks for admin
	authorize

	#retrieve Tape from database
	@tape = retrieve_tape(id)

	

	
	#get rid of old songs (cause DataMapper)
	@tape.songs.each do |song|
		song.destroy
	end
	#adds new songs
	params[:songs].each_with_index do |song,i|

			@newsong = Song.new(
			:song_name => song,
			:track_number => (i+1),
			:tape => @tape
			)
			@tape.songs << @newsong

	end
	@tape.save


	

	@tape = retrieve_tape(id)
	
	#updates tape info

	if @tape.update(
		:tape_name => params['tape_name'],
		:tape_description => params['tape_description'],
		:soundcloud_url => params['soundcloud_url'],
		:spotify_url => params['spotify_url'],
		:artist => params['artist'],
		:release_date => Date.new(params['release_year'].to_i,params['release_month'].to_i,params['release_day'].to_i),
		)
		#redirects to home
		
		redirect to("/")

	else
		#redirects to update page
		redirect to("/#{id}/edit?error=Could+not+update")
	end




	

	
	

	


end

get "/:id/delete" do |id|

	#checks for admin
	authorize

	#retrieve Tape from database
	@tape = retrieve_tape(id)

	#loads verification page
	erb :delete_tape

end

post "/:id/delete" do |id|

	#checks for admin
	authorize

	#retrieve Tape from database
	@tape = retrieve_tape(id)

	#destroy each song first
	@tape.songs.each do |song|
		song.destroy
	end

	#destroy the tape
	if @tape.destroy
		#redirect to home
		redirect to("/")
	else
		redirect to("#{id}/delete?error=Could+not+delete")
	end
end




#ADMIN
namespace '/admin' do

	get '/login' do

		#loads the login page
		erb :login


	end

	post '/login' do

		#trys to find the username in the Admin database
		begin
			@admin = Admin.all(:username => params['username'])[0]
		#if the credentials are not found, return to login page
		rescue
			redirect to('/login?error=Username+not+valid')
		end

		#if the password doesn't match the one in the database, return to login page
		redirect to('/login?error=Incorrect+password') unless @admin.password == params['password']

		#set the admin session variable to true (admin privileges)
		session[:admin] = true

		#redirect to home
		redirect to('/')

	end

	get '/new' do
		#checks admin
		authorize

		#loads the form for creating a new admin
		erb :new_admin

	end

	post '/new' do

		#checks admin
		authorize
		
		#creates a new Admin object and saves
		@admin = Admin.new(
			:username => params['username'],
			:password => params['password'])
		@admin.save

		#redirects to home
		redirect to('/')
	end
end

