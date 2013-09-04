# main.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'csv'
require 'dm-core'
require 'dm-migrations'
require 'net/ldap'
require 'sinatra/flash'

require './csv.rb'

require File.dirname(__FILE__) + '/lib/user_auth'

set :server, 'thin' 
#set :bind, '10.110.162.177'
set :bind, '202.120.87.195'
set :port, '4567'
set :root, File.dirname(__FILE__)

enable :sessions
set :session_secret, "My session secret"

#puts "This is process #{Process.pid}"
set :admin_grp, ["ffeng", "slu", "hus", "chenh", "aren", "yisuih" \
  "lbai", "bowang", "wshao", "yzhao", "tzhou", "haoh", "shenj", "cdan" \
  "jying", "rfang"] # patent_committee
set :guest_grp, ["ssqian", "linali", "vzheng", "rfang", "bqiao"] # patent_group

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

# before '/*' do
#     url = params[:splat].first

#     #puts url
#     unless url == "login"
#       if !session[:username]
#         session[:request_path] = request.path
#         #flash[:error] = "You are required to log in before you can proceed"
#         redirect '/login'
#       elsif session[:request_path] && session[:username]
#         path = session[:request_path]
#         session[:request_path] = nil
#         redirect path unless path == '/favicon.ico'
#       end

#       case session[:user_level]
#         when "guest"
#           redirect '/redir' unless ["redir", "logout", "", "csv", "download/out_file"].include? url
#         when "ban"
#           session[:username] = nil
#           session[:user_level] = nil
#           redirect '/login'
#       end
#     end
# end

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
  erb :edit, :layout => false
end

get '/login' do
  erb :login, :layout => false
end

post '/login' do
  user = params[:username]
  pass = params[:passwd]

  commonName = UserAuth.authenticate(user, pass)
  if commonName
    session[:username] = commonName.first
    session[:user_level] = "ban"
    session[:user_level] = "guest" if settings.guest_grp.include? user
    session[:user_level] = "admin" if settings.admin_grp.include? user

    case session[:user_level]
      when "admin", "guest"
        redirect '/'
      else
        return erb(:login, :layout => false)
    end
  else
    @lbl_pass = "Wrong Pass."
    return erb(:login, :layout => false)
  end
end

get '/logout' do
  session[:username] = nil
  session[:user_level] = nil
  redirect '/login'
end

get '/logs' do
  erb :log, :layout => false
end

get '/redir' do
  erb :jump, :layout => false
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
