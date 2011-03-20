require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class User
  include Neography::Graph

  def initialize(id, name)
    @id = id
    @name = name
  end

  def id 
    @id
  end
  def name
    @name
  end

  def save
    #does nothing
  end
end

describe Neography::Graph do
  it "should save a node along with the main model" do 
    user = User.new(150, "Max")
    user.save
    user.graph.should_not eql nil
    p user.graph.id
    user.graph.type.should eql "User"
  end
  
end
