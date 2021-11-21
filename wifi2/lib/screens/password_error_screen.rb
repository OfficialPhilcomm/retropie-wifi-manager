module Screens
  class PasswordErrorScreen
    def initialize(ssid, password)
      @ssid = ssid
      @password = password

      @index = 0
      @finished = false
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Password is too short. Wanna re-enter or go back to menu?\n\n"

      @padding = (window.maxx - 11) / 2

      window << "".ljust(@padding)

      if @index == 0
        window.attron(color_pair(COLOR_RED)) {
          window << "Back"
        }
      else
        window << "Back"
      end

      window << "   "

      if @index == 1
        window.attron(color_pair(COLOR_RED)) {
          window << "Menu"
        }
      else
        window << "Menu"
      end

      window.refresh
    end

    def input(window)
      key = Key.get(window.getch)

      case key
      when Key::LEFT
        @index = 0
      when Key::RIGHT
        @index = 1
      when Key::ENTER
        @finished = true
      when Key::BACK
      end
    end
    
    def compute
    end

    def resolve
      if @finished
        if @index == 0
          return Screens::EnterWifiPasswordScreen.new(@ssid, @password)
        else
          return Screens::ScanForSSIDsScreen.new()
        end
      end
    end
  end
end
