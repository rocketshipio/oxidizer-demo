class UsersController < ApplicationController
  resources :users

  class Form < ApplicationForm
    def template(&)
      field :name
      field :email
      submit
    end
  end

  class Index < ApplicationView
    attr_writer :users

    def template(&)
      h1 { "People" }
      section do
        ul do
          @users.each do |user|
            li { helpers.link_to(user.name, user) }
          end
        end
        a(href: new_user_path) { "Create user" }
      end
    end
  end

  class Show < ApplicationView
    attr_writer :user

    def template(&)
      h1 { @resource.name }
      section { @user.inspect }
      a(href: new_user_blog_path(@user)) { "Create Blog" }
      a(href: edit_user_path(@user)) { "Edit User" }
    end
  end

  class New < ApplicationView
    attr_writer :user

    def template(&)
      h1 { "Create User" }
      render Form.new(@user)
    end
  end

  class Edit < ApplicationView
    attr_writer :user

    def template(&)
      h1 { "Edit #{@user.name}" }
      render Form.new(@user)
    end
  end
end
