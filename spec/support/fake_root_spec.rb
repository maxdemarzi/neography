FakeWeb.register_uri(:get, "http://localhost:9999/", :body => '{
  "index" : "http://localhost:9999/index",
  "node" : "http://localhost:9999/node",
  "reference_node" : "http://localhost:9999/node/0"
}')