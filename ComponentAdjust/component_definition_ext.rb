# extend Sketchup::ComponentDefinition

class Sketchup::ComponentDefinition
  def dynamic_attrs
    self.attribute_dictionary("dynamic_attributes")
  end

  def dynamic_attrs_info
    dynamic_attrs.each_pair{|key, value| puts "#{key} : #{value}"}
  end

  def set_dynamic_attr(key, value)
    self.set_attribute("dynamic_attributes", key, value)
  end
end
