require 'rails/railtie'

module Rails
  module Prg
    class Railtie < Rails::Railtie
      initializer "rails-prg.action_controller" do
        ActiveSupport.on_load(:action_controller) do
          include Rails::Prg::RedirectedObjectController
        end
      end
    end
  end
end
