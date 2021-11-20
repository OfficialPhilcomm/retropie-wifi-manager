require "curses"
require 'require_all'
require_rel "lib"

include Curses

@screen = Screens::ScanForSSIDsScreen.new()

COLOR_RED = 1
COLOR_GREEN = 2
COLOR_BLUE = 3

begin
  init_screen
  start_color
  curs_set(0)
  noecho
  init_pair(COLOR_RED, 1, 0)
  init_pair(COLOR_GREEN, 2, 0)
  init_pair(COLOR_BLUE, 6, 0)

  window = Curses::Window.new(0, 0, 1, 2)
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
