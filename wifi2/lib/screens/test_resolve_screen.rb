module Screens
  class TestResolveScreen
    def initialize(ssid, password)
      @ssid = ssid
      @password = password
      
      wpa_passphrase_output = `wpa_passphrase "#{ssid}" "#{password}"`
      
      @cell = Cell.new(wpa_passphrase_output)
      if @cell.valid?
        config = Config.new()
        
        config.cells.each do |cell|
          cell.set_priority false
        end
        @cell.set_priority true

        cells_to_remove = config.cells.select do |cell|
          cell.ssid == @cell.ssid
        end

        config.remove_cells cells_to_remove

        config.cells.append(@cell)
        
        config.save!
        `wpa_cli -i wlan0 reconfigure`
      end

    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Wifi: #{@ssid}\n\n"
      window << "Entered password: #{@password}"
      window << "\n\nNetwork invalid" unless @cell.valid?

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
