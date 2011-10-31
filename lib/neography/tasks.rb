# borrowed from architect4r

namespace :neo4j do
  desc "Install Neo4j"
  task :install do
    puts 'Installing Neo4j...'
    %x[wget http://dist.neo4j.org/neo4j-community-1.5.M02-unix.tar.gz]
    %x[tar -xvzf neo4j-community-1.5.M02-unix.tar.gz]
    %x[mv neo4j-community-1.5.M02 neo4j]
    %x[rm neo4j-community-1.5.M02-unix.tar.gz]
    puts "Neo4j Installed in to neo4j directory." 
    puts "Type 'rake neo4j:start' to start it"
  end
  
  desc "Start the Neo4j Server"
  task :start do
    puts "Starting Neo4j..."
    %x[neo4j/bin/neo4j start]
  end
  
  desc "Stop the Neo4j Server"
  task :stop do
    puts "Stopping Neo4j..."
    %x[neo4j/bin/neo4j stop]
  end

  desc "Restart the Neo4j Server"
  task :restart do
    puts "Restarting Neo4j..."
    %x[neo4j/bin/neo4j restart]
  end

  desc "Reset the Neo4j Server"
  task :reset_yes_i_am_sure do
      # Stop the server
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