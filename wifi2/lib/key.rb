require "curses"

class Key
  UP = 0
  DOWN = 1
  LEFT = 2
  RIGHT = 3
  ENTER = 4
  BACK = 5

  def self.get(getch)
    case getch
    when KEY_UP
      return UP
    when KEY_DOWN
      return DOWN
    when KEY_LEFT
      return LEFT
    when KEY_RIGHT
      return RIGHT
    when 10
      return ENTER
    when " "
      return BACK
    end
  end
end
