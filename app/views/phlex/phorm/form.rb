module Phlex::Phorm
  class Form < Phlex::HTML
    attr_reader :model

    delegate :field, :collection, :permit, to: :@field

    # TODO: Overlay this stuff
    Field = Phlex::Phorm::Field

    def self.register_component(tag, class_constant)
      Field.define_method tag do |**attributes|
        class_constant.new(field: self, attributes: attributes)
      end
    end

    prepend Components

    register_component :input, InputComponent
    register_component :label, LabelComponent
    register_component :textarea, TextareaComponent
    register_component :button, ButtonComponent
    # // TODO: Overlay this stuff

    def initialize(model, action: nil, method: nil)
      @model = model
      @action = action
      @method = method
      @field = Field.new(model.model_name.param_key, value: model)
    end

    def around_template(&)
      form action: form_action, method: form_method do
        authenticity_token_field
        _method_field
        super
      end
    end

    def template(&block)
      yield_content(&block)
    end

    def submit(value = submit_value)
      input(
        name: "commit",
        type: "submit",
        value: value
      )
    end

    protected

    def authenticity_token_field
      input(
        name: "authenticity_token",
        type: "hidden",
        value: helpers.form_authenticity_token
      )
    end

    def _method_field
      input(
        name: "_method",
        type: "hidden",
        value: _method_field_value
      )
    end

    def _method_field_value
      @method || @model.persisted? ? "patch" : "post"
    end

    def submit_value
      "#{resource_action.to_s.capitalize} #{@model.model_name}"
    end

    def resource_action
      @model.persisted? ? :update : :create
    end

    def form_action
      @action ||= helpers.url_for(action: resource_action)
    end

    def form_method
      @method.to_s.downcase == "get" ? "get" : "post"
    end
  end
end