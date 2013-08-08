# myapp.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'haml' # gem install haml
require 'sinatra/activerecord'
require 'dm-core'
require 'dm-migrations'

set :server, 'webrick' 
set :bind, '10.110.162.177'
set :port, '4567'

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
  @patents = Patent.all
	erb :index
end

post '/' do
  @emp_id = params[:txt_id]
  @emp_nm = params[:txt_nm]
  @emp_id.strip
  @emp_nm.strip
  
  puts @emp_id
  puts @emp_nm
  
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

put '/' do
  puts "#{params[:btn_us]}"
  @us_tag = "#{ params[:btn_us] }"
  if @us_tag == "DESC"
    @patents = Patent.all(:order => [:total_us.desc])
    @us_tag = "ASC"
  else
    @patents = Patent.all(:order => [:total_us.asc])
    @us_tag = "DESC"
  end
    
  erb :index
end

get '/ip' do
    "Your IP address is #{ @env['REMOTE_ADDR'] } "
end

not_found do
  status 404
  "sorry, page not found -- by rfang@vmware.com"
end
