require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
  end

  describe "start a transaction" do
    it "can start a transaction" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
    end

    it "can start a transaction with statements" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      tx.should have_key("transaction")
      tx.should have_key("results")
      tx["results"].should_not be_empty
    end

    it "can start a transaction with statements and represent them as a graph" do
      tx = @neo.begin_transaction(["CREATE ( bike:Bike { weight: 10 } ) CREATE ( frontWheel:Wheel { spokes: 3 } ) CREATE ( backWheel:Wheel { spokes: 32 } ) CREATE p1 = bike -[:HAS { position: 1 } ]-> frontWheel CREATE p2 = bike -[:HAS { position: 2 } ]-> backWheel RETURN bike, p1, p2", 
                                 ["row", "graph", "rest"]])
      tx.should have_key("transaction")
      tx.should have_key("results")
      tx["results"].should_not be_empty
      tx["results"].first["data"].first["row"].should_not be_empty
      tx["results"].first["data"].first["graph"].should_not be_empty
      tx["results"].first["data"].first["rest"].should_not be_empty
    end


  end

  describe "keep a transaction" do
    it "can keep a transaction" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      sleep(1)
      existing_tx = @neo.keep_transaction(tx)
      existing_tx.should have_key("transaction")
      existing_tx["transaction"]["expires"].should > tx["transaction"]["expires"]
    end
  end

  
  describe "add to a transaction" do
    it "can add to a transaction" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.in_transaction(tx, "start n=node(0) return n")
      existing_tx.should have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should_not be_empty
    end

    it "can add to a transaction with parameters" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.in_transaction(tx, ["start n=node({id}) return n", {:id => 0}])
      existing_tx.should have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should_not be_empty
    end    

    it "can add to a transaction with representation" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.in_transaction(tx, ["start n=node(0) return n", [:row,:rest]])
      existing_tx.should have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should_not be_empty
    end    

    it "can add to a transaction with parameters and representation" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.in_transaction(tx, ["start n=node({id}) return n", {:id => 0}, [:row,:rest]])
      existing_tx.should have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should_not be_empty
    end    
    
  end

  describe "commit a transaction" do
    it "can commit an opened empty transaction" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.commit_transaction(tx)
      existing_tx.should have_key("results")
      existing_tx["results"].should be_empty
    end

    it "can commit an opened transaction" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      tx.should have_key("transaction")
      tx["results"].should_not be_empty
      existing_tx = @neo.commit_transaction(tx)
      existing_tx.should_not have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should be_empty
    end
    
    it "can commit an opened transaction with new statements" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.commit_transaction(tx, "start n=node(0) return n")
      existing_tx.should_not have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should_not be_empty
    end

    it "can commit an new transaction right away" do
      tx = @neo.commit_transaction(["start n=node(0) return n"])
      tx.should_not have_key("transaction")
      tx.should have_key("results")
      tx["results"].should_not be_empty
    end
    
    it "can commit an new transaction right away with parameters" do
      tx = @neo.commit_transaction(["start n=node({id}) return n", {:id => 0}])
      tx.should_not have_key("transaction")
      tx.should have_key("results")
      tx["results"].should_not be_empty
    end

    it "can commit an new transaction right away without parameters" do
      tx = @neo.commit_transaction("start n=node(0) return n")
      tx.should_not have_key("transaction")
      tx.should have_key("results")
      tx["results"].should_not be_empty
    end
    
  end

  describe "rollback a transaction" do
    it "can rollback an opened empty transaction" do
      tx = @neo.begin_transaction
      tx.should have_key("transaction")
      tx["results"].should be_empty
      existing_tx = @neo.rollback_transaction(tx)
      existing_tx.should have_key("results")
      existing_tx["results"].should be_empty
    end

    it "can rollback an opened transaction" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      tx.should have_key("transaction")
      tx["results"].should_not be_empty
      existing_tx = @neo.rollback_transaction(tx)
      existing_tx.should have_key("transaction")
      existing_tx.should have_key("results")
      existing_tx["results"].should be_empty
    end
  end  
  
end  