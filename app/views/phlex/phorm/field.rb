module Phlex::Phorm
  class Field
    attr_reader :value, :parent, :children, :key, :dom

    def initialize(key = nil, value: nil, parent: nil, permitted: true)
      @key = key
      @parent = parent
      @children = []
      @value = value || parent_value
      @permitted = true
      @dom = DOM.new(field: self)
      yield self if block_given?
    end

    def permitted?
      @permitted
    end

    def name
      @key unless @parent.is_a? Collection
    end

    def permit(params)
      params.require(@key).permit(*permitted_keys)
    end

    def parents
      field = self
      Enumerator.new do |y|
        while field = field.parent
          y << field
        end
      end
    end

    class LabelComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        label(**attributes) do
          @field.key.to_s.titleize
        end
      end

      def attributes
        { for: @field.dom.id }.merge(@attributes)
      end
    end

    class ButtonComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        button(**attributes) do
          @field.value.to_s.titleize
        end
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name, value: @field.value.to_s }
      end
    end

    class InputComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        input(**attributes.merge(@attributes))
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name, value: @field.value.to_s, type: type }
      end

      def type
        case @field.value
        when URI
          "url"
        when Integer
          "number"
        when Date, DateTime
          "date"
        when Time
          "time"
        else
          "text"
        end
      end
    end

    class TextareaComponent < ApplicationComponent
      def initialize(field:, attributes: {})
        @field = field
        @attributes = attributes
      end

      def template(&)
        textarea(**attributes.merge(@attributes)) do
          @field.value
        end
      end

      def attributes
        { id: @field.dom.id, name: @field.dom.name }
      end
    end

    def input(**attributes)
      InputComponent.new(field: self, attributes: attributes)
    end

    def label(**attributes)
      LabelComponent.new(field: self)
    end

    def textarea(**attributes)
      TextareaComponent.new(field: self, attributes: attributes)
    end

    def button(**attributes)
      ButtonComponent.new(field: self, attributes: attributes)
    end

    def collection(key, **kwargs, &)
      add_child Collection.new(key, parent: self, **kwargs), &
    end

    def field(key = nil, **kwargs, &)
      add_child Field.new(key, parent: self, **kwargs), &
    end

    def add_child(field, &block)
      @children << field
      block.call field if block
      field
    end

    def permitted_keys
      children(&:permitted).map do |child|
        if child.permitted_keys.any?
          { child.key => child.permitted_keys }
        else
          child.key
        end
      end
    end

    def to_h
      @children.each_with_object({}) do |f, h|
        h[f.name] = f.children.any? ? f.to_h : f.value
      end
    end

    def root?
      @parent.nil?
    end

    private

    def parent_value
      @parent.value.send @key if @key and @parent and @parent.value and @parent.value.respond_to? @key
    end
  end
end
