module Screens
  class ConnectingScreen
    def initialize(ssid, password)
      @ssid = ssid
      @password = password

      @finished = false
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      wpa_passphrase_output = `wpa_passphrase "#{@ssid}" "#{@password}"`
      @cell = Cell.new(wpa_passphrase_output)

      window << "Wifi: #{@ssid}\n"
      window << "Entered password: #{@password}"
      
      window << "\n\nNetwork invalid (password needs to be at least 8 characters)" unless @cell.valid?

      window << "\n\nSaving config and restarting network" if @cell.valid? && !@finished
      window << "\n\nConfig saved and network restarted" if @cell.valid? && @finished

      window.refresh
    end

    def input(window)
    end

    def compute
      if @cell.valid?
        config = Config.new()
        
        config.set_priority @cell
        
        cells_to_remove = config.cells.select do |cell|
          cell.ssid == @cell.ssid
        end
        
        config.remove_cells cells_to_remove
        
        config.cells.append(@cell)
        
        config.save!
        `wpa_cli -i wlan0 reconfigure`
      end
      
      sleep 3
      @finished = true
    end

    def resolve
      Screens::ConnectionResultScreen.new() if @finished
    end
  end
end
