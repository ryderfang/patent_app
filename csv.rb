# csv.rb
# dealing with csv import & export
post '/download/:filename' do |filename|
  @patents = Patent.all

  CSV.open("./download/#{filename}.csv", "wb", :headers => true) do |csv|
    csv << ["employee_id", "employee_name", "bu", "total_us", "total_other"]
    @patents.each do |patent|
      csv << ["#{patent.employee_id}", "#{patent.employee_name}", \
        "#{patent.bu}", "#{patent.total_us}", "#{patent.total_others}"]
    end
  end

  send_file "./download/#{filename}.csv", :filename => "PatentHistoricalData_v2.csv", :type => 'Application/octet-stream'
end

post '/upload' do
  im_log = File.open("./download/web_log.txt", "wb")

  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
    @lbl_csv = "File not exist."
    im_log.print(@lbl_csv)
    im_log.close
    return erb(:csv, :layout => false)
  end
  
  unless File.extname(name) == ".csv"
    @lbl_csv = "It's not a csv file."
    im_log.print(@lbl_csv)
    im_log.close
    return erb(:csv, :layout => false)
  end
  
  while blk = tmpfile.read(65536)
    File.open("./upload/up_file.csv", "wb") { |f| f.write(blk) }
  end
  
  patent = Hash.new
  
  CSV.foreach("./upload/up_file.csv", :headers => true) do |row|
    #p row
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
    elsif ['EUC', 'MBU', 'NSBU', 'Platform', 'Product Engineering', 'SAS'].include? (row[2])
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

  @lbl_csv = "Import is complete."

  return erb(:csv, :layout => false)
end
