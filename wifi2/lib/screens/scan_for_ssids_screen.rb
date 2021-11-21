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
      @ssids = `iwlist wlan0 scan | grep ESSID`
        .split("\n")
        .map do |line|
          match = SSID_REGEX.match(line)
          next unless match
          match[:ssid]
        end
        .select do |ssid|
          ssid
        end
    end

    def resolve
      if @ssids
        return WifiSelectionScreen.new(@ssids)
      end
    end
  end
end
