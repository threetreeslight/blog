+++
date = "2014-04-06T04:23:00+00:00"
draft = false
tags = ["rails", "devise", "registration", "no_password"]
title = "[rails][devise] devise userの更新対象追加 + current_password無し更新"
+++
ちょっと無理矢理やっていたので、ちゃんとdocument探してやる事にしました。

やりたい事は二つ

1. 独自columnのstrong parameterを通す
2. password無しで更新可能にする

解決策としてはシンプルにregistration controllerをoverride


## require

* rails 4
* devise > 3.2 

## 1. 独自columnのstrong parameterを通す 

registrations_controller.rbが追加、今回は、mail_notificationというcolumnを追加したいと思います。

    $ vim app/controller/registrations_controller.rb
    class RegistrationsController < Devise::RegistrationsController
      before_filter :configure_permitted_parameters


      protected

        def configure_permitted_parameters
            devise_parameter_sanitizer.for(:sign_up) do |u|
            u.permit(:email, :password, :password_confirmation, :current_password, :mail_notification)
          end
          devise_parameter_sanitizer.for(:account_update) do |u|
            u.permit(:email, :password, :password_confirmation, :current_password, :mail_notification)
          end
        end

    end

routingも独自振っている訳なので、明示的に。

    $ vim config/routes.rb
    devise_for :users, controllers: { registrations: 'registrations' }


## 2. password無しで更新可能にする

officialのdocumentを読んでみると

[How To: Allow users to edit their account without providing a password](https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password)

updateをoverrideする感じに書いてありますが、ソースを読むと


    # PUT /resource
    # We need to use a copy of the resource because we don't want to change
    # the current user in place.
    def update
      self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
      prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

      resource_updated = update_resource(resource, account_update_params)
      yield resource if block_given?
      if resource_updated
        if is_flashing_format?
          flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
            :update_needs_confirmation : :updated
          set_flash_message :notice, flash_key
        end
        sign_in resource_name, resource, bypass: true
        respond_with resource, location: after_update_path_for(resource)
      else
        clean_up_passwords resource
        respond_with resource
      end
    end

    protected

    # By default we want to require a password checks on update.
    # You can overwrite this method in your own RegistrationsController.
    def update_resource(resource, params)
      resource.update_with_password(params)
    end


というわけで、update_resource更新した方が良さそうですね。

override

    $ vim app/controller/registrations_controller.rb
    class RegistrationsController < Devise::RegistrationsController
      ...

      protected

      def update_resource(resource, params)
        binding.pry
        resource.update_with_password(params)
      end

      
    end
  

resourceのmethod群を潜って見ると


    pry> cd resource
    pry> show-method update_with_password
    From: /opt/boxen/rbenv/versions/2.0.0-p353/lib/ruby/gems/2.0.0/gems/devise-3.2.4/lib/devise/models/database_authenticatable.rb @ line 61:
    Owner: Devise::Models::DatabaseAuthenticatable
    Visibility: public
    Number of lines: 20

    def update_with_password(params, *options)
      current_password = params.delete(:current_password)

      if params[:password].blank?
        params.delete(:password)
        params.delete(:password_confirmation) if params[:password_confirmation].blank?
      end

      result = if valid_password?(current_password)
        update_attributes(params, *options)
      else
        self.assign_attributes(params, *options)
        self.valid?
        self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
        false
      end

      clean_up_passwords
      result
    end

    pry> cd Devise::Models::DatabaseAuthenticatable

    pry(Devise::Models::DatabaseAuthenticatable):2> ls
    constants: ClassMethods
    ActiveSupport::Concern#methods: append_features  included
    Devise::Models::DatabaseAuthenticatable.methods: required_fields
    Devise::Models::DatabaseAuthenticatable#methods:
      after_database_authentication  destroy_with_password  update_without_password
      authenticatable_salt           password=              valid_password?
      clean_up_passwords             update_with_password
    instance variables: @_dependencies  @_included_block
    locals: _  __  _dir_  _ex_  _file_  _in_  _out_  _pry_


おっ、update_without_passwordがあるのね。

    pry> show-method update_without_password

      From: /opt/boxen/rbenv/versions/2.0.0-p353/lib/ruby/gems/2.0.0/gems/devise-3.2.4/lib/devise/models/database_authenticatable.rb @ line 94:
      Owner: Devise::Models::DatabaseAuthenticatable
      Visibility: public
      Number of lines: 8

      def update_without_password(params, *options)
        params.delete(:password)
        params.delete(:password_confirmation)

        result = update_attributes(params, *options)
        clean_up_passwords
        result
      end

というわけで、override内容は

    $ vim app/controller/registrations_controller.rb
    class RegistrationsController < Devise::RegistrationsController
      ...

      protected

      def update_resource(resource, params)
        binding.pry
        resource.update_without_password(params)
      end

      
    end
  
こんな感じで通ります。



## 参考

* deviseのregistration controller - <https://github.com/plataformatec/devise/blob/master/app/controllers/devise/registrations_controller.rb>
* [How To: Allow users to edit their account without providing a password](https://github.com/plataformatec/devise/wiki/How-To:-Allow-users-to-edit-their-account-without-providing-a-password)
