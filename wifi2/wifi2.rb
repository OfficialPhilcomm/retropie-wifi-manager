require "curses"
require 'require_all'
require_rel "lib"

include Curses

@screen = Screens::ScanForSSIDsScreen.new()

DEFAULT_COLOR = 1
COLOR_RED = 2
COLOR_GREEN = 3
COLOR_BLUE = 4

begin
  init_screen
  start_color
  curs_set(0)
  noecho
  
  init_pair(DEFAULT_COLOR, 0, 7)
  init_pair(COLOR_RED, 1, 7)
  init_pair(COLOR_GREEN, 2, 7)
  init_pair(COLOR_BLUE, 6, 7)
  init_pair(5, 7, 4)

  max_x = Curses.cols
  max_y = Curses.lines
  padding_x = [0, max_x, max_x - 50].sort[1]
  padding_y = [0, max_y, max_y - 20].sort[1]

  background_window = Curses::Window.new(0, 0, 0, 0)
  background_window.bkgdset(color_pair(5))
  background_window.clear
  background_window.refresh

  window = Curses::Window.new(
    max_y - padding_y,
    max_x - padding_x,
    padding_y / 2,
    padding_x / 2
  )
  window.bkgdset(color_pair(DEFAULT_COLOR))
  window.keypad true

  loop do
    @screen.draw(window)
    @screen.input(window)
    @screen.compute()

    resolve = @screen.resolve
    if resolve
      @screen = resolve
    end
  end
ensure
  close_screen
end
