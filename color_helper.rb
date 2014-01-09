require './config'
class ColorHelper

  def self.color_class_by_value(value)
    return self.get_color_from_array(value,CONFIG.color_classes)
  end

  def self.color_code_by_value(value)
    return self.get_color_from_array(value,CONFIG.color_codes)
  end


  def self.get_color_from_array(value, list)
    if value >= 1.0
      return list[-1]
    end

    if value <= 0.0
      return list[0]
    end

    return list[((value-0.001)*list.length).floor.to_i]
  end

end