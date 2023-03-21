module Phlexable
  extend ActiveSupport::Concern

  class_methods do
    # Finds a class on the controller with the same name as the action. For example,
    # `def index` would find the `Index` constant on the controller class to render
    # for the action `index`.
    def phlex_action_class(action:)
      action_class = action.camelcase
      const_get action_class if const_defined? action_class
    end
  end

  # Assigns the instance variables that are set in the controller to setter method
  # on Phlex. For example, if a controller defines @users and a Phlex class has
  # `attr_writer :users`, `attr_accessor :user`, or `def users=`, it will be automatically
  # set by this method.
  def assign_phlex_accessors(phlex_view)
    phlex_view.tap do |view|
      view_assigns.each do |variable, value|
        attr_writer_name = "#{variable}="
        view.send attr_writer_name, value if view.respond_to? attr_writer_name
      end
    end
  end

  # Initializers a Phlex view based on the action name, then assigns `view_assigns`
  # to the view.
  def phlex(...)
    assign_phlex_accessors self.class.phlex_action_class(action: action_name).new(...)
  end
end