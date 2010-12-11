module Neography
  module NodePath

    def all_paths_to(to)
      PathTraverser.new(self, to, "allPaths", true)
    end

    def all_simple_paths_to(to)
      PathTraverser.new(self, to, "allSimplePaths", true)
    end

    def all_shortest_paths_to(to)
      PathTraverser.new(self, to, "shortestPath", true)
    end

    def path_to(to)
      PathTraverser.new(self, to, "allPaths", false)
    end

    def simple_path_to(to)
      PathTraverser.new(self, to, "allSimplePaths", false)
    end

    def shortest_path_to(to)
      PathTraverser.new(self, to, "shortestPath", false)
    end

  end
end