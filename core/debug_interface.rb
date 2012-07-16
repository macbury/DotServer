class DebugInterface

  def initialize(server)
    @server = server
  end

  def start
    @interface_thread ||= Thread.new { initUI }
  end

  def stop
    if @interface_thread
      @refresh_timer.cancel if @refresh_timer
      FFI::NCurses.endwin
      @interface_thread.exit
      @interface_thread = nil
    end
  end

  def initUI
    FFI::NCurses.initscr
    FFI::NCurses.curs_set 0
    FFI::NCurses.cbreak
    FFI::NCurses.noecho
    FFI::NCurses.scrollok(FFI::NCurses.stdscr, true)
    FFI::NCurses.keypad(FFI::NCurses.stdscr, true)
    FFI::NCurses.clear
    updateUI
    @refresh_timer = EventMachine::PeriodicTimer.new(1) { updateUI }
  end

  def updateUI
    begin
      render_ui
    rescue Exception => e
      FFI::NCurses.clear
      FFI::NCurses.endwin
      puts e.to_s
      puts e.backtrace.join "\n"
      @server.stop
    end
  end

  def render_ui
    FFI::NCurses.move 0,0
    FFI::NCurses.addstr("Hello at D.T!")
    FFI::NCurses.move 1,0
    FFI::NCurses.addstr("Current server time: #{Time.now.to_s}")
    FFI::NCurses.refresh
  end
end