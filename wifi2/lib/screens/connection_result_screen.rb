module Screens
  class ConnectionResultScreen
    CONNECTED_SSIDS_REGEX = /[A-Za-z0-9]+\s+ESSID:"(?<ssid>[A-Za-z0-9-]+)"/

    def initialize
      match = CONNECTED_SSIDS_REGEX.match(`iwgetid`)
      @connected_ssid = if match
        match[:ssid]
      else
        nil
      end
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      if @connected_ssid
        window << "Connected WiFi: #{@connected_ssid}\n\n" if @connected_ssid
      else
        window << "Not connected to any WiFi currently\n\n" if !@connected_ssid
      end
      window << "Press any key to exit"

      window.refresh
    end

    def input(window)
      window.getch
      exit 0
    end

    def compute
    end

    def resolve
    end
  end
end
