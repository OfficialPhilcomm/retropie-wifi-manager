module Network
  class Wifi
    ACCESS_POINT_REGEX = /(?<network>Address:\s*(.+)\sFrequency:\s*(.+)\sQuality=\s*(.+)\sEncryption\s*(.+)\sESSID:\s*"(.+)"\s)/
    NETWORK_REGEX = /Address:\s*(?<mac>([0-9A-F]{2}[:]){5}([0-9A-F]{2}))\sFrequency:(?<frequency>.*)\sQuality=(?<quality>.*)\sEncryption\s(?<encryption>.*)\sESSID:"(?<ssid>.*)"/
    FREQUENCY_REGEX = /(?<frequency>\d[.]\d+)/
    
    def self.access_points
      scan_output = `iwlist wlan0 scan | grep -o '\\(ESSID:\\|Address:\\|Frequency:\\|Quality=\\|Encryption key:\\).*'`

      scan_output.scan(ACCESS_POINT_REGEX).flatten.map do |access_point|
        match = NETWORK_REGEX.match(access_point)
        next unless match

        frequency = FREQUENCY_REGEX.match(match[:frequency])[:frequency].to_f

        diff_to_2_4 = (frequency - 2.4).abs
        diff_to_5 = (frequency - 5).abs

        frequency = if diff_to_2_4 < diff_to_5
          "2.4 GHz"
        else
          "5 GHz"
        end

        Network::AccessPoint.new(match[:ssid], frequency)
      end
    end
  end
end
