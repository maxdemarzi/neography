require 'spec_helper'

describe Neography::NodePath do

  def create_nodes
    johnathan = Neography::Node.create("name" =>'Johnathan')
    mark      = Neography::Node.create("name" =>'Mark')
    phill     = Neography::Node.create("name" =>'Phill')
    mary      = Neography::Node.create("name" =>'Mary')

    johnathan.both(:friends) << mark
    mark.both(:friends) << mary
    mark.both(:friends) << phill
    phill.both(:friends) << mary

    [johnathan, mark, phill, mary]
  end

  describe "all_paths" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_paths_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_paths_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_paths_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end

  describe "all_simple_paths" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_simple_paths_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_simple_paths_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_simple_paths_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end

  describe "all_shortest_paths_to" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_shortest_paths_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_shortest_paths_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.all_shortest_paths_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end

  describe "path_to" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.path_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.path_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.path_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end

  describe "simple_path_to" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.simple_path_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.simple_path_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.simple_path_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end

  describe "shortest_path_to" do
    it "can return nodes" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.shortest_path_to(mary).incoming(:friends).depth(4).nodes.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_true}
         path.map{|n| n.is_a?(Neography::Relationship).should be_false}
      end
    end

    it "can return relationships" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.shortest_path_to(mary).incoming(:friends).depth(4).rels.each do |path|
         path.map{|n| n.is_a?(Neography::Node).should be_false}
         path.map{|n| n.is_a?(Neography::Relationship).should be_true}
      end
    end

    it "can return both" do
      johnathan, mark, phill, mary = create_nodes

      johnathan.shortest_path_to(mary).incoming(:friends).depth(4).each do |path|
        path.each_with_index do  |n,i| 
          if i.even?
            n.is_a?(Neography::Node).should be_true
          else
            n.is_a?(Neography::Relationship).should be_true 
          end
        end
      end
    end
  end
end
