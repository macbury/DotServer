
=begin
at_exit do
  if Server.env != "test"
    if $!.nil? || $!.is_a?(SystemExit) && $!.success?
      Log.server.info "Finished..."
    elsif defined?(Log)
      Log.critical.info $!.to_s
      Log.critical.info $!.backtrace.join("\n")
      Server.context.stop if Server.context
    end
  end
end
=end