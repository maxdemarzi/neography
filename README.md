Neography
=========

- [![Gem Version](https://badge.fury.io/rb/neography.png)](https://rubygems.org/gems/neography)
- [![Build Status](https://secure.travis-ci.org/maxdemarzi/neography.png?branch=master)](http://travis-ci.org/maxdemarzi/neography)
- [![Code Climate](https://codeclimate.com/github/maxdemarzi/neography.png)](https://codeclimate.com/github/maxdemarzi/neography)
- [![Coverage Status](https://coveralls.io/repos/maxdemarzi/neography/badge.png?branch=master)](https://coveralls.io/r/maxdemarzi/neography)

## Welcome to Neography 

Neography is a thin Ruby wrapper to the Neo4j Rest API, for more information:

* [Getting Started with Neo4j Server](http://neo4j.org/community/)
* [Neo4j Rest API Reference](http://docs.neo4j.org/chunked/milestone/rest-api.html)

If you want to utilize the full power of Neo4j, you will want to use JRuby and the excellent Neo4j.rb gem at https://github.com/andreasronge/neo4j by Andreas Ronge


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

[Rake tasks](https://github.com/maxdemarzi/neography/wiki/Rake-tasks) are available for downloading, installing and running Neo4j.


## Usage

### Configuration and initialization

Configure Neography as follows:

```ruby
# these are the default values:
Neography.configure do |config|
  config.protocol             = "http"
  config.server               = "localhost"
  config.port                 = 7474
  config.directory            = ""  # prefix this path with '/'
  config.cypher_path          = "/cypher"
  config.gremlin_path         = "/ext/GremlinPlugin/graphdb/execute_script"
  config.log_file             = "neography.log"
  config.log_enabled          = false
  config.slow_log_threshold   = 0    # time in ms for query logging
  config.max_threads          = 20
  config.authentication       = nil  # 'basic' or 'digest'
  config.username             = nil
  config.password             = nil
  config.parser               = MultiJsonParser
  config.http_send_timeout    = 1200
  config.http_receive_timeout = 1200
  config.persistent           = true
  end
  ```

Then initialize a `Rest` instance:

```ruby
@neo = Neography::Rest.new
@neo = Neography::Rest.new({:authentication => 'basic', :username => "neo4j", :password => "swordfish"})
@neo = Neography::Rest.new("http://neo4j:swordfish@localhost:7474")
```

For overriding these default and other initialization methods, see the
[configuration and initialization](https://github.com/maxdemarzi/neography/wiki/Configuration-and-initialization) page in the Wiki.


### REST API

Neography supports the creation and retrieval of nodes and relationships through the Neo4j REST interface.
It supports indexes, Gremlin scripts, Cypher queries and batch operations.

Some of this functionality is shown here, but all of it is explained in the following Wiki pages:

2.0 Only features:

* [Schema indexes](https://github.com/maxdemarzi/neography/wiki/Schema-indexes) - Create, get and delete schema indexes.
* [Node labels](https://github.com/maxdemarzi/neography/wiki/Node-labels) - Create, get and delete node labels.
* [Transactions](https://github.com/maxdemarzi/neography/wiki/Transactions) - Begin, add to, commit, rollback transactions.

1.8+ features:

* [Nodes](https://github.com/maxdemarzi/neography/wiki/Nodes) - Create, get and delete nodes.
* [Node properties](https://github.com/maxdemarzi/neography/wiki/Node-properties) - Set, get and remove node properties.
* [Node relationships](https://github.com/maxdemarzi/neography/wiki/Node-relationships) - Create and get relationships between nodes.
* [Relationship](https://github.com/maxdemarzi/neography/wiki/Relationships) - Get and delete relationships.
* [Relationship properties](https://github.com/maxdemarzi/neography/wiki/Relationship-properties) - Create, get and delete relationship properties.
* [Relationship types](https://github.com/maxdemarzi/neography/wiki/Relationship-types) - List relationship types.
* [Node indexes](https://github.com/maxdemarzi/neography/wiki/Node-indexes) - List and create node indexes. Add, remove, get and search nodes in indexes.
* [Relationship indexes](https://github.com/maxdemarzi/neography/wiki/Relationship-indexes) - List and create relationships indexes. Add, remove, get and search relationships in indexes.
* [Auto indexes](https://github.com/maxdemarzi/neography/wiki/Auto-indexes) - Get, set and remove auto indexes.
* [Scripts and queries](https://github.com/maxdemarzi/neography/wiki/Scripts-and-queries) - Run Gremlin scripts and Cypher queries.
* [Paths and traversal](https://github.com/maxdemarzi/neography/wiki/Paths-and-traversal) - Paths between nodes and path traversal.
* [Batch](https://github.com/maxdemarzi/neography/wiki/Batch) - Execute multiple calls at once.
* [Errors](https://github.com/maxdemarzi/neography/wiki/Errors) - Errors raised if REST API calls fail.


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
@neo.add_node_to_index("people", "name", "max", node1)
@neo.get_node_index("people", "name", "max")

# Batches:
@neo.batch [:create_node, {"name" => "Max"}],
           [:create_node, {"name" => "Marc"}]
           
# Cypher queries:
@neo.execute_query("start n=node(0) return n")
           
```

You can also use the [cypher gem](https://github.com/andreasronge/neo4j-cypher) instead of writing cypher as text.


```
node(1).outgoing(rel(:friends).where{|r| r[:since] == 1994})
```

would become:

```
START me=node(1) 
MATCH (me)-[friend_rel:`friends`]->(friends) 
WHERE (friend_rel.since = 1994) 
RETURN friends
```

This is just a small sample of the full API, see the [Wiki documentation](https://github.com/maxdemarzi/neography/wiki) for the full API.

Neography raises REST API errors as Ruby errors, see the wiki page about [errors](https://github.com/maxdemarzi/neography/wiki/Errors).
(**Note**: older versions of Neography did not raise any errors!)


## *Phase 2*

Trying to mimic the [Neo4j.rb API](https://github.com/andreasronge/neo4j/wiki/Neo4j%3A%3ACore-Nodes-Properties-Relationships).

Now we are returning full objects. The properties of the node or relationship can be accessed directly (`node.name`).
The Neo4j ID is available by using `node.neo_id`.

Some of this functionality is shown here, but all of it is explained in the following Wiki pages:

* [Nodes](https://github.com/maxdemarzi/neography/wiki/Phase-2-Nodes) - Create, load and delete nodes.
* [Node properties](https://github.com/maxdemarzi/neography/wiki/Phase-2-Node-properties) - Add, get and remove node properties.
* [Node relationships](https://github.com/maxdemarzi/neography/wiki/Phase-2-Node-relationships) - Create and retrieve node relationships.
* [Node paths](https://github.com/maxdemarzi/neography/wiki/Phase-2-Node-paths) - Gets paths between nodes.


```ruby
# create two nodes:
n1 = Neography::Node.create("age" => 31, "name" => "Max")
n2 = Neography::Node.create("age" => 33, "name" => "Roel")

n1.exist? # => true

# get and change some properties:
n1[:age]         # => 31
n1.name          # => "Max"
n1[:age]  = 32   # change property
n1.weight = 190  # new property
n1.age    = nil  # remove property

# add a relationship between nodes:
new_rel = Neography::Relationship.create(:coding_buddies, n1, n2)

# remove a relationship:
new_rel.del

# add a relationship on nodes:
n1.outgoing(:coding_buddies) << n2

# more advanced relationship traversal:
n1.outgoing(:friends)                                                # Get nodes related by outgoing friends relationship
n1.outgoing(:friends).depth(2).include_start_node                    # Get n1 and nodes related by friends and friends of friends

n1.rel?(:outgoing, :friends)                                         # Has outgoing friends relationship
n1.rels(:friends,:work).outgoing                                     # Get outgoing friends and work relationships

n1.all_paths_to(n2).incoming(:friends).depth(4)                      # Gets all paths of a specified type
n1.shortest_path_to(n2).incoming(:friends).depth(4).nodes            # Gets just nodes in path
```

This is just a small sample of the full API, see the [Wiki documentation](https://github.com/maxdemarzi/neography/wiki) for the full API.

## More

### Examples

Some [example code](https://github.com/maxdemarzi/neography/wiki/Examples).


### Testing

Some [tips about testing](https://github.com/maxdemarzi/neography/wiki/Testing).


### Related Neo4j projects

Complement to Neography are the:

* [Neo4j Active Record Adapter](https://github.com/yournextleap/activerecord-neo4j-adapter) by Nikhil Lanjewar
* [Neology](https://github.com/lordkada/neology) by Carlo Alberto Degli Atti
* [Neoid](https://github.com/elado/neoid) by Elad Ossadon

An alternative to Neography is [Architect4r](https://github.com/namxam/architect4r) by Maximilian Schulz


### Neography in the Wild

* [Vouched](http://getvouched.com)
* [Neovigator](http://neovigator.herokuapp.com) fork it at https://github.com/maxdemarzi/neovigator
* [Neoflix](http://neoflix.herokuapp.com) fork it at  https://github.com/maxdemarzi/neoflix


### Getting started with Neography

* [Getting Started with Ruby and Neo4j](http://maxdemarzi.com/2012/01/04/getting-started-with-ruby-and-neo4j/)
* [Graph visualization with Neo4j](http://maxdemarzi.com/2012/01/11/graph-visualization-and-neo4j/)
* [Neo4j on Heroku](http://maxdemarzi.com/2012/01/13/neo4j-on-heroku-part-one/)


## Contributing

Please create a [new issue](https://github.com/maxdemarzi/neography/issues) if you run into any bugs.

Contribute patches via [pull requests](https://github.com/maxdemarzi/neography/pulls).


## Help

If you are just starting out, or need help send me an e-mail at maxdemarzi@gmail.com.

Check you my blog at http://maxdemarzi.com where I have more Neography examples.


## Licenses

* Neography - MIT, see the LICENSE file http://github.com/maxdemarzi/neography/tree/master/LICENSE.
* Lucene -  Apache, see http://lucene.apache.org/java/docs/features.html
* Neo4j - Dual free software/commercial license, see http://neo4j.org

