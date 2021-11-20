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

  window = Curses::Window.new(0, 0, 1, 2)
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
