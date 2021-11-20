module Screens
  class WifiSelectionScreen
    def initialize(ssids)
      @config = Config.new()

      @ssids = ssids
      
      connected_ssid_regex = /[A-Za-z0-9]+\s+ESSID:"(?<ssid>[A-Za-z0-9-]+)"/
      @connected_ssids = `iwgetid`
        .split("\n")
        .map do |line|
          match = connected_ssid_regex.match(line)
          next unless match
          match[:ssid]
        end
        .select do |ssid|
          ssid
        end
      
      @wifi_index = 0
      @option_index = 0
      
      @selected_ssid = nil
      @finished = false
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Found #{@ssids.size} access points:\n"

      @ssids.each_with_index do |ssid, i|
        if @wifi_index == i && !@selected_ssid
          window.attron(color_pair(COLOR_RED)) {
            window << " »  "
          }
        else
          window << "   "
        end
        
        if @connected_ssids.include? ssid
          window.attron(color_pair(COLOR_GREEN)) {
            window << "#{ssid}"
          }
        elsif @config.cells.map {|c| c.ssid}.include? ssid
          window.attron(color_pair(COLOR_BLUE)) {
            window << "#{ssid}"
          }
        else
          window << "#{ssid}"
        end

        if @selected_ssid && @wifi_index == i
          if @option_index == 0
            window.attron(color_pair(COLOR_RED)) {
              window << "\n    »  Connect"
            }
          else
            window << "\n      Connect"
          end

          selected_is_saved = @config.cells.map {|c| c.ssid}.include?(@ssids[@wifi_index])

          if selected_is_saved
            if @option_index == 1
              window.attron(color_pair(COLOR_RED)) {
                window << "\n    »  Delete"
              }
            else
              window << "\n      Delete"
            end

            if @option_index == 2
              window.attron(color_pair(COLOR_RED)) {
                window << "\n    »  Prioritize"
              }
            else
              window << "\n      Prioritize"
            end
          end

          window << "\n"
        end

        clrtoeol
        window << "\n"
      end

      bottom_y = window.maxy() - 2
      window.setpos(bottom_y, 0)
      window.attron(color_pair(COLOR_GREEN)) {
        window << "████ Already connected\n"
      }
      window.attron(color_pair(COLOR_BLUE)) {
        window << "████ Saved"
      }

      window.refresh
    end

    def input(window)
      key = Key.get(window.getch)

      case key
      when Key::UP
        if @selected_ssid
          @option_index -= 1
        else
          @wifi_index -= 1
        end
      when Key::DOWN
        if @selected_ssid
          @option_index += 1
        else
          @wifi_index += 1
        end
      when Key::ENTER
        if @selected_ssid
          @finished = true
        else
          @selected_ssid = @ssids[@wifi_index]
        end
      when Key::BACK
        if @selected_ssid
          @selected_ssid = nil
        else
          exit 0
        end
      end
    end

    def compute
      @wifi_index = [@wifi_index, 0, @ssids.size - 1].sort[1]
      @option_index = [@option_index, 0, 2].sort[1]

      selected_is_saved = @config.cells.map {|c| c.ssid}.include?(@ssids[@wifi_index])
      @option_index = 0 if @option_index > 0 && !selected_is_saved
    end

    def resolve
      if @finished
        network_exists = @config.cells.select do |cell|
          cell.ssid == @selected_ssid
        end.any?
        if network_exists
          case @option_index
          when 0
            return Screens::OverrideWarningScreen.new(@selected_ssid)
          when 1
            return Screens::DeleteScreen.new(@selected_ssid)
          when 2
            return Screens::PrioritizeScreen.new(@selected_ssid)
          end
        else
          return Screens::EnterWifiPasswordScreen.new(@selected_ssid)
        end
      end
    end
  end
end
