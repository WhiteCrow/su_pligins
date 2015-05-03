MAC = ( Object::RUBY_PLATFORM =~ /darwin/i ? true : false )
WIN = ( (Object::RUBY_PLATFORM =~ /mswin/i || Object::RUBY_PLATFORM =~ /mingw/i) ? true : false )

# extend Sketchup::ComponentDefinition

class Sketchup::ComponentDefinition
  def dynamic_attrs
    self.attribute_dictionary("dynamic_attributes")
  end

  def set_dynamic_attr(key, value)
    self.set_attribute("dynamic_attributes", key, value)
  end
end

class Sketchup::ComponentInstance
  def dynamic_name
    dynamic_attrs["_name"]
  end

  def dynamic_attrs
    self.attribute_dictionary("dynamic_attributes")
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

  def dynamic_attrs_info
    dynamic_attrs.each_pair{|key, value| puts "#{key} : #{value}"}
  end

  def set_dynamic_attr(key, value)
    self.set_attribute("dynamic_attributes", key, value)
  end

  def get_dynamic_attr(key)
    get_attribute("dynamic_attributes", key)
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

if MAC
  PATH = $LOAD_PATH[1]
elsif WIN
  PATH = $LOAD_PATH[0]
else
  UI.messagebox("本插件仅支持Windos或Mac系统。")
end

def reload
  UI.menu("Plugins").add_item("Reload My Script") { load("component.rb") }
end

def show_component_adjust_item
  plugins_menu = UI.menu("Window")
  plugins_menu.add_item("组件调整") { switch_display_toolbar }
end

def component_adjust_dialog
  dlg = UI::WebDialog.new("组件调整", true, "", 339, 641, 150, 150, true)
  dlg.set_file "#{PATH}/ComponentAdjust/html/configurator.html"
  dlg
end

def init_window(instance)
  dialog = component_adjust_dialog
  dialog.add_action_callback("set_options") do |web_dialog,action_name|
    if action_name == 'set'
      dialog.execute_script("$('#header #config-image').html(\"<img src=\'#{PATH}/config-thumb.jpg'>\")")
      dialog.execute_script("$('#header #config-head').html('#{instance.dynamic_name}')")
      @_customized_attrs = {}
      config_html_string = config_html_str(instance, "")
      dialog.execute_script("$('#content #config-options').html('#{config_html_string}')")
      dialog.execute_script("$(\"#footer #applyButton\").removeAttr(\"disabled\")")
    end
    if action_name == 'update'
      @_customized_attrs.each_pair do |inst, attrs|
        instance_id = inst.object_id.to_s
        new_attrs = {instance_id => {}}
        attrs.each_key do |key|
          value = dialog.get_element_value("input" + instance_id + key[1])
          new_attrs[instance_id][key[1]] = value
        end
        inst.update_dynamic_attrs(new_attrs[instance_id])
      end
      # refresh @_customized_attrs
      @_customized_attrs = {}
      config_html_str(instance, "")
    end
  end
  dialog
end

def config_html_str(instance, html_str)
  return html_str if instance.nil?
  attrs = instance.customized_attrs
  return html_str if (attrs.nil? || attrs.empty?)
  instance_id = instance.object_id.to_s

  @_customized_attrs.merge!({instance => attrs })

  html_str << "<a style=\"color: blue;\" onclick=\"expandDefinition(#{instance_id});\"><strong> > #{instance.dynamic_name} </strong></a><br />"
  if @_selected_instance == instance
    html_str << "<div id=#{instance_id}>"
  else
    html_str << "<div id=#{instance_id} style=\"display: none;\">"
  end

  attrs.each_pair do |key, value|
    html_str << "<span style=\"width: 100px; display: inline-block;\">#{key[0]}(#{key[1]})</span><input id=#{'input'+ instance_id + key[1]} value=#{value}></input><br/>"
  end

  html_str << "<div style=\"margin-left: 10px\">"
  instance.sub_instances.each do |sub_i|
    config_html_str(sub_i, html_str)
  end
  html_str << "</div></div>"
end

def selected_component_instance
  selection = Sketchup.active_model.selection
  @_selected_instance = selection.first
  @_selected_component_definition =
  selection.count == 1 && @_selected_instance.class == Sketchup::ComponentInstance ? selection.first.definition : nil
  @_selected_instance
end

def switch_window
  if Sketchup.active_model.selection.first.class != Sketchup::ComponentInstance
    return UI.messagebox("请选择一个动态组件")
  end

  if @_selected_instance !=  Sketchup.active_model.selection.first
    instance = selected_component_instance
    @_dlg.close if !@_dlg.nil?
    @_dlg = init_window(instance)
  end

  @_dlg.visible? ? @_dlg.close : @_dlg.show
end

def component_toolbar
  toolbar = UI::Toolbar.new("动态组件插件")

  switch_display_command = UI::Command.new('Swith display component') { UI.messagebox 'Swith display component' }
  component_adjust_command = UI::Command.new('adjust component') { switch_window }
  component_function_command = UI::Command.new('function component') { UI.messagebox 'component function' }

  switch_display_command.small_icon = './images/interact_tool_small.png'
  switch_display_command.large_icon = './images/interact_tool.png'
  component_adjust_command.small_icon = './images/adjust_small.png'
  component_adjust_command.large_icon = './images/adjust.png'
  component_function_command.small_icon = './images/function_small.png'
  component_function_command.large_icon = './images/function.png'

  [switch_display_command, component_adjust_command, component_function_command].each do |command|
    toolbar = toolbar.add_item command
  end

  toolbar
end

def switch_display_toolbar
  if @toolbar.visible?
    @toolbar.hide
  else
    @toolbar.show
  end
end

@toolbar ||= component_toolbar
@toolbar.show
show_component_adjust_item
