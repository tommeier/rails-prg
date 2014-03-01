module Rails
  # Post-Redirect-Get
  module Prg
    # Allow full POST-REDIRECT-GET pattern, instead of rendering an error, on change of object
    # redirect back and load errors on to object. This prevents issues with a fully
    # secure browser environment (no-cache, no-store), when the user clicks back
    # Note: The filter *must* be loaded after the object instance is loaded for dynamic
    # lookup without having to find it again.
    # eg:
    # class ObjectController
    #   before_filter :find_object,               only: [:edit,:update]
    #   before_filter :load_redirected_objects!,  only: [:edit]
    #   def update
    #     if errors;
    #       set_redirected_object!('@object', @object, clean_params)
    #       redirect_to edit_object_path(@object)
    module RedirectedObjectController
      extend ActiveSupport::Concern

      # Load any redirected objects present in flash
      # Loaded on any view where an error redirect has occured
      def load_redirected_objects!
        if flash[:redirected_objects]
          flash[:redirected_objects].each do |instance_reference, attributes|
            object_instance = instance_variable_get(instance_reference)
            # Apply errors to instance
            set_errors_to_redirected_instance(object_instance, attributes[:errors])
            # Apply any params (ie: changed form fields to be corrected)
            set_params_to_redirected_instance(object_instance, attributes[:params])
          end
        end
      ensure
        flash.delete(:redirected_objects)
      end

      # Allow Post-Redirect-Get on errors & submitted details
      # passing details to redirected page for display
      def set_redirected_object!(instance_reference, instance, instance_params)
        ensure_redirected_params_are_safe!(instance_params)

        flash[:redirected_objects] ||= {}
        flash[:redirected_objects][instance_reference] = {
          errors: instance.errors.messages,
          params: instance_params
        }
      end

      private

      # Compare passed params for redirected object
      #  - raise error if not strong parameters or not marked as safe
      def ensure_redirected_params_are_safe!(passed_params)
        unless passed_params.is_a?(ActionController::Parameters) && passed_params.permitted?
          error_message = if passed_params.is_a?(ActionController::Parameters)
            unsafe_parameters = passed_params.send(:unpermitted_keys, params)
            "[Rails::Prg] Error - Must use permitted strong parameters. Unsafe: #{unsafe_parameters.join(', ')}"
          else
            "[Rails::Prg] Error - Must pass strong parameters."
          end
          raise error_message
        end
      end

      # Assign any errors to redirected instance
      def set_errors_to_redirected_instance(instance, error_hash = {})
        error_hash.each do |attribute, errors|
          errors.each do |error_for_attribute|
            instance.errors.add(attribute, error_for_attribute)
          end
        end
      end

      # Assign any provided params to redirected instance
      # - Only clean params should be passed through
      def set_params_to_redirected_instance(instance, instance_params)
        ensure_redirected_params_are_safe!(instance_params)

        instance_params.each do |attribute, value|
          instance.public_send("#{attribute}=", value)
        end
      end
    end
  end
end
