require "ncurses"

$debug_log = []
49.times { $debug_log << "" }

class DebugInterface
  LogLinesLimit = 50
  InformationWindowHeight = 6
  attr_accessor :mutex

  def self.push_log(msg)
    $debug_log << msg
    $debug_log.shift if $debug_log.size > DebugInterface::LogLinesLimit
  end

  def initialize(server)
    @server     = server
    @start_time = Time.now
    self.mutex  = Mutex.new
    $debug_interface = self
  end

  def start
    @interface_thread ||= Thread.new { initUI }
    Log.server.copy_to_stdout = true
  end

  def stop
    if @interface_thread
      Ncurses.echo
      Ncurses.nocbreak
      Ncurses.nl
      Ncurses.endwin
      @interface_thread.exit
      @input_thread.exit
      @interface_thread = nil
      @input_thread = nil
    end
  end

  def initUI
    @window = Ncurses.initscr
    Ncurses.curs_set 0
    Ncurses.cbreak
    Ncurses.noecho
    Ncurses.scrollok(Ncurses.stdscr, true)
    Ncurses.keypad(Ncurses.stdscr, true)
    Ncurses.clear
    
    init_windows
    updateStateUI
    updateLogUI

    @input_thread     ||= Thread.new { initInput }

    while true
      updateStateUI
      updateLogUI

      sleep 1
    end
  end

  def init_windows
    rows         = Ncurses.getmaxy(@window)
    Log.server.info "Rows #{rows}"
    @stat_window = Ncurses::WINDOW.new(InformationWindowHeight, Ncurses.COLS()/2, 0, 0)
    @log_window  = Ncurses::WINDOW.new(rows-InformationWindowHeight, Ncurses.COLS(), InformationWindowHeight, 0)
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

  def updateStateUI
    @stat_window.bkgd(Ncurses.COLOR_PAIR(3))
    @stat_window.box(0, 0)
    @stat_window.mvaddstr(0, 0, ".dot server: running ")
    @stat_window.move 1,2
    @stat_window.addstr "time: #{Time.now.to_s}"
    @stat_window.move 2,2
    @stat_window.addstr "uptime: #{self.uptime} min"
    @stat_window.move 3,2
    @stat_window.addstr "environment: #{Server.env}, ip: #{Server.listen}, port: #{Server.port}"
    @stat_window.move 4,2
    @stat_window.addstr "connections: #{Server.connections.size}"
    @stat_window.wrefresh
  end

  def updateLogUI
    @log_window.clear
    @log_window.bkgd(Ncurses.COLOR_PAIR(3))
    @log_window.box(0, 0)
    @log_window.mvaddstr(0, 0, " Logs ")
    self.mutex.synchronize do 
      rows = Ncurses.getmaxy(@window) - InformationWindowHeight
      log_lines = rows-2
      lines = $debug_log[-log_lines..-1] || []
      width = Ncurses.COLS() - 6
      lines.each_with_index do |line, index|
        if line.size < width
          (line.size - width).times { line += " " }
        else
          line = line[0..width] 
        end
        @log_window.mvaddstr(index+1, 2, line)
      end
    end

    @log_window.wrefresh
  end

  def initInput
    while true
      char = @window.getch()
      Log.server.info char
      EM.next_tick { Server.context.reload! } if char == 114 # pressed r
      EM.next_tick { Server.context.switch_to_console! } if char == 99 # pressed c
    end
  end

  def uptime
    (Time.now - @start_time).round / 60
  end
end