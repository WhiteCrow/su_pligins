# Writer: Aaron Liu
# Connect: liu_sihao@163.com
#
require 'sketchup.rb'

def reload
  UI.menu("Plugins").add_item("Reload My Script") { load("component.rb") }
end

def show_component_adjust_item
  plugins_menu = UI.menu("Window")
  plugins_menu.add_item("组件调整") { switch_display_toolbar }
end

def component_adjust_dialog
  dlg = UI::WebDialog.new("组件调整", true, "", 339, 641, 150, 150, true)
  dlg.set_file "#{$LOAD_PATH[1]}/ComponentAdjust/html/configurator.html"
  dlg
end

def init_window(definition)
  @_html_string = ""
  dialog = component_adjust_dialog
  dialog.add_action_callback("set_options") do |web_dialog,action_name|
    if action_name == 'test'
      dialog.execute_script("$('#header #config-image').html(\"<img src=\'#{$LOAD_PATH[1]}/config-thumb.jpg'>\")")
      dialog.execute_script("$('#header #config-head').html('#{definition.name}')")
      set_config_options(dialog, definition);
    end
  end
  dialog
end

def switch_window
  definition = selected_component_definition
  return UI.messagebox("请选择一个动态组件") if definition.nil?
  @_dlg = init_window(definition)
  @_dlg.visible? ? @_dlg.close : @_dlg.show
end

def config_html_str(definition)
  return @_html_string if definition.nil?

  attrs = selected_component_attrs(definition)

  return @_html_string if attrs.nil?

  attrs = selected_component_customized_attrs(attrs)
  definition_id = definition.object_id.to_s
  @_html_string << "<a style=\"color: blue;\" onclick=\"expandDefinition(#{definition_id});\"><strong> > #{definition.name} </strong></a><br />"
  if @_selected_component_definition == definition
    @_html_string << "<div id=#{definition_id}>"
  else
    @_html_string << "<div id=#{definition_id} style=\"display: none;\">"
  end
  @_html_string << "名字<input value=#{definition.name}></input><br/>"
  attrs.each_pair do |key, value|
    @_html_string << "#{key}<input value=#{value}></input><br/>"
  end

  @_html_string << "<div style=\"margin-left: 10px\">"
  sub_definitions(definition).each do |sub_d|
    config_html_str(sub_d)
  end
  @_html_string << "</div></div>"
end

def set_config_options(dialog, definition)
  config_html_str(definition)
  dialog.execute_script("$('#content #config-options').html('#{@_html_string}')")
end
def selected_component_definition
  selection = Sketchup.active_model.selection
  @_selected_component_definition =
  if selection.count == 1 && selection.first.class == Sketchup::ComponentInstance
    selection.first.definition
  else
    nil
  end
end

def selected_component_attrs(definition)
  dict = definition.attribute_dictionaries
  dict.nil? ? nil : dict.map{|d| d }.first
end

def selected_component_customized_attrs(attrs)
  customized_attributes ||= {}
  attrs.each_pair do |key, value|
    if key=~ /_formlabel$/ && !value.nil?
      customized_key = value
      origin_key = key.gsub(/^_|_formlabel$/, '')
      customized_value = attrs[origin_key]
      customized_attributes.merge!(customized_key => customized_value)
    end
  end
  customized_attributes
end

def sub_definitions(definition)
  definition.entities.select do |e|
    e.is_a? Sketchup::ComponentInstance
  end.map do |e|
    e.definition
  end
end

def component_toolbar
  toolbar = UI::Toolbar.new("动态组件插件")

  switch_display_command = UI::Command.new('Swith display component') { UI.messagebox 'Swith display component' }
  component_adjust_command = UI::Command.new('adjust component') { switch_window }
  component_function_command = UI::Command.new('function component') { UI.messagebox 'component function' }

  switch_display_command.small_icon = './ComponentAdjust/images/interact_tool_small.png'
  switch_display_command.large_icon = './ComponentAdjust/images/interact_tool.png'
  component_adjust_command.small_icon = './ComponentAdjust/images/adjust_small.png'
  component_adjust_command.large_icon = './ComponentAdjust/images/adjust.png'
  component_function_command.small_icon = './ComponentAdjust/images/function_small.png'
  component_function_command.large_icon = './ComponentAdjust/images/function.png'

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
