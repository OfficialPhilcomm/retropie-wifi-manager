module Screens
  class EnterWifiPasswordScreen

    def initialize(wifi, password=nil)
      @wifi = wifi
      @keyboard = Keyboard.new()
      @keyboard.current_input = password if password
      @connect = false
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Enter password for #{@wifi}\n\n"

      @keyboard.draw(window)

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
          @connect = true
        else
          @keyboard.press
        end
      when Key::BACK
        @keyboard.backspace
      end
    end

    def compute
    end

    def resolve
      if @connect
        if @keyboard.current_input.length == 0 || @keyboard.current_input.length >= 8
          return Screens::ConnectingScreen.new(@wifi, @keyboard.current_input)
        else
          return Screens::PasswordErrorScreen.new(@ssid, @keyboard.current_input)
        end
      end
    end
  end
end
