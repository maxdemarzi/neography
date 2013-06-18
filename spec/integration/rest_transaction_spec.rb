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