require "ncurses"

class DebugInterface
  def initialize(server)
    @server     = server
    @start_time = Time.now
  end

  def start
    @interface_thread ||= Thread.new { initUI }
  end

  def stop
    if @interface_thread
      @refresh_timer.cancel if @refresh_timer
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
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
    init_stat_window
    updateUI
    @refresh_timer = EventMachine::PeriodicTimer.new(1) { updateUI }
  end

  def init_stat_window
    @stat_window = Ncurses::WINDOW.new(6, 80, 0, 0)
    @stat_window.bkgd(Ncurses.COLOR_PAIR(3))
    @stat_window.box(0, 0)
    @stat_window.mvaddstr(0, 0, "DoT server: running ")
    @stat_window.wrefresh()
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
    @stat_window.move 1,2
    @stat_window.addstr "time: #{Time.now.to_s}"
    @stat_window.move 2,2
    @stat_window.addstr "uptime: #{self.uptime} min"
    @stat_window.move 3,2
    @stat_window.addstr "environment: #{Server.env}, ip: #{Server.listen}, port: #{Server.port}"
    @stat_window.move 4,2
    @stat_window.addstr "connections: #{Server.connections.size}, messages: #{Server.messages.size}"
    @stat_window.wrefresh
  end

  def uptime
    (Time.now - @start_time).round / 60
  end
end