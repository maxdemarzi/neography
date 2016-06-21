# borrowed from architect4r
require 'os'
require 'zip'
require 'net/http'

namespace :neography do
  namespace :neo4j do
    desc "Install Neo4j"
    task :install, :edition, :version do |t, args|
      args.with_defaults(:edition => "community", :version => "2.3.2")
      puts "Installing Neo4j-#{args[:edition]}-#{args[:version]}"

      if OS::Underlying.windows?
        # Download Neo4j
        unless File.exist?('neo4j.zip')
          df = File.open('neo4j.zip', 'wb')
          begin
            Net::HTTP.start("dist.neo4j.org") do |http|
              http.request_get("/neo4j-#{args[:edition]}-#{args[:version]}-windows.zip") do |resp|
                resp.read_body do |segment|
                  df.write(segment)
                end
              end
            end
          ensure
            df.close()
          end
        end

        # Extract and move to neo4j directory
        unless File.exist?('neo4j')
          Zip::File.open('neo4j.zip') do |zip_file|
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
        %x[curl -O http://dist.neo4j.org/neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
        %x[tar -xvzf neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
        %x[mv neo4j-#{args[:edition]}-#{args[:version]} neo4j]
        %x[rm neo4j-#{args[:edition]}-#{args[:version]}-unix.tar.gz]
        puts "Neo4j Installed in to neo4j directory."
      end
      puts "Type 'rake neo4j:start' to start it"
    end

    desc "Unsecure the Neo4j Server (for testing only)"
    task :unsecure do
      properties_file = "neo4j/conf/neo4j-server.properties"
      text = File.read(properties_file)
      new_contents = text.gsub(/dbms.security.auth_enabled=true/, "dbms.security.auth_enabled=false")
      File.open(properties_file, "w") {|file| file.puts new_contents }
    end

    desc "Start the Neo4j Server"
    task :start do
      puts "Starting Neo4j..."
      if OS::Underlying.windows?
        if %x[reg query "HKU\\S-1-5-19"].size > 0
          value = %x[neo4j/bin/Neo4j.bat start]  #start service
        else
          puts "Starting Neo4j directly, not as a service."
          value = %x[neo4j/bin/Neo4j.bat]
        end
      else
        value = %x[neo4j/bin/neo4j start]
      end
      puts value
    end

    desc "Start the Neo4j Server in the background"
    task :start_no_wait do
      puts "Starting Neo4j in the background..."
      if OS::Underlying.windows?
        if %x[reg query "HKU\\S-1-5-19"].size > 0
          value = %x[neo4j/bin/Neo4j.bat start-no-wait]  #start service
        else
          puts "Starting Neo4j directly, not as a service."
          value = %x[neo4j/bin/Neo4j.bat start-no-wait]
        end
      else
        value = %x[neo4j/bin/neo4j start-no-wait]
      end
      puts value
    end

    desc "Stop the Neo4j Server"
    task :stop do
      puts "Stopping Neo4j..."
      if OS::Underlying.windows?
        if %x[reg query "HKU\\S-1-5-19"].size > 0
          value = %x[neo4j/bin/Neo4j.bat stop]  #stop service
        else
          puts "You do not have administrative rights to stop the Neo4j Service"
        end
      else
        value = %x[neo4j/bin/neo4j stop]
      end
      puts value
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
          FileUtils.rm_rf("neo4j/data/graph.db") if File.exist?("neo4j/data/graph.db")
          FileUtils.mkdir("neo4j/data/graph.db")

          # Remove log files
          FileUtils.rm_rf("neo4j/data/log") if File.exist?("neo4j/data/log")
          FileUtils.mkdir("neo4j/data/log")

          %x[neo4j/bin/Neo4j.bat start]
        else
          puts "You do not have administrative rights to reset the Neo4j Service"
        end
      else
        %x[neo4j/bin/neo4j stop]

        # Reset the database
        FileUtils.rm_rf("neo4j/data/graph.db") if File.exist?("neo4j/data/graph.db")
        FileUtils.mkdir("neo4j/data/graph.db")

        # Remove log files
        FileUtils.rm_rf("neo4j/data/log") if File.exist?("neo4j/data/log")
        FileUtils.mkdir("neo4j/data/log")

        # Start the server
        %x[neo4j/bin/neo4j start]
      end
    end

    task :get_spatial, :version  do |t, args|
      args.with_defaults(:version => "2.2.3")
      puts "Installing Neo4j-Spatial #{args[:version]}"

      unless File.exist?('neo4j-spatial.zip')
        df = File.open('neo4j-spatial.zip', 'wb')
        case args[:version]
        when "2.2.3"
          dist = "https://raw.githubusercontent.com"
          request = "/neo4j-contrib/m2/master/releases/org/neo4j/neo4j-spatial/0.15-neo4j-2.2.3/neo4j-spatial-0.15-neo4j-2.2.3-server-plugin.zip"
        when "2.2.0"
          dist = "https://raw.githubusercontent.com"
          request = "/neo4j-contrib/m2/master/releases/org/neo4j/neo4j-spatial/0.14-neo4j-2.2.0/neo4j-spatial-0.14-neo4j-2.2.0-server-plugin.zip"
        when "2.1.4"
          dist = "m2.neo4j.org"
          request = "/content/repositories/releases/org/neo4j/neo4j-spatial/0.13-neo4j-2.1.4/neo4j-spatial-0.13-neo4j-2.1.4-server-plugin.zip"
        when "2.0.1"
          dist = "m2.neo4j.org"
          request = "/content/repositories/releases/org/neo4j/neo4j-spatial/0.13-neo4j-2.0.1/neo4j-spatial-0.13-neo4j-2.0.1-server-plugin.zip"
        when "2.0.0"
          dist = "dist.neo4j.org"
          request = "/spatial/neo4j-spatial-0.12-neo4j-2.0.0-server-plugin.zip"
        when "1.9"
          dist = "dist.neo4j.org.s3.amazonaws.com"
          request = "/spatial/neo4j-spatial-0.11-neo4j-1.9-server-plugin.zip"
        when "1.8.2"
          dist = "dist.neo4j.org.s3.amazonaws.com"
          request = "/spatial/neo4j-spatial-0.9.1-neo4j-1.8.2-server-plugin.zip"
        else
          abort("I don't know that version of the neo4j spatial plugin")
        end

        begin
          case args[:version] when "2.2.3", "2.2.0"
            df.write(Net::HTTP.get(URI(dist+request)))
          else
            Net::HTTP.start(dist) do |http|
              http.request_get(request) do |resp|
                resp.read_body do |segment|
                  df.write(segment)
                end
              end
            end
          end
        ensure
          df.close()
        end
      end

      # Extract to neo4j plugins directory
      Zip::File.open('neo4j-spatial.zip') do |zip_file|
        zip_file.each do |f|
          f_path=File.join("neo4j/plugins/", f.name)
          FileUtils.mkdir_p(File.dirname(f_path))
          begin
            zip_file.extract(f, f_path) unless File.exist?(f_path)
          rescue
            puts f.name + " failed to extract."
          end
        end
      end

    end
  end
end
