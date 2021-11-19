module Screens
  class PrioritizeScreen
    def initialize(selected_ssid)
      @selected_ssid = selected_ssid

      @index = 0
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Prioritize #{@selected_ssid}?\n\n"

      if @index == 0
        window.attron(color_pair(COLOR_RED)) {
          window << "Yes"
        }
      else
        window << "Yes"
      end

      window << "   "

      if @index == 1
        window.attron(color_pair(COLOR_RED)) {
          window << "No"
        }
      else
        window << "No"
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
        if @index == 0
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
        config = Config.new()
        
        cell = config.cells.select do |cell|
          cell.ssid == @selected_ssid
        end.first

        @finished = true unless cell
        return unless cell

        config.set_priority cell
        
        config.save!
        `wpa_cli -i wlan0 reconfigure`

        @finished = true
      end
    end

    def resolve
      if @finished
        return Screens::WifiSelectionScreen.new()
      end
    end
  end
end
