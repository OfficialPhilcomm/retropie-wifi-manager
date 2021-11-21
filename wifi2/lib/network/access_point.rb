module Network
  class AccessPoint
    attr_reader :ssid, :frequency

    def initialize(ssid, frequency)
      @ssid = ssid
      @frequency = frequency
    end

    def five_ghz?
      @frequency == 5
    end
  end
end
