require 'spec_helper'

describe Neography::Rest do
  before(:each) do
    @neo = Neography::Rest.new
    node = @neo.create_node
    @node_id = node["self"].split('/').last.to_i

  end

  describe "start a transaction" do
    it "can start a transaction" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
    end

    it "can start a transaction with statements" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      expect(tx).to have_key("transaction")
      expect(tx).to have_key("results")
      expect(tx["results"]).not_to be_empty
    end

    it "can start a transaction with statements and represent them as a graph" do
      tx = @neo.begin_transaction(["CREATE ( bike:Bike { weight: 10 } ) CREATE ( frontWheel:Wheel { spokes: 3 } ) CREATE ( backWheel:Wheel { spokes: 32 } ) CREATE p1 = bike -[:HAS { position: 1 } ]-> frontWheel CREATE p2 = bike -[:HAS { position: 2 } ]-> backWheel RETURN bike, p1, p2", 
                                 ["row", "graph", "rest"]])
      expect(tx).to have_key("transaction")
      expect(tx).to have_key("results")
      expect(tx["results"]).not_to be_empty
      expect(tx["results"].first["data"].first["row"]).not_to be_empty
      expect(tx["results"].first["data"].first["graph"]).not_to be_empty
      expect(tx["results"].first["data"].first["rest"]).not_to be_empty
    end


  end

  describe "keep a transaction" do
    it "can keep a transaction" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      sleep(1)
      existing_tx = @neo.keep_transaction(tx)
      expect(existing_tx).to have_key("transaction")
      expect(existing_tx["transaction"]["expires"]).to be > tx["transaction"]["expires"]
    end
  end

  
  describe "add to a transaction" do
    it "can add to a transaction" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.in_transaction(tx, "MATCH (n) WHERE ID(n) =#{@node_id} RETURN n")
      expect(existing_tx).to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).not_to be_empty
    end

    it "can add to a transaction with parameters" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.in_transaction(tx, ["MATCH (n) WHERE ID(n) ={id} RETURN n", {:id => @node_id}])
      expect(existing_tx).to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).not_to be_empty
    end    

    it "can add to a transaction with representation" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.in_transaction(tx, ["MATCH (n) RETURN n LIMIT 1", [:row,:rest]])
      expect(existing_tx).to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).not_to be_empty
    end    

    it "can add to a transaction with parameters and representation" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.in_transaction(tx, ["MATCH (n) WHERE ID(n)={id} RETURN n", {:id => 0}, [:row,:rest]])
      expect(existing_tx).to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).not_to be_empty
    end    
    
  end

  describe "commit a transaction" do
    it "can commit an opened empty transaction" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.commit_transaction(tx)
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).to be_empty
    end

    it "can commit an opened transaction" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      expect(tx).to have_key("transaction")
      expect(tx["results"]).not_to be_empty
      existing_tx = @neo.commit_transaction(tx)
      expect(existing_tx).not_to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).to be_empty
    end
    
    it "can commit an opened transaction with new statements" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.commit_transaction(tx, "start n=node(0) return n")
      expect(existing_tx).not_to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).not_to be_empty
    end

    it "can commit an new transaction right away" do
      tx = @neo.commit_transaction(["start n=node(0) return n"])
      expect(tx).not_to have_key("transaction")
      expect(tx).to have_key("results")
      expect(tx["results"]).not_to be_empty
    end
    
    it "can commit an new transaction right away with parameters" do
      tx = @neo.commit_transaction(["start n=node({id}) return n", {:id => @node_id}])
      expect(tx).not_to have_key("transaction")
      expect(tx).to have_key("results")
      expect(tx["results"]).not_to be_empty
    end

    it "can commit an new transaction right away without parameters" do
      tx = @neo.commit_transaction("start n=node(0) return n")
      expect(tx).not_to have_key("transaction")
      expect(tx).to have_key("results")
      expect(tx["results"]).not_to be_empty
    end
    
  end

  describe "rollback a transaction" do
    it "can rollback an opened empty transaction" do
      tx = @neo.begin_transaction
      expect(tx).to have_key("transaction")
      expect(tx["results"]).to be_empty
      existing_tx = @neo.rollback_transaction(tx)
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).to be_empty
    end

    it "can rollback an opened transaction" do
      tx = @neo.begin_transaction("start n=node(0) return n")
      expect(tx).to have_key("transaction")
      expect(tx["results"]).not_to be_empty
      existing_tx = @neo.rollback_transaction(tx)
      expect(existing_tx).not_to have_key("transaction")
      expect(existing_tx).to have_key("results")
      expect(existing_tx["results"]).to be_empty
    end
  end  
  
end  