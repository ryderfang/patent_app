# myapp.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'haml' # gem install haml
require 'sinatra/activerecord'

set :server, 'webrick' 
set :bind, '10.110.162.177'
set :port, '2117'

#puts "This is process #{Process.pid}"

db = URI.parse('postgres://rfang:1007-ecnu@localhost/test')

ActiveRecord::Base.establish_connection(
    :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
    :host     => db.host,
    :username => db.user,
    :password => db.password,
    :database => db.path[1..-1],
    :encoding => 'utf8'
)

class Note < ActiveRecord::Base
end


get '/' do
	erb :index
end

post '/' do
    redirect '/result'
end

get '/result' do
    erb :result
end

get '/all' do
    erb :all
end

get '/about' do
    haml :about
end

get '/ip' do
    "Your IP address is #{ @env['REMOTE_ADDR'] } "
    "Request ip is #{ request.ip }"
end

not_found do
#status 404
#"sorry, page not found --------- by rfang@vmware.com"
	halt 404, 'page not found'
end
