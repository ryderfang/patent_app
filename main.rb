# main.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'haml' # gem install haml
require 'dm-core'
require 'dm-migrations'

set :server, 'webrick' 
set :bind, '10.110.162.177'
set :port, '4567'

enable :sessions
set :session_secret, "My session secret"

#puts "This is process #{Process.pid}"

DataMapper.setup(:default, 'postgres://rfang:1007-ecnu@localhost/test')

# define model
class Patent
  include DataMapper::Resource
  
  storage_names[:default] = "patent"
  
  property :employee_id, String, :key => true
  property :employee_name, String
  property :total_us, Integer
  property :total_others, Integer
end

DataMapper.finalize


get '/' do
  session[:us_tag] = "DESC"
  session[:oth_tag] = "DESC"
  
  @patents = Patent.all
	erb :index
end

post '/search' do
  @emp_id = params[:txt_id]
  @emp_nm = params[:txt_nm]
  @emp_id.strip
  @emp_nm.strip
  
  if @emp_id == "" and @emp_nm == ""
    @patents = Patent.all
  elsif @emp_id != "" and @emp_nm == ""
    @patents = Patent.all(:employee_id => @emp_id)
  elsif @emp_id == "" and @emp_nm != ""
    @patents = Patent.all(:employee_name => @emp_nm)
  else
    @patents = Patent.all(:employee_id => @emp_id, :employee_name => @emp_nm)
  end
    
  erb :index
end

post '/' do
  us_tag = session[:us_tag]
  puts us_tag
  
  if us_tag == "DESC"
    @patents = Patent.all(:order => [:total_us.desc])
    session[:us_tag] = "ASC"
  elsif us_tag == "ASC"
    @patents = Patent.all(:order => [:total_us.asc])
    session[:us_tag] = "DESC"
  end
  
  erb :index
end

post '/index' do
  oth_tag = session[:oth_tag]
  puts oth_tag
  
  if oth_tag == "DESC"
    @patents = Patent.all(:order => [:total_others.desc])
    session[:oth_tag] = "ASC"
  elsif oth_tag == "ASC"
    @patents = Patent.all(:order => [:total_others.asc])
    session[:oth_tag] = "DESC"
  end
  
  erb :index
end

get '/new' do
  @patent = Patent.new
  erb :new, :layout => false
end

post '/new' do
  patent = Patent.create(:employee_id => params[:patent][:employee_id], :employee_name => params[:patent][:employee_name], \
    :total_us => params[:patent][:total_us], :total_others => params[:patent][:total_others])
  if patent.saved?
    redirect to('/')
  else
    "Insert Data Failed.."
  end
end

get '/patent/:id' do
  @patent = Patent.get(params[:id])
  erb :show, :layout => false
end

put '/patent/:id' do
  patent = Patent.get(params[:id])
  patent.update(params[:patent])
  redirect to("/patent/#{ patent.employee_id }")
end

delete '/patent/:id' do
  Patent.get(params[:id]).destroy
  redirect to('/')
end

get '/patent/:id/edit' do
  @patent = Patent.get(params[:id])
  erb :edit, :layout =>false
end

get '/ip' do
    "Your IP address is #{ @env['REMOTE_ADDR'] } "
end

not_found do
  status 404
  "sorry, page not found :( -- by rfang(at)vmware.com"
end

get '/about' do
  haml :about
end