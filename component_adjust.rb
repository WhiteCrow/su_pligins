# Writer: Aaron Liu
# Connect: liu_sihao@163.com
#
require 'sketchup.rb'
require 'extensions.rb'

ComponentAdjust = SketchupExtension.new "Component Adjust", "ComponentAdjust/main.rb"
ComponentAdjust.version = '1.0'
ComponentAdjust.creator="liusihao.com"
ComponentAdjust.description = "Plugins to manage components in a model"
Sketchup.register_extension ComponentAdjust, true
