require 'tor'
require 'openssl'
require 'fileutils'

module Tor
  class HiddenService

    attr_reader :options

    def initialize(options={})
      @options = parse_options(options)
      @base_dir = "#{@options[:temp_dir]}/tor_#{@options[:tor_control_port]}"
    end

    def start
      generate_tor_config

      @pid = fork do
        spawn @options[:tor_executable], '-f',  "#{@base_dir}/torrc"
      end
      Process.wait(@pid)

      begin
        @tor_pid = File.read(open("#{@base_dir}/pid")).strip.to_i
      rescue Errno::ENOENT
        log_message "Waiting for Tor PID to appear..."
        sleep 1
        retry
      end

      log_message "Started Tor with PID #{@tor_pid} on control port #{@options[:tor_control_port]}"

      at_exit do
        log_message "Killing Tor PID #{@tor_pid}..."
        Process.kill :SIGTERM, @tor_pid
        Process.wait
      end
    end

    private

    def parse_options(options)
      parsed_options = {
        tor_executable:      (Tor.available? ? Tor.program_path : nil),
        temp_dir:            "#{ENV['PWD']}/tmp" || nil,
        private_key:         nil,
        server_host:         'localhost',
        server_port:         ENV['PORT'],
        hidden_service_port: 80,
        tor_control_port:    rand(10000..65000)
      }.merge(options)

      raise ArgumentError, "No tor executable found" unless parsed_options[:tor_executable]
      raise ArgumentError, "temp_dir #{parsed_options[:temp_dir]} does not exist or is not writable" unless (
        File.writable? parsed_options[:temp_dir] or
        FileUtils.mkdir_p parsed_options[:temp_dir])
      raise ArgumentError, "Private key is not a valid 1024 bit RSA private key" unless (
        OpenSSL::PKey::RSA.new(parsed_options[:private_key]).private? and
        OpenSSL::PKey::RSA.new(parsed_options[:private_key]).n.num_bits == 1024)
      raise ArgumentError, "Must provide option: #{parsed_options.key(nil).to_s}" if parsed_options.values.include? nil

      return parsed_options
    end

    def generate_tor_config
      tor_config = {
        DataDirectory:     "#{@base_dir}/data",
        ControlPort:       "#{@options[:tor_control_port]}",
        HiddenServiceDir:  "#{@base_dir}/hidden_service",
        HiddenServicePort: "#{@options[:hidden_service_port]} #{@options[:server_host]}:#{@options[:server_port]}",
        PidFile:           "#{@base_dir}/pid",
        RunAsDaemon:       1,
        SocksPort:         0
      }

      begin
        FileUtils.mkdir_p tor_config[:DataDirectory]
        FileUtils.mkdir_p tor_config[:HiddenServiceDir]
        File.write("#{tor_config[:HiddenServiceDir]}/private_key", @options[:private_key])
        FileUtils.chmod 0700, tor_config[:HiddenServiceDir]
        FileUtils.chmod 0600, "#{tor_config[:HiddenServiceDir]}/private_key"

        File.write(
          "#{@base_dir}/torrc",
          tor_config.map{|k,v| "#{k} #{v}"}.join("\n"))
      rescue => e
        raise "Error creating configuration: #{e}"
      end

      return true
    end

    def log_message(message)
      $stdout.puts "Tor::HiddenService: [#{@options[:tor_control_port]}]: #{message}"
    end

    def log_error(message)
      $stderr.puts "Tor::HiddenService: [#{@options[:tor_control_port]}]: ERROR: #{message}"
    end

  end
end
