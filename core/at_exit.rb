
at_exit do
  if Server.env != "test"
    if $!.nil? || $!.is_a?(SystemExit) && $!.success?
      Log.server.info "Finished..."
    else
      Log.critical.info $!.to_s
      Log.critical.info $!.backtrace.join("\n")
      $server.stop if $server
    end
  end
end