module Neography

  class NeographyError < StandardError
    attr_reader :message, :code, :stacktrace, :request, :index

    def initialize(message = nil, code = nil, stacktrace = nil, request = nil, index = 0)
      @message    = message
      @code       = code
      @stacktrace = stacktrace
      @request    = request
      @index      = index
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

  # Thrown when CREATE UNIQUE matches multiple paths.
  class UniquePathNotUniqueException < NeographyError; end

  # Signals that a deadlock between two or more transactions has been detected
  class DeadlockDetectedException < NeographyError; end

end
