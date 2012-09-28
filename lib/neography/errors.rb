module Neography

  class NeographyError < StandardError
    attr_reader :message, :stacktrace

    def initialize(message = nil, code = nil, stacktrace = nil)
      @message = message
      @stacktrace = stacktrace
    end
  end

  # HTTP Authentication error
  class UnauthorizedError < NeographyError; end

  # the Neo4j server Exceptions returned by the REST API:

  # A node could not be found
  class NodeNotFoundException < NeographyError; end

  # A node cannot be deleted because it has relationships
  class OperationFailureException < NeographyError; end

  # Properties can not be null
  class PropertyValueException < NeographyError; end

  # Trying to a delete a property that does not exist
  class NoSuchPropertyException < NeographyError; end

  # A relationship could not be found
  class RelationshipNotFoundException < NeographyError; end

  # Error during valid Cypher query
  class BadInputException < NeographyError; end

  # Invalid Cypher query syntax
  class SyntaxException < NeographyError; end

  # A path could not be found by node traversal
  class NotFoundException < NeographyError; end

end
