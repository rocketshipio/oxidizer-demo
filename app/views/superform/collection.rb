module Superform
  class Collection
    include Enumerable

    attr_reader :key, :parent

    def initialize(key, schema:, parent:, object: [], builder:, &block)
      @key = key
      @children = []
      @parent = parent
      @schema = schema
      @block = block
      @builder = builder

      self.assign object if object.any?
    end

    def each(&)
      @children.each(&)
    end

    def assign(array)
      array.each { |value| index_namespace(&@block).assign value }
    end

    def namespace(...)
      index_namespace.tap { |namespace| namespace.namespace(...) }
    end

    def collection(...)
      index_namespace.collection(...)
    end

    def field(value: nil)
      @builder.field(@children.size, parent: self, value: value).tap do |field|
        @children.append field
      end
    end

    def serialize
      map(&:serialize)
    end

    private

    def index_namespace(&block)
      @builder.namespace(@children.size, parent: self, schema: @schema, &block).tap do |namespace|
        @children.append namespace
      end
    end
  end
end
