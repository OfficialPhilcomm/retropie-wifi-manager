module Network
  class Config
    attr_reader :cells

    COUNTRY_REGEX = /country=(?<country>[A-Z]{2})/
    UPDATE_CONFIG_REGEX = /update_config=(?<update_config>[0-1])/
    NETWORK_REGEX = /(?<network>network\s*=\s*{(?:\s*[^}]*){2}})/x

    def initialize
      file_output = `cat /etc/wpa_supplicant/wpa_supplicant.conf`
      
      country_match = COUNTRY_REGEX.match(file_output)
      @country = country_match[:country] if country_match
      
      update_config_match = UPDATE_CONFIG_REGEX.match(file_output)
      @update_config = update_config_match[:update_config] if country_match

      @cells = file_output.scan(NETWORK_REGEX).flatten.map do |network|
        Cell.new(network)
      end
    end

    def set_priority(cell)
      @cells.each do |c|
        c.set_priority false
      end
      cell.set_priority true
    end

    def remove_cells(cells)
      @cells = @cells.select do |cell|
        !cells.include? cell
      end
    end
    
    def to_s
      [
        "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev",
        "country=#{@country}",
        "update_config=#{@update_config}",
        ""
      ].concat(
        @cells.map do |cell|
          cell.to_s
        end
      ).join("\n")
    end

    def save!
      File.write("/etc/wpa_supplicant/wpa_supplicant.conf", to_s)
    end
  end
end
