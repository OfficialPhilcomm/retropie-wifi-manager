module Screens
  class DeleteScreen
    def initialize(selected_ssid)
      @selected_ssid = selected_ssid

      @confirm = false
      @finished = false

      @index = 0
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Sure you wanna delete this network? You will have to reenter the password\n\n"

      @padding = (window.maxx - 8) / 2

      window << "".ljust(@padding)

      if @index == 0
        window.attron(color_pair(COLOR_RED)) {
          window << "No"
        }
      else
        window << "No"
      end

      window << "   "

      if @index == 1
        window.attron(color_pair(COLOR_RED)) {
          window << "Yes"
        }
      else
        window << "Yes"
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
        if @index == 1
          @confirm = true
        else
          @finished = true
        end
      when Key::BACK
        @finished = true
      end
    end
    
    def compute
      if @confirm
        config = Network::Config.new()
        
        cells_to_remove = config.cells.select do |cell|
          cell.ssid == @selected_ssid
        end
        
        config.remove_cells cells_to_remove
        
        config.save!
        `wpa_cli -i wlan0 reconfigure`

        sleep 10

        @finished = true
      end
    end

    def resolve
      if @finished
        return Screens::ScanForSSIDsScreen.new()
      end
    end
  end
end
