require "ncurses"
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
      Ncurses.endwin
      @interface_thread.exit
      @interface_thread = nil
    end
  end

  def initUI
    Ncurses.initscr
    Ncurses.curs_set 0
    Ncurses.cbreak
    Ncurses.noecho
    Ncurses.scrollok(Ncurses.stdscr, true)
    Ncurses.keypad(Ncurses.stdscr, true)
    Ncurses.clear
    updateUI
    @refresh_timer = EventMachine::PeriodicTimer.new(1) { updateUI }
  end

  def updateUI
    begin
      render_ui
    rescue Exception => e
      Ncurses.clear
      Ncurses.endwin
      puts e.to_s
      puts e.backtrace.join "\n"
      @server.stop
    end
  end

  def render_ui
    Ncurses.move 0,0
    Ncurses.addstr("Hello at D.T!")
    Ncurses.move 1,0
    Ncurses.addstr("Current server time: #{Time.now.to_s}")
    Ncurses.refresh
  end
end