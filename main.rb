# main.rb
require 'rubygems'
require 'sinatra'
require 'rack'
require 'sinatra/reloader' if development? # gem install sinatra-reloader
require 'haml' # gem install haml
require 'csv'
require 'dm-core'
require 'dm-migrations'

set :server, 'webrick' 
set :bind, '10.110.162.177'
set :port, '4567'
set :root, File.dirname(__FILE__)

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
  property :bu, String
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
  
  @sel_bu = params[:sel_bu]
  
=begin
  if @emp_id == "" and @emp_nm == ""
    @patents = Patent.all
  elsif @emp_id != "" and @emp_nm == ""
    @patents = Patent.all(:employee_id => @emp_id)
  elsif @emp_id == "" and @emp_nm != ""
    @patents = Patent.all(:employee_name => @emp_nm)
  else
    @patents = Patent.all(:employee_id => @emp_id, :employee_name => @emp_nm)
  end
=end

  cond = Hash.new
  cond[:employee_id] = @emp_id if @emp_id != ""
  cond[:employee_name] = @emp_nm if @emp_nm != ""
  cond[:bu] = @sel_bu if @sel_bu != ""
  
  #puts cond
  
  @patents = Patent.all(cond)
  
  erb :index
end

post '/' do
  us_tag = session[:us_tag]
  
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

post '/download/:filename' do |filename|
=begin
  CSV.foreach("./download/#{filename}.csv", :headers => true) do |row|
    print "Name: #{row['employee_id']} "
    print "Language: #{row['employee_name']} "
    print "URL: #{row['total_us']} "
    print "Total Number of Forks: #{row['total_others']}"
    puts
  end
=end

  @patents = Patent.all
  CSV.open("./download/#{filename}.csv", "wb", :headers => true) do |csv|
    csv << ["employee_id", "employee_name", "bu", "total_us", "total_other"]
    @patents.each do |patent|
      csv << ["#{patent.employee_id}", "#{patent.employee_name}", \
        "#{patent.bu}", "#{patent.total_us}", "#{patent.total_others}"]
    end
  end

  send_file "./download/#{filename}.csv", :filename => filename + ".csv", :type => 'Application/octet-stream'
end

get '/ip' do
    "Your IP address is #{ @env['REMOTE_ADDR'] } "
end

get '/upload' do
  erb :upload, :layout => false
end

post '/upload' do
  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    return erb(:upload)
  end
  
  #File.open('public/' + params[:file][:filename], "w") do |f|
    #f.write(params[:file][:tempfile].read)
  #end
  while blk = tmpfile.read(65536)
    File.open("public/#{name}", "wb") { |f| f.write(blk) }
  end
  'success'
end

not_found do
  status 404
  "sorry, page not found :( -- by rfang(at)vmware.com"
end

get '/about' do
  haml :about
end