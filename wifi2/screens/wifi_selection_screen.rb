module Screens
  class WifiSelectionScreen
    def initialize
      ssid_regex = /\s*ESSID:"(?<ssid>[A-Za-z0-9-]+)"/
      @ssids = `iwlist wlan0 scan | grep ESSID`
        .split("\n")
        .map do |line|
          match = ssid_regex.match(line)
          next unless match
          match[:ssid]
        end
        .select do |ssid|
          ssid
        end
      
      connected_ssid_regex = /[A-Za-z0-9]+\s+ESSID:"(?<ssid>[A-Za-z0-9-]+)"/
      @connected_ssids = `iwgetid`
        .split("\n")
        .map do |line|
          match = connected_ssid_regex.match(line)
          next unless match
          match[:ssid]
        end
        .select do |ssid|
          ssid
        end
      
      @index = 0
      @selected_ssid = nil
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Found #{@ssids.size} access points:\n"

      @ssids.each_with_index do |ssid, i|
        if @index == i
          window.attron(color_pair(1)) {
            window << " »  "
          } if @index == i
        else
          window << "   "
        end
        
        if @connected_ssids.include? ssid
          window.attron(color_pair(2)) {
            window << "#{ssid}"
          }
        else
          window << "#{ssid}"
        end

        clrtoeol
        window << "\n"
      end

      window << "\n"
      window.attron(color_pair(2)) {
        window << "████ Already connected"
      }

      window.refresh
    end

    def input(window)
      key = Key.get(window.getch)

      case key
      when Key::UP
        @index -= 1
      when Key::DOWN
        @index += 1
      when Key::ENTER
        @selected_ssid = @ssids[@index]
      when Key::BACK then exit 0
      end
      @index = [@index, 0, @ssids.size - 1].sort[1]
    end

    def compute
    end

    def resolve
      if @selected_ssid
        return Screens::EnterWifiPasswordScreen.new(@selected_ssid)
      end
    end
  end
end
