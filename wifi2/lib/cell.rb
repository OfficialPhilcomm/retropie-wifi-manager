class Cell
  ARGUMENT_REGEX = /\s*(?<parameter>[A-Za-z#_]+)=(?<value>.*)/

  attr_reader :arguments

  def initialize(original_config)
    @original_config = original_config

    @arguments = original_config.split("\n").map do |line|
      next if /\s*network\s*=\s*{\s*/.match(line)
      
      match = ARGUMENT_REGEX.match(line)
      next unless match
      
      next if match[:parameter].start_with? "#"

      [match[:parameter], match[:value]]
    end
    .select do |network_argument|
      network_argument
    end
  end

  def ssid
    ssid = arguments.select do |argument|
      argument[0] == "ssid"
    end.first

    return unless ssid

    return ssid[1].gsub "\"", ""
  end

  def set_priority(priority)
    @arguments = @arguments.select do |argument|
      argument[0] != "priority"
    end
    
    arguments.append(["priority", 1]) if priority
  end

  def valid?
    !ssid.nil?
  end

  def to_s
    [
      "network={",
    ].concat(
      arguments.map do |parameter, value|
        "\t#{parameter}=#{value}"
      end
    ).concat(
      ["}\n"]
    ).join("\n")
  end
end
