module Screens
  class ManualSSIDScreen
    def initialize
      @keyboard = Keyboard.new("Enter SSID")

      @finished = false

      @error = nil
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      @keyboard.draw(window)
      
      window << "\n#{@error}\n\n" if @error
      
      window.refresh
    end

    def input(window)
      key = Key.get(window.getch)

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
        if @keyboard.get_current_key == "Connect"
          @finished = true
        else
          @keyboard.press
        end
      when Key::BACK
        @keyboard.backspace
      end
    end

    def compute
      @error = nil

      if @finished && @keyboard.current_input.length < 1
        @error = "SSID must be at least 1 character long"
        @finished = false
      end
    end

    def resolve
      if @finished
        return Screens::EnterWifiPasswordScreen.new(@keyboard.current_input)
      end
    end
  end
end
