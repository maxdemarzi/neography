FakeWeb.register_uri(:get, "http://localhost:7474/", :body => '{
  "index" : "http://localhost:7474/index",
  "node" : "http://localhost:7474/node",
  "reference_node" : "http://localhost:7474/node/0"
}')