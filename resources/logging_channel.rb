unified_mode true

property :bind_config, String,
          default: 'default',
          description: 'Name of the `bind_config` resource to notify actions on'
property :destination, String,
          equal_to: %w(stderr syslog file null),
          description: 'String containing the destination name'
property :facility, String,
          equal_to: %w(
            kern user mail daemon auth syslog lpr news uucp cron authpriv ftp local0 local1 local2 local3 local4 local5
            local6 local7
          ),
          description: 'String containing the syslog facility to use for the syslog destination'
property :path, String,
          description: 'File name used for the file destination'
property :print_category, [true, false],
          default: false,
          description: 'Boolean representing if we should print the category in the output message'
property :print_severity, [true, false],
          default: false,
          description: 'Boolean representing if we should print the severity of the log message to the output channel'
property :print_time, [true, false],
          default: false,
          description: 'Boolean representing if we should print the time in the log message sent to the output channel'
property :severity, String,
          default: 'dynamic',
          callbacks: {
            'should be a valid severity' => lambda { |severity|
              %w(critical error warning notice info dynamic).include?(severity) || severity.match(/^debug\s+\d+$/)
            },
          },
          description: 'String containing the minimum severity of BIND logs to send to this channel'
property :size, String,
          description: 'Maximum size of the log file used for the file destination'
property :versions, Integer,
          description: 'Number of versions of the log file used for the file destination'

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
  apparmor_template.variables[:log_files] << new_resource.path if new_resource.destination == 'file' && platform?('ubuntu')
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
