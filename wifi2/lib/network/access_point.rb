module Network
  class AccessPoint
    attr_reader :ssid, :frequency

    def initialize(ssid, frequency)
      @ssid = ssid
      @frequency = frequency
    end
end
