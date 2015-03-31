# Writer: Aaron Liu
# Connect: liu_sihao@163.com
#
require 'sketchup.rb'

def show_component_adjust_item
  plugins_menu = UI.menu("Window")
  plugins_menu.add_item("组件调整") { switch_display_toolbar }
end

def component_adjust_dialog
  dlg = UI::WebDialog.new("组件调整", true, "ShowGoogleDotCom", 739, 641, 150, 150, true);
  dlg.set_url('./ComponentAdjust/html/manager.html')
  dlg.show
end

def component_toolbar
  toolbar = UI::Toolbar.new("动态组件插件")

  switch_display_command = UI::Command.new('Swith display component') { UI.messagebox 'Swith display component' }
  component_adjust_command = UI::Command.new('adjust component') { component_adjust_dialog }
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