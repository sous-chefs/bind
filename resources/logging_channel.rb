# frozen_string_literal: true

property :bind_config, String, default: 'default'

property :destination, String, equal_to: %w(
  stderr syslog file null
)

property :facility, String, equal_to: %w(
  kern user mail daemon auth syslog lpr news uucp cron authpriv
  ftp local0 local1 local2 local3 local4 local5 local6 local7
)

property :severity, String, default: 'dynamic', callbacks: {
  'should be a valid severity' => lambda { |severity|
    %w(
      critical error warning notice info dynamic
    ).include?(severity) || severity.match(/^debug\s+\d+$/)
  },
}

property :path, String
property :versions, Integer
property :size, String

property :print_category, [true, false], default: false
property :print_severity, [true, false], default: false
property :print_time, [true, false], default: false

# The options parameter is used to allow the deprecated bind_config
# property `query_log_options` to work. It is not used here, and should be
# removed when the deprecated property is removed.
LoggingChannel = Struct.new(
  :name, :destination, :severity, :print_category,
  :print_severity, :print_time, :options
)

action :create do
  destination_config_line = case new_resource.destination
                            when 'file'
                              file_destination(
                                new_resource.path,
                                new_resource.versions,
                                new_resource.size
                              )
                            when 'syslog'
                              "syslog #{new_resource.facility}"
                            else
                              new_resource.destination.to_s
                            end

  options_template.variables[:logging_channels] << LoggingChannel.new(
    new_resource.name, destination_config_line,
    new_resource.severity, new_resource.print_category,
    new_resource.print_severity, new_resource.print_time, []
  )
end

action_class do
  include BindCookbook::ResourceHelpers

  def file_destination(path, versions, size)
    result = ["file \"#{path}\""]
    result << "versions #{versions}" if versions
    result << "size #{size}" if size
    result.join(' ')
  end
end
