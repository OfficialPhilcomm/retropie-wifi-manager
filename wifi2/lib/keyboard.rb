class Keyboard
  attr_accessor :current_input

  KEYBOARD = [
    ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
    ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
    ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
    ["z", "x", "c", "v", "b", "n", "m"],
    ["!", '"', "§", "$", "%", "&", "/", "\\", "(", ")", "="],
    ["?", "+", "*", "#", "'", ".", ":", ",", ";", "-", "_"],
    ["@", "[", "]", "^", "~", "`", "|", "<", ">"],
    ["Shift", "←", "Connect", "Exit"]
  ]

  def initialize(prefix)
    @prefix = prefix
    @shift = false
    @selected_key = [0, 0]
    @current_input = ""
  end

  def up
    limit_y = KEYBOARD.size - 1

    @selected_key[1] = [@selected_key[1] - 1, 0, limit_y].sort[1]

    if @selected_key[0] > KEYBOARD[@selected_key[1]].size - 1
      @selected_key[0] = KEYBOARD[@selected_key[1]].size - 1
    end
  end

  def down
    limit_y = KEYBOARD.size - 1

    @selected_key[1] = [@selected_key[1] + 1, 0, limit_y].sort[1]

    if @selected_key[0] > KEYBOARD[@selected_key[1]].size - 1
      @selected_key[0] = KEYBOARD[@selected_key[1]].size - 1
    end
  end

  def left
    limit_x = KEYBOARD[@selected_key[1]].size - 1

    @selected_key[0] = [@selected_key[0] - 1, 0, limit_x].sort[1]
  end

  def right
    limit_x = KEYBOARD[@selected_key[1]].size - 1

    @selected_key[0] = [@selected_key[0] + 1, 0, limit_x].sort[1]
  end

  def backspace
    @current_input = @current_input[0...-1]
  end

  def press
    x, y = @selected_key
    input = KEYBOARD[y][x]
    if input == "Shift"
      @shift = !@shift
    elsif input == "←"
      backspace
    elsif input == "Exit"
      exit 0
    else
      if @shift
        @current_input += input.capitalize
      else
        @current_input += input
      end
    end
  end

  def get_current_key()
    x, y = @selected_key
    KEYBOARD[y][x]
  end

  def draw(window)
    window << "#{@prefix}: #{@current_input}\n\n"

    selected_x, selected_y = @selected_key

    KEYBOARD.each_with_index do |row, row_index|
      row.each_with_index do |key, key_index|
        if selected_y == row_index && selected_x == key_index
          window.attron(color_pair(COLOR_RED)) {
            if @shift
              window << key.capitalize
            else
              window << key
            end
          }
        else
          if @shift
            window << key.capitalize
          else
            window << key
          end
        end

        unless row.length - 1 == key_index
          window << " "
        end
      end

      window << "\n"

      clrtoeol
    end
  end
end
