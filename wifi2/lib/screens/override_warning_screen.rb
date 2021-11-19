module Screens
  class OverrideWarningScreen
    def initialize(selected_ssid)
      @selected_ssid = selected_ssid

      @confirm = nil
      @index = 0
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "That network is already saved, it will be overwritten. Ya sure?\n\n"

      if @index == 0
        window.attron(color_pair(COLOR_RED)) {
          window << "Return"
        }
      else
        window << "Return"
      end

      window << "   "

      if @index == 1
        window.attron(color_pair(COLOR_RED)) {
          window << "Continue"
        }
      else
        window << "Continue"
      end
    end

    def input(window)
      key = Key.get(window.getch)

      case key
      when Key::LEFT
        @index = 0
      when Key::RIGHT
        @index = 1
      when Key::ENTER
        @confirm = true
      when Key::BACK then exit 0
      end
    end

    def compute
    end

    def resolve
      if @confirm
        if @index == 1
          return Screens::EnterWifiPasswordScreen.new(@selected_ssid)
        else
          return Screens::WifiSelectionScreen.new()
        end
      end
    end
  end
end
