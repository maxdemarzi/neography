require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  it "can batch a bunch of nodes streaming" do
   class Enumerator
     def next_json
       begin 
         self.next.to_json.to_s
       rescue StopIteration
         return ""
       end
     end
   end
   #Enumerator.class_eval{ alias :call :next}
   Enumerator.class_eval{ alias :call :next_json}
    #module Enumerable
    #  class Enumerator
    #    #alias :call :next
    #    class_eval{ alias :call :next}
    #  end 
    #end

    module Neography
      class Rest
      
      def batch_streaming(*args)
        batch = []
        Array(args).each_with_index do |c,i|
          batch << {:id => i}.merge(get_batch(c))
        end
         options = { :body => batch.to_json, 
                     :headers => {'Content-Type' => 'application/json',
                                  # Seeing connection reset by peer errors
                                  # and timeouts. 
                                   'Accept' => 'application/json;stream=true'
                                  },
                     :write_timeout => 600 } 
         post("/batch", options)
      end

        def batch_not_streaming(*args)
          batch = []
          Array(args).each_with_index do |c,i|
            batch << {:id => i}.merge(get_batch(c))
          end
           options = { :body => batch.to_json, :headers => {'Content-Type' => 'application/json'} } 
           post("/batch", options)
        end

      
        def batch_chunked(*args)
          batch = []
          Array(args).each_with_index do |c,i|
            batch << {:id => i}.merge(get_batch(c))
          end
  
           file = StringIO.new(batch.to_json)
           #file = Tempfile.new('a')
           #file.write(batch.to_json)
           #file.rewind
           chunker = lambda do
             file.read(50000).to_s        
           end
  
           options = { :headers => {'Content-Type' => 'application/json', 
                                    'Accept' => 'application/json;stream=true'}, 
                       :request_block => chunker,
                       :write_timeout => 600              
                     }   
           post("/batch", options)
        end
        
        def batch_chunked2(*args)
          batch = []
          Array(args).each_with_index do |c,i|
            batch << {:id => i}.merge(get_batch(c))
          end
      
           options = { :headers => {'Content-Type' => 'application/json'
                                    }, 
                       :request_block => batch.each_slice(1000),
                       :write_timeout => 600              
                     }  
           post("/batch", options)
        end

        
      end
    end

    commands = 2000.times.collect{|x| [:create_node, {:name => "node-#{x}"}]}
    file = StringIO.new(commands.to_json)
       
      Benchmark.bm do |x|
        x.report("batch               ") { @new_nodes = @neo.batch *commands }
        x.report("batch streaming     ") { @new_nodes = @neo.batch_streaming *commands }
        x.report("batch chunked       ") { @new_nodes_streaming = @neo.batch_chunked *commands }
        x.report("batch chunked 2     ") { @new_nodes_streaming = @neo.batch_chunked2 *commands }
        x.report("batch not streaming ") { @new_nodes_not_streaming = @neo.batch_not_streaming *commands }
      end
      @new_nodes_not_streaming.should_not be_nil
      @new_nodes.should_not be_nil
      @new_nodes_streaming.should_not be_nil
  end
  
end