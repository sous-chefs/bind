# frozen_string_literal: true

module BindCookbook
  module ResourceHelpers
    def find_bind_config
      with_run_context :root do
        find_resource!(:bind_config, new_resource.bind_config)
      end
    end

    def find_service_resource
      with_run_context :root do
        find_resource!(:bind_service, find_bind_config.bind_service)
      end
    end

    def options_template
      with_run_context :root do
        find_resource!(:template, find_bind_config.options_file)
      end
    end

    def config_template
      with_run_context :root do
        find_resource!(:template, find_bind_config.conf_file)
      end
    end

    def choose_view
      new_resource.view || find_bind_config.default_view
    end
  end
end
