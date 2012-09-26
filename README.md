[![Build Status](https://secure.travis-ci.org/maxdemarzi/neography.png?branch=master)](http://travis-ci.org/maxdemarzi/neography)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/maxdemarzi/neography)

## Welcome to Neography 

Neography is a thin Ruby wrapper to the Neo4j Rest API, for more information:

* [Getting Started with Neo4j Server](http://neo4j.org/community/)
* [Neo4j Rest API Reference](http://docs.neo4j.org/chunked/milestone/rest-api.html)

If you want to the full power of Neo4j, you will want to use JRuby and the excellent Neo4j.rb gem at https://github.com/andreasronge/neo4j by Andreas Ronge


## Installation

### Gemfile

Add `neography` to your Gemfile:

```ruby
gem 'neography'
```

And run Bundler:

```sh
$ bundle
```

### Manually:

Or install `neography` manually:

```sh
$ gem install 'neography'
```

And require the gem in your Ruby code:

```ruby
require 'rubygems'
require 'neography'
```

Read the wiki for information about [dependencies](https://github.com/maxdemarzi/neography/wiki/Dependencies).

[Rake tasks](https://github.com/maxdemarzi/neography/wiki/Rake-tasks) are available.


## Usage

### Configuration and initialization

Configure Neography as follows:

```ruby
# these are the default values:
Neography.configure do |config|
  config.protocol       = "http://"
  config.server         = "localhost"
  config.port           = 7474
  config.directory      = ""  # prefix this path with '/' 
  config.cypher_path    = "/cypher"
  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file       = "neography.log"
  config.log_enabled    = false
  config.max_threads    = 20
  config.authentication = nil  # 'basic' or 'digest'
  config.username       = nil
  config.password       = nil
  config.parser         = {:parser => MultiJsonParser}
end
```

Then initialize as follows:

```ruby
@neo = Neography::Rest.new
```

For overriding these default and other initialization methods, see the
[configuration and initialization](https://github.com/maxdemarzi/neography/wiki/Configuration-and-initialization) page in the Wiki.


### REST API

Neography supports the creation and retrieval of nodes and relationships through the Neo4j interface.
It supports indexes, Gremlin scripts, Cypher queries and batch operations.

Some of this functionality is shown here, but all of it is explained in the following Wiki pages:

* [Nodes](https://github.com/maxdemarzi/neography/wiki/Nodes)
* [Node properties](https://github.com/maxdemarzi/neography/wiki/Node-properties)
* [Node relationships](https://github.com/maxdemarzi/neography/wiki/Node-relationships)

* [Relationship](https://github.com/maxdemarzi/neography/wiki/Relationships)
* [Relationship properties](https://github.com/maxdemarzi/neography/wiki/Relationship-properties)

* [Node indexes](https://github.com/maxdemarzi/neography/wiki/Node-indexes)
* [Relationship indexes](https://github.com/maxdemarzi/neography/wiki/Relationship-indexes)
* [Auto indexes](https://github.com/maxdemarzi/neography/wiki/Node-indexes)

* [Scripts and queries](https://github.com/maxdemarzi/neography/wiki/Scripts-and-queries)
* [Paths and traversal](https://github.com/maxdemarzi/neography/wiki/Paths-and-traversal)
* [Batch](https://github.com/maxdemarzi/neography/wiki/Batch)

* [Experimental](https://github.com/maxdemarzi/neography/wiki/Experimental)


Some example usage:

```ruby
# Node creation:
node1 = @neo.create_node("age" => 31, "name" => "Max")
node2 = @neo.create_node("age" => 33, "name" => "Roel")

# Node properties:
@neo.set_node_properties(node1, {"weight" => 200})

# Relationships between nodes:
@neo.create_relationship("coding_buddies", node1, node2)

# Get node relationships:
@neo.get_node_relationships(node2, "in", "coding_buddies")

# Use indexes:
@neo.add_node_to_index('people', 'name', 'max', node1)
@neo.get_node_index('people', name', 'max')

# Cypher queries:
@neo.execute_query("start n=node(0) return n")

# Batches:
@neo.batch [:create_node, {"name" => "Max"}],
           [:create_node, {"name" => "Marc"}]
```

This is just a small sample of the full API, see the [Wiki documentation](https://github.com/maxdemarzi/neography/wiki) for the full API.


### Phase 2

Trying to mimic the Neo4j.rb API.

Now we are returning full objects.  The properties of the node or relationship can be accessed directly (node.name).
The Neo4j ID is available by using node.neo_id .

```ruby
@neo2 = Neography::Rest.new({:server => '192.168.10.1'})

Neography::Node.create                                               # Create an empty node
Neography::Node.create("age" => 31, "name" => "Max")                 # Create a node with some properties
Neography::Node.create({"age" => 31, "name" => "Max"}, @neo2)        # Create a node on the server defined in @neo2

Neography::Node.load(5)                                              # Get a node and its properties by id
Neography::Node.load(existing_node)                                  # Get a node and its properties by Node
Neography::Node.load("http://localhost:7474/db/data/node/2")         # Get a node and its properties by String

Neography::Node.load(5, @neo2)                                       # Get a node on the server defined in @neo2

n1 = Node.create
n1.del                                                               # Deletes the node
n1.exist?                                                            # returns true/false if node exists in Neo4j

n1 = Node.create("age" => 31, "name" => "Max")
n1[:age] #returns 31                                                 # Get a node property using [:key]
n1.name  #returns "Max"                                              # Get a node property as a method
n1[:age] = 24                                                        # Set a node property using [:key] =
n1.name = "Alex"                                                     # Set a node property as a method
n1[:hair] = "black"                                                  # Add a node property using [:key] =
n1.weight = 190                                                      # Add a node property as a method
n1[:name] = nil                                                      # Delete a node property using [:key] = nil
n1.name = nil                                                        # Delete a node property by setting it to nil

n2 = Neography::Node.create
new_rel = Neography::Relationship.create(:family, n1, n2)            # Create a relationship from my_node to node2
new_rel.start_node                                                   # Get the start/from node of a relationship
new_rel.end_node                                                     # Get the end/to node of a relationship
new_rel.other_node(n2)                                               # Get the other node of a relationship
new_rel.attributes                                                   # Get the attributes of the relationship as an array

existing_rel = Neography::Relationship.load(12)                      # Get an existing relationship by id
existing_rel.del                                                     # Delete a relationship

Neography::Relationship.create(:friends, n1, n2)
n1.outgoing(:friends) << n2                                          # Create outgoing relationship
n1.incoming(:friends) << n2                                          # Create incoming relationship
n1.both(:friends) << n2                                              # Create both relationships

n1.outgoing                                                          # Get nodes related by outgoing relationships
n1.incoming                                                          # Get nodes related by incoming relationships
n1.both                                                              # Get nodes related by any relationships

n1.outgoing(:friends)                                                # Get nodes related by outgoing friends relationship
n1.incoming(:friends)                                                # Get nodes related by incoming friends relationship
n1.both(:friends)                                                    # Get nodes related by friends relationship

n1.outgoing(:friends).incoming(:enemies)                             # Get nodes related by one of multiple relationships
n1.outgoing(:friends).depth(2)                                       # Get nodes related by friends and friends of friends
n1.outgoing(:friends).depth(:all)                                    # Get nodes related by friends until the end of the graph
n1.outgoing(:friends).depth(2).include_start_node                    # Get n1 and nodes related by friends and friends of friends

n1.outgoing(:friends).prune("position.endNode().getProperty('name') == 'Tom';")
n1.outgoing(:friends).filter("position.length() == 2;")

n1.rel?(:friends)                                                    # Has a friends relationship
n1.rel?(:outgoing, :friends)                                         # Has outgoing friends relationship
n1.rel?(:friends, :outgoing)                                         # same, just the other way
n1.rel?(:outgoing)                                                   # Has any outgoing relationships
n1.rel?(:both)                                                       # Has any relationships
n1.rel?(:all)                                                        # same as above
n1.rel?                                                              # same as above

n1.rels                                                              # Get node relationships
n1.rels(:friends)                                                    # Get friends relationships
n1.rels(:friends).outgoing                                           # Get outgoing friends relationships
n1.rels(:friends).incoming                                           # Get incoming friends relationships
n1.rels(:friends,:work)                                              # Get friends and work relationships
n1.rels(:friends,:work).outgoing                                     # Get outgoing friends and work relationships

n1.all_paths_to(n2).incoming(:friends).depth(4)                      # Gets all paths of a specified type
n1.all_simple_paths_to(n2).incoming(:friends).depth(4)               # for the relationships defined
n1.all_shortest_paths_to(n2).incoming(:friends).depth(4)             # at a maximum depth
n1.path_to(n2).incoming(:friends).depth(4)                           # Same as above, but just one path.
n1.simple_path_to(n2).incoming(:friends).depth(4)
n1.shortest_path_to(n2).incoming(:friends).depth(4)

n1.shortest_path_to(n2).incoming(:friends).depth(4).rels             # Gets just relationships in path
n1.shortest_path_to(n2).incoming(:friends).depth(4).nodes            # Gets just nodes in path
```

See Neo4j API for:
* [Order](http://components.neo4j.org/neo4j-examples/1.2.M04/apidocs/org/neo4j/graphdb/Traverser.Order.html)
* [Uniqueness](http://components.neo4j.org/neo4j-examples/1.2.M04/apidocs/org/neo4j/kernel/Uniqueness.html)
* [Prune Evaluator](http://components.neo4j.org/neo4j-examples/1.2.M04/apidocs/org/neo4j/graphdb/StopEvaluator.html)
* [Return Filter](http://components.neo4j.org/neo4j-examples/1.2.M04/apidocs/org/neo4j/graphdb/ReturnableEvaluator.html)

### Examples

A couple of examples borrowed from Matthew Deiters's Neo4jr-social:

*  [Facebook](https://github.com/maxdemarzi/neography/blob/master/examples/facebook.rb)
*  [Linked In](https://github.com/maxdemarzi/neography/blob/master/examples/linkedin.rb)

Phase 2 way of doing these:

*  [Facebook](https://github.com/maxdemarzi/neography/blob/master/examples/facebook_v2.rb)
*  [Linked In](https://github.com/maxdemarzi/neography/blob/master/examples/linkedin_v2.rb)

### Testing

To run testing locally you will need to have two instances of the server running. There is some
good advice on how to set up the a second instance on the
[neo4j site](http://docs.neo4j.org/chunked/stable/server-installation.html#_multiple_server_instances_on_one_machine).
Connect to the second instance in your testing environment, for example:

```ruby
if Rails.env.development?
  @neo  = Neography::Rest.new({:port => 7474})
elsif Rails.env.test?
  @neo  = Neography::Rest.new({:port => 7475})
end
```

Install the test-delete-db-extension plugin, as mentioned in the neo4j.org docs, if you want to use
the Rest clean_database method to empty your database between tests. In Rspec, for example,
put this in your spec_helper.rb:

```ruby
config.before(:each) do
  @neo.clean_database("yes_i_really_want_to_clean_the_database")
end
```

### Related Neo4j projects

Complement to Neography are the:

* [Neo4j Active Record Adapter](https://github.com/yournextleap/activerecord-neo4j-adapter) by Nikhil Lanjewar
* [Neology](https://github.com/lordkada/neology) by Carlo Alberto Degli Atti
* [Neoid](https://github.com/elado/neoid) by Elad Ossadon

An alternative is the Architect4r Gem at https://github.com/namxam/architect4r by Maximilian Schulz

### Neography in the Wild

* [Vouched](http://getvouched.com)
* [Neovigator](http://neovigator.herokuapp.com) fork it at https://github.com/maxdemarzi/neovigator
* [Neoflix](http://neoflix.herokuapp.com) fork it at  https://github.com/maxdemarzi/neoflix

### Getting started with Neography

* [Getting Started with Ruby and Neo4j](http://maxdemarzi.com/2012/01/04/getting-started-with-ruby-and-neo4j/)
* [Graph visualization with Neo4j](http://maxdemarzi.com/2012/01/11/graph-visualization-and-neo4j/)
* [Neo4j on Heroku](http://maxdemarzi.com/2012/01/13/neo4j-on-heroku-part-one/)

### To-do

* Batch functions
* Phase 2 Index functionality
* Phase 2 Unit Tests
* More Examples
* Mixins ?

### Contributing

[![Build Status](https://secure.travis-ci.org/maxdemarzi/neography.png)](http://travis-ci.org/maxdemarzi/neography)

Please create a [new issue](https://github.com/maxdemarzi/neography/issues) if you run into any bugs.

Contribute patches via pull requests.

### Help

If you are just starting out, or need help send me an e-mail at maxdemarzi@gmail.com.
Check you my blog at http://maxdemarzi.com where I have more Neography examples.

### Licenses

* Neography - MIT, see the LICENSE file http://github.com/maxdemarzi/neography/tree/master/LICENSE.
* Lucene -  Apache, see http://lucene.apache.org/java/docs/features.html
* Neo4j - Dual free software/commercial license, see http://neo4j.org

