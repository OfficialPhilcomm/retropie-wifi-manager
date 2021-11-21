module Screens
  class WifiSelectionScreen
    def initialize(access_points)
      @config = Network::Config.new()

      @access_points = access_points
      
      connected_ssid_regex = /[A-Za-z0-9]+\s+ESSID:"(?<ssid>[A-Za-z0-9-]+)"/
      connected_freq_regex = /(?<frequency>\d[.]\d+)/

      iwgetid_ssid_match = connected_ssid_regex.match(`iwgetid`)
      iwgetid_freq_match = connected_freq_regex.match(`iwgetid --freq`)

      @connected_ssid = iwgetid_ssid_match ? iwgetid_ssid_match[:ssid] : nil
      @connected_frequency = if iwgetid_freq_match
        frequency = Network::Wifi.normalize_frequency(iwgetid_freq_match[:frequency].to_f)
      else
        nil
      end
      
      @wifi_index = 0
      @wifi_option_index = 0

      @menu_index = 0
      
      @focus = 0
      
      @selected_access_point = nil
      @finished = false
    end

    def draw(window)
      window.clear
      window.setpos(0,0)

      window << "Found #{@access_points.size} access points:\n"

      @access_points.each_with_index do |access_point, i|
        if @wifi_index == i && @focus == 0 && !@selected_access_point
          window.attron(color_pair(COLOR_RED)) {
            window << " »  "
          }
        else
          window << "   "
        end
        
        if @connected_ssid == access_point.ssid && @connected_frequency == access_point.frequency
          window.attron(color_pair(COLOR_GREEN)) {
            window << "#{access_point.ssid}"
            window << " (5GHz)" if access_point.five_ghz?
          }
        elsif @config.cells.map {|c| c.ssid}.include? access_point.ssid
          window.attron(color_pair(COLOR_BLUE)) {
            window << "#{access_point.ssid}"
            window << " (5GHz)" if access_point.five_ghz?
          }
        else
          window << "#{access_point.ssid}"
          window << " (5GHz)" if access_point.five_ghz?
        end

        if @selected_access_point == access_point
          if @wifi_option_index == 0
            window.attron(color_pair(COLOR_RED)) {
              window << "\n    »  Connect"
            }
          else
            window << "\n      Connect"
          end

          selected_is_saved = @config.cells.map {|c| c.ssid}.include?(@access_points[@wifi_index].ssid)

          if selected_is_saved
            if @wifi_option_index == 1
              window.attron(color_pair(COLOR_RED)) {
                window << "\n    »  Delete"
              }
            else
              window << "\n      Delete"
            end

            if @wifi_option_index == 2
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

      draw_bottom(window)

      window.refresh
    end

    def draw_bottom(window)
      bottom_y = window.maxy() - 5
      window.setpos(bottom_y, 0)

      if @focus == 1 && @menu_index == 0
        window.attron(color_pair(COLOR_RED)) {
          window << "Enter SSID manually\n"
        }
      else
        window << "Enter SSID manually\n"
      end

      if @focus == 1 && @menu_index == 1
        window.attron(color_pair(COLOR_RED)) {
          window << "Exit\n"
        }
      else
        window << "Exit\n"
      end

      window << "\n"

      window.attron(color_pair(COLOR_GREEN)) {
        window << "████ Already connected\n"
      }
      window.attron(color_pair(COLOR_BLUE)) {
        window << "████ Saved"
      }
    end

    def input(window)
      key = Key.get(window.getch)

      if @focus == 0
        input_wifi(key)
      else
        input_menu(key)
      end
    end

    def input_wifi(key)
      case key
      when Key::UP
        if @selected_access_point
          @wifi_option_index -= 1
        else
          @wifi_index -= 1
        end
      when Key::DOWN
        if @selected_access_point
          @wifi_option_index += 1
        else
          @wifi_index += 1
        end
      when Key::ENTER
        if @selected_access_point
          @finished = true
        else
          @selected_access_point = @access_points[@wifi_index]
        end
      when Key::BACK
        if @selected_access_point
          @selected_access_point = nil
        else
          exit 0
        end
      end
    end

    def input_menu(key)
      case key
      when Key::UP
        @menu_index -= 1
      when Key::DOWN
        @menu_index += 1
      when Key::ENTER
        @finished = true
      when Key::BACK
        exit 0
      end
    end

    def compute
      if @wifi_index >= @access_points.size
        @focus = 1
      elsif @menu_index < 0
        @focus = 0
      end

      @wifi_index = [@wifi_index, 0, @access_points.size - 1].sort[1]
      @wifi_option_index = [@wifi_option_index, 0, 2].sort[1]

      @menu_index = [@menu_index, 0, 1].sort[1]

      selected_is_saved = @config.cells.map {|c| c.ssid}.include?(@access_points[@wifi_index].ssid)
      @wifi_option_index = 0 if @wifi_option_index > 0 && !selected_is_saved
    end

    def resolve
      if @finished
        if @focus == 0
          network_exists = @config.cells.select do |cell|
            cell.ssid == @selected_access_point.ssid
          end.any?
          if network_exists
            case @wifi_option_index
            when 0
              return Screens::OverrideWarningScreen.new(@selected_access_point.ssid)
            when 1
              return Screens::DeleteScreen.new(@selected_access_point.ssid)
            when 2
              return Screens::PrioritizeScreen.new(@selected_access_point.ssid)
            end
          else
            return Screens::EnterWifiPasswordScreen.new(@selected_access_point.ssid)
          end
        else
          return Screens::ManualSSIDScreen.new() if @menu_index == 0
          exit 0 if @menu_index == 1
        end
      end
    end
  end
end
