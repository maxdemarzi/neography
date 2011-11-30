# borrowed from architect4r
require 'os'

namespace :neo4j do
  desc "Install Neo4j"
  task :install, :edition, :version do |t, args|
    args.with_defaults(:edition => "community", :version => "1.6.M01")
    puts "Installing Neo4j-#{args[:edition]}-#{args[:version]}"
    
    if OS::Underlying.windows?
      # Download Neo4j    
      unless File.exist?('neo4j.zip')
        df = File.open('neo4j.zip', 'wb')
        begin
          df << HTTParty.get("http://dist.neo4j.org/neo4j-#{args[:edition]}-#{args[:version]}-windows.zip")
        ensure
          df.close()
        end
      end

      # Extract and move to neo4j directory
      unless File.exist?('neo4j')
        Zip::ZipFile.open('neo4j.zip') do |zip_file|
          zip_file.each do |f|
           f_path=File.join(".", f.name)
           FileUtils.mkdir_p(File.dirname(f_path))
           begin
             zip_file.extract(f, f_path) unless File.exist?(f_path)
           rescue
             puts f.name + " failed to extract."
           end
          end
        end
        FileUtils.mv "neo4j-#{args[:edition]}-#{args[:version]}", "neo4j"
     end

      # Install if running with Admin Privileges
      if %x[reg query "HKU\\S-1-5-19"].size > 0 
        %x[neo4j/bin/neo4j install]
        puts "Neo4j Installed as a service."
      end

    else    
      %x[wget http://dist.neo4j.org/neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
      %x[tar -xvzf neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
      %x[mv neo4j-#{args[:edition]}-#{args[:version]} neo4j]
      %x[rm neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
      puts "Neo4j Installed in to neo4j directory."
    end
    puts "Type 'rake neo4j:start' to start it"
  end
  
  desc "Start the Neo4j Server"
  task :start do
    puts "Starting Neo4j..."
    if OS::Underlying.windows? 
      if %x[reg query "HKU\\S-1-5-19"].size > 0 
        %x[neo4j/bin/Neo4j.bat start]  #start service
      else
        puts "Starting Neo4j directly, not as a service."
        %x[neo4j/bin/Neo4j.bat]
      end      
    else
      %x[neo4j/bin/neo4j start]  
    end
  end
  
  desc "Stop the Neo4j Server"
  task :stop do
    puts "Stopping Neo4j..."
    if OS::Underlying.windows? 
      if %x[reg query "HKU\\S-1-5-19"].size > 0
         %x[neo4j/bin/Neo4j.bat stop]  #stop service
      else
        puts "You do not have administrative rights to stop the Neo4j Service"   
      end
    else  
      %x[neo4j/bin/neo4j stop]
    end
  end

  desc "Restart the Neo4j Server"
  task :restart do
    puts "Restarting Neo4j..."
    if OS::Underlying.windows? 
      if %x[reg query "HKU\\S-1-5-19"].size > 0
         %x[neo4j/bin/Neo4j.bat restart] 
      else
        puts "You do not have administrative rights to restart the Neo4j Service"   
      end
    else  
      %x[neo4j/bin/neo4j restart]
    end
  end

  desc "Reset the Neo4j Server"
  task :reset_yes_i_am_sure do
    # Stop the server
    if OS::Underlying.windows? 
      if %x[reg query "HKU\\S-1-5-19"].size > 0
         %x[neo4j/bin/Neo4j.bat stop]
         
        # Reset the database
        FileUtils.rm_rf("neo4j/data/graph.db")
        FileUtils.mkdir("neo4j/data/graph.db")
        
        # Remove log files
        FileUtils.rm_rf("neo4j/data/log")
        FileUtils.mkdir("neo4j/data/log")

        %x[neo4j/bin/Neo4j.bat start]
      else
        puts "You do not have administrative rights to reset the Neo4j Service"   
      end
    else  
      %x[neo4j/bin/neo4j stop]
      
      # Reset the database
      FileUtils.rm_rf("neo4j/data/graph.db")
      FileUtils.mkdir("neo4j/data/graph.db")
      
      # Remove log files
      FileUtils.rm_rf("neo4j/data/log")
      FileUtils.mkdir("neo4j/data/log")
      
      # Start the server
      %x[neo4j/bin/neo4j start]
    end
  end

end  
