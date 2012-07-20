class AbstractLogger

  attr_accessor :copy_to_stdout

  @severities = {
    :debug   => Logger::DEBUG,
    :info    => Logger::INFO,
    :warn    => Logger::WARN,
    :error   => Logger::ERROR,
    :fatal   => Logger::FATAL,
    :unknown => Logger::UNKNOWN
  }

  @silencer = true

  class << self
    attr_reader :severities
    attr_accessor :silencer
  end

  # Optional log path, defaults to
  # <em>DAEMON_ROOT/log/DAEMON_ENV.log</em>
  def initialize( log_path = nil )
    @logger_file = log_path || "./log/server.log"
    @backend = :logger

    @copy_to_stdout = false
  end

  # Silence the logger for the duration of the block.
  def silence( temporary_level = :error )
    if self.class.silencer
      begin
        old_level, self.level = self.level, temporary_level
        yield self
      ensure
        self.level = old_level
      end
    else
      yield self
    end
  end

  # Write unformatted message to logging device, mostly useful for Logger interface
  # compatibility and debugging soap4r (possibly others)
  def <<( msg ) #:nodoc:
    self.logger.write( msg ) if self.logger && self.logger.respond_to?( :write )
  end

  def debug( msg = nil, &block )
    add( :debug, msg, &block )
  end

  def debug?
    self.level == :debug
  end

  def info( msg = nil, &block )
    add( :info, msg, &block )
  end

  def info?
    self.level == :info
  end

  def warn( msg = nil, &block )
    add( :warn, msg, &block )
  end

  def warn?
    self.level == :warn
  end

  def error( msg = nil, &block )
    add( :error, msg, &block )
  end

  def error?
    self.level == :error
  end

  def fatal( msg = nil, &block )
    add( :fatal, msg, &block )
  end

  def fatal?
    self.level == :fatal
  end

  def unknown( msg = nil, &block )
    add( :unknown, msg, &block )
  end

  def unknown?
    self.level == :unknown
  end

  # Conveniently log an exception and the backtrace
  def exception( e )
    message = "EXCEPTION: #{e.message}: #{clean_trace( e.backtrace )}"
    self.add( :error, message, true )
  end

  def add( severity, message = nil, skip_caller = false, &block )
    message = yield if block_given?

    message = "#{called(caller)}: #{message}" unless skip_caller

    self.logger.add( self.class.severities[ severity ] ) { message }

    DebugInterface.push_log(message) if self.copy_to_stdout
  end

  def level
    self.class.severities.invert[ @logger.level ]
  end

  def level=( level )
    level = ( Symbol === level ? self.class.severities[ level ] : level )
    self.logger.level = level
  end

  def logger
    @logger ||= create_logger
  end

  def logger=( logger )
    if logger.is_a?( Symbol )
      @backend = logger
      @logger.close rescue nil
      @logger = create_logger
    else
      @logger.close rescue nil
      @logger = logger
    end
  end

  def clean_trace( trace )
    trace = trace.map { |l| l.gsub(Server.root, '') }
    trace = trace.reject { |l| l =~ /gems\/daemon[\-_]kit/ }
    trace = trace.reject { |l| l =~ /vendor\/daemon[\-_]kit/ }
    trace.join("\n")
  end

  def close
    case @backend
    when :logger
      self.logger.close
      @logger = nil
    end
  end

  private

  def called( trace )
    l = trace.detect('unknown:0') { |l| l.index('abstract_logger.rb').nil? }
    file, num, _ = l.split(':')

    [ File.basename(file), num ].join(':')
  end

  def create_logger
    create_standard_logger
  end

  def create_standard_logger
    log_path = File.dirname( @logger_file )
    unless File.directory?( log_path )
      begin
        FileUtils.mkdir_p( log_path )
      rescue
        STDERR.puts "#{log_path} not writable, using STDERR for logging"
        @logger_file = STDERR
      end
    end

    l = Logger.new( @logger_file )
    l.formatter = Formatter.new
    l.progname = File.basename($0)
    l
  end

  class Formatter

    # YYYY:MM:DD HH:MM:SS.MS daemon_name(pid) level: message
    @format = "%s %s(%d) [%s] %s\n"

    class << self
      attr_accessor :format
    end

    def call(severity, time, progname, msg)
      self.class.format % [ format_time( time ), progname, $$, severity, msg.to_s ]
    end

    private

    def format_time( time )
      time.strftime( "%Y-%m-%d %H:%M:%S." ) + time.usec.to_s
    end
  end
end