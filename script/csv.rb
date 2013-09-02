#! /usr/bin/env ruby
require 'csv'
require 'dm-core'
require 'dm-migrations'

=begin
ARGV.each do |a|
  puts "Argument: #{a}"
end
=end

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

#p Patent.get("001")
csv_file = ARGV[0]
im_log = File.open("im_log.txt", "wb")

unless File.extname(csv_file) == ".csv"
  im_log.puts("It's not a csv file.")
  exit 0
end

CSV.foreach(csv_file, :headers => true) do |row|
  if row.length != 5
    im_log.print("Line length:#{row.length}, [Length incorrect!], Failed.\n")
    next
  end
  
  im_log.print("employee_id:")
  if row[0].nil?
    im_log.print("[Nil!], Failed.\n")
    next
  elsif
    im_log.print("#{row[0]}, ")
  end
  
  im_log.print("employee_name:")
  if row[1].nil?
    im_log.print("[Nil!], Failed.\n")
    next
  elsif
    im_log.print("#{row[1]}, ")
  end
  
  im_log.print("bu:")
  if row[2].nil?
    im_log.print("[Nil!], Failed.\n")
    next
  elsif ['EUC', 'NSBU', 'Platform', 'Product Engineering', 'SAS'].include? (row[2])
    im_log.print("#{row[2]}, ")
  else
    im_log.print("#{row[2]}[Incorrect BU!], Failed.\n")
    next
  end
  
  im_log.print("total_us:")
  if row[3].nil?
    im_log.print("[Nil!], Failed\n")
    next
  elsif row[3].to_i.to_s != row[3]
    im_log.print("#{row[3]}[Not Integer!], Failed.\n")
    next
  else
    im_log.print("#{row[3]}, ")
  end
  
  im_log.print("total_others:")
  if row[4].nil?
    im_log.print("[Nil!], Failed.\n")
    next
  elsif row[4].to_i.to_s != row[4]
    im_log.print("#{row[4]}[Not Integer!], Failed.\n")
    next
  else
    im_log.print("#{row[4]}, ")
  end
  
  patent = Hash.new
  patent[:employee_id] = row[0]
  patent[:employee_name] = row[1]
  patent[:bu] = row[2]
  patent[:total_us] = row[3]
  patent[:total_others] = row[4]
  
  Patent.first_or_create({:employee_id => row[0]}, {:employee_name => row[1], :bu => row[2], \
    :total_us => row[3], :total_others => row[4]}).update(patent)
  
  im_log.print("Success!\n")
end

im_log.close