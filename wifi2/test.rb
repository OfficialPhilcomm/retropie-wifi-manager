require "curses"
require_relative "./key.rb"
require_relative "./keyboard.rb"

include Curses

ssid_regex = /\s*ESSID:"(?<ssid>[A-Za-z0-9-]+)"/
WIFI_SSIDS = `iwlist wlan0 scan | grep ESSID`
  .split("\n")
  .map do |line|
    match = ssid_regex.match(line)
    next unless match
    match[:ssid]
  end
  .select do |ssid|
    ssid
  end

@state = 0

@index = 0

@selected_ssid = nil
@keyboard = Keyboard.new()

def draw_list(window)
  window << "Found #{WIFI_SSIDS.size} access points:\n"

  WIFI_SSIDS.each_with_index do |e, i|
    if @index == i
      window.attron(color_pair(1)) {
        window << "  #{e}"
      }
    else
      window << "  #{e}"
    end
    clrtoeol
    window << "\n"
  end
end

def draw_password_page(window)
  window << "Enter password for #{@selected_ssid}\n\n"

  @keyboard.draw(window)
end

def draw(window)
  window.setpos(0,0)

  draw_list(window) if @state == 0

  draw_password_page(window) if @state == 1

  window.refresh
end

def input(window)
  key = Key.get(window.getch)
  if @state == 0
    case key
    when Key::UP
      @index -= 1
    when Key::DOWN
      @index += 1
    when Key::ENTER
      @state = 1
      @selected_ssid = WIFI_SSIDS[@index]
    when Key::BACK then exit 0
    end
    @index = [@index, 0, WIFI_SSIDS.size - 1].sort[1]
  elsif @state == 1
    case key
    when Key::UP
      @keyboard.up
    when Key::DOWN
      @keyboard.down
    when Key::LEFT
      @keyboard.left
    when Key::RIGHT
      @keyboard.right
    when Key::ENTER
      @keyboard.press
    when Key::BACK then exit 0
    end
  end
end

def compute
end

begin
  init_screen
  start_color
  curs_set(0)
  noecho
  init_pair(1, 1, 0)

  window = Curses::Window.new(0, 0, 1, 2)
  window.keypad true

  loop do
    draw(window)
    input(window)
    compute()
  end
ensure
  close_screen
end
