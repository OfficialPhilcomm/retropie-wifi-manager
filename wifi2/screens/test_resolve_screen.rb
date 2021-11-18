module Screens
  class TestResolveScreen
    def initialize(ssid, password)
      @ssid = ssid
      @password = password

      wpa_passphrase_output = `wpa_passphrase "#{ssid}" "#{password}"`

      open('/etc/wpa_supplicant/wpa_supplicant.conf', 'a') do |f|
        f << wpa_passphrase_output
      end
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Wifi: #{@ssid}\n\n"
      window << "Entered password: #{@password}"

      window.refresh
    end

    def input(window)
      key = window.getch
      exit 0
    end

    def compute
    end

    def resolve
    end
  end
end
