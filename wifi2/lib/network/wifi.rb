require "singleton"

module Network
  class Wifi
    include Singleton

    ACCESS_POINT_REGEX = /(?<network>Address:\s*(.+)\sFrequency:\s*(.+)\sQuality=\s*(.+)\sEncryption\s*(.+)\sESSID:\s*"(.+)"\s)/
    NETWORK_REGEX = /Address:\s*(?<mac>([0-9A-F]{2}[:]){5}([0-9A-F]{2}))\sFrequency:(?<frequency>.*)\sQuality=(?<quality>.*)\sEncryption\s(?<encryption>.*)\sESSID:"(?<ssid>.*)"/
    FREQUENCY_REGEX = /(?<frequency>\d[.]\d+)/
    
    def access_points
      if !@last_refresh
        @access_points = parse_access_points
      else
        elapsed_seconds = (Time.now - @last_refresh)

        @access_points = parse_access_points if elapsed_seconds > 15
      end

      @access_points
    end

    def parse_access_points
      scan_output = `iwlist wlan0 scan | grep -o '\\(ESSID:\\|Address:\\|Frequency:\\|Quality=\\|Encryption key:\\).*'`

      scan_output.scan(ACCESS_POINT_REGEX).flatten.map do |access_point|
        match = NETWORK_REGEX.match(access_point)
        next unless match

        frequency = Network::Wifi.normalize_frequency(FREQUENCY_REGEX.match(match[:frequency])[:frequency].to_f)

        @last_refresh = Time.now

        Network::AccessPoint.new(match[:ssid], frequency)
      end
    end

    def reset_cache
      @last_refresh = nil
    end

    def self.normalize_frequency(freq)
      diff_to_2_4 = (freq - 2.4).abs
      diff_to_5 = (freq - 5).abs

      if diff_to_2_4 < diff_to_5
        2.4
      else
        5
      end
    end
  end
end
