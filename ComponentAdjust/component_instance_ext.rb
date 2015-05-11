# extend Sketchup::ComponentInstance

class Sketchup::ComponentInstance
  def dynamic_name
    dynamic_attrs["_name"]
  end

  def dynamic_attrs
    self.attribute_dictionary("dynamic_attributes")
  end

  def dynamic_attrs_info
    dynamic_attrs.each_pair{|key, value| puts "#{key} : #{value}"}
  end

  def customized_attrs
    customized_attributes ||= {}
    definition_attrs = self.definition.dynamic_attrs
    return {} if definition_attrs.nil?

    definition_attrs.each_pair do |key, value|
      if key=~ /_formlabel$/ && !value.nil?
        customized_key = value
        origin_key = key.gsub(/^_|_formlabel$/, '')
        customized_value = definition_attrs[origin_key]
        customized_attributes.merge!([customized_key, origin_key] => customized_value)
      end
    end
    customized_attributes.merge!(["名字", "_name"] => definition_attrs["_name"])
    customized_attributes
  end

  def set_dynamic_attr(key, value)
    self.set_attribute("dynamic_attributes", key, value)
  end

  def get_dynamic_attr(key)
    get_attribute("dynamic_attributes", key)
  end

  def equipotential_replace(instance)
    # replace name
    # self.set_dynamic_attr("_name", instance.get_dynamic_attr("_name"))
    # replace Coordinate
    # self.move!(instance.transformation)
    self.update_dynamic_attrs(instance.dynamic_attrs)
    #self.redraw
  end

  def update_dynamic_attrs(new_attrs)
    redraw_flag = false
    old_attrs = self.dynamic_attrs
    new_attrs.each_pair do |key, value|
      if old_attrs[key] != value && !old_attrs[key].nil?
        puts "#{key} : #{old_attrs[key]} - #{value}"
        self.set_dynamic_attr(key, value)
        self.definition.set_dynamic_attr(key, value)
        redraw_flag = true
      end
    end
    self.redraw if redraw_flag == true
    self
  end

  def sub_instances
    self.definition.entities.select do |e|
      e.is_a? Sketchup::ComponentInstance
    end
  end

  def redraw
    $dc_observers.get_latest_class.redraw_with_undo(self)
  end

end

