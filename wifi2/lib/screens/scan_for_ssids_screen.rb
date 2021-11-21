module Screens
  class ScanForSSIDsScreen
    SSID_REGEX = /\s*ESSID:"(?<ssid>.+)"/
    
    def initialize
      @ssids = nil
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Scanning for SSIDs, please stand by..."

      window.refresh
    end

    def input(window)
    end

    def compute
      @access_points = Network::Wifi.instance.access_points
    end

    def resolve
      if @access_points
        return WifiSelectionScreen.new(
          @access_points
        )
      end
    end
  end
end
