# main.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'csv'
require 'dm-core'
require 'dm-migrations'
require 'net/ldap'

require './csv.rb'

set :server, 'webrick' 
set :bind, '10.110.162.177'
set :port, '4567'
set :root, File.dirname(__FILE__)

ADMIN_PWD = 'Lovechina!'

enable :sessions
set :session_secret, "My session secret"

#puts "This is process #{Process.pid}"

DataMapper.setup(:default, 'postgres://rfang:postgres@localhost/test')

# define model
class Patent
  include DataMapper::Resource
  
  storage_names[:default] = "patent"
  
  property :employee_id, String, :key => true
  property :employee_name, String
  property :bu, String
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
  
  @sel_bu = params[:sel_bu]

  cond = Hash.new
  cond[:employee_id] = @emp_id if @emp_id != ""
  cond[:employee_name] = @emp_nm if @emp_nm != ""
  cond[:bu] = @sel_bu if @sel_bu != ""
  
  @patents = Patent.all(cond)
  
  erb :index
end

get '/csv' do
  erb :csv, :layout => false
end

get '/new' do
  @patent = Patent.new
  erb :new, :layout => false
end

post '/new' do
  #patent = Patent.create(:employee_id => params[:patent][:employee_id], :employee_name => params[:patent][:employee_name], \
    #:total_us => params[:patent][:total_us], :total_others => params[:patent][:total_others])
  patent = Patent.create(params[:patent])
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

get '/ldap' do
  ldap = Net::LDAP.new
  ldap.host = 'ldap1-pek2.eng.vmware.com'
  ldap.port = 389
  ldap.auth "cn=rfang,dc=vmware,dc=com", "#{ADMIN_PWD}"
  puts ldap.bind
  if ldap.bind
    'success'
  else
    'failed'
  end
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