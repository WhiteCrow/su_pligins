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
  #dlg.add_action_callback("pull_information") {|dlg, params| UI.messagebox params; @params = params}
  @selected_component_definition ||= selected_component_definition
  dlg.execute_script("$('#header #config-head').html('#{@selected_component_definition.name}')")
  dlg.execute_script("$('#header #config-image').html(\"<img src=\'#{$LOAD_PATH[1]}/config-thumb.jpg'>\")")
  dlg
end

def init_component_adjust_dialog
  dialog = component_adjust_dialog
  definition = selected_component_definition
  attrs = selected_component_attrs(definition)
  selected_component_customized_attrs(attrs)
  customized_attrs = selected_component_customized_attrs(attrs)
  set_config_options(dialog, customized_attrs)
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
  definition.attribute_dictionaries.map{|dict| dict }.last
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

def set_config_options(dialog, attrs)
  @_d = dialog; @_a = attrs
  html_string = ''
  attrs.each_pair do |key, value|
    html_string << "#{key}<input value=#{value}></input><br/>"
  end
  @_str = html_string
  dialog.execute_script("$('#content #config-options').html('#{html_string}')")
  dialog
end

def switch_component_adjust_dialog
  @dlg = init_component_adjust_dialog
  @dlg.visible? ? @dlg.close : @dlg.show
end

def component_toolbar
  toolbar = UI::Toolbar.new("动态组件插件")

  switch_display_command = UI::Command.new('Swith display component') { UI.messagebox 'Swith display component' }
  component_adjust_command = UI::Command.new('adjust component') { switch_component_adjust_dialog }
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
