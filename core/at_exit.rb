
at_exit do
  if $!.nil? || $!.is_a?(SystemExit) && $!.success?
    Server.logger.info "Finished..."
  else
    Server.logger.error $!.to_s
    Server.logger.error $!.backtrace.join("\n")
    $server.stop
  end
end