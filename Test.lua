-- This script is used to test all the module is correct.

require("TexturePart")
require("MaterialPart")
RItemPart = require("RenderItemPart")

test_m_1 = Material.new("baseMat")
test_m_2 = Material.new("whiteMat")

test_ritem_1 = RenderItem.new("box.obj", test_m_1.name, "layer_1")
test_ritem_2 = RenderItem.new("cylinder.obj", test_m_2.name, "layer_2")

test_m_1:showDetail()
test_m_2:showDetail()
print()
test_ritem_1:showDetail()
test_ritem_2:showDetail()
print()
RItemPart.ShowRenderLayers()
