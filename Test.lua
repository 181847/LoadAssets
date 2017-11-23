-- This script is used to test all the module is correct.

-- Create a local enviroment for local test.
_ENV = {_G = _G}
-- set the metatable, find the missing var and function
-- in the _G enviroment.
_G.setmetatable(_ENV, {__index = _G})
--[[
TexPart   = require("TexturePart")
MatPart   = require("MaterialPart")
GeoPart   = require("GeometryPart")
--]]

AssembleModule  = require("Assemble")

test_t_1 = Texture.new("brick", "d:/texture/brick.dds")
test_t_2 = Texture.new("tree", "d:/texture/tree.dds")

test_m_1 = Material.new("baseMat")
test_m_2 = Material.new("whiteMat")
test_m_3 = Material.new("bricks")
test_m_3.diffuseAlbedo[1] = 0.3
test_m_3.diffuseAlbedo[2] = 0
test_m_3.diffuseMap = test_t_1.name

test_m_4 = Material.new("tree")
test_m_4.diffuseAlbedo[3] = 0.222223333
test_m_4.normalMap = test_t_1.name
test_m_4.diffuseMap = test_t_2.name

test_g_1 = Geometry.new("box", "Tank.obj")
test_g_2 = Geometry.new("sphere", "shapeG.obj")

test_ritem_1 = RenderItem.new(test_g_1.name, test_m_1.name, "opaque")
test_ritem_2 = RenderItem.new(test_g_2.name, test_m_2.name, "water")
print()

-- add each instance to specific set, 
-- then assemble.
test_t_1:addToGlobalSet()
test_t_2:addToGlobalSet()
--
test_m_1:addToGlobalSet()
test_m_2:addToGlobalSet()
test_m_3:addToGlobalSet()
test_m_4:addToGlobalSet()
--
test_g_1:addToGlobalSet()
test_g_2:addToGlobalSet()
--
test_ritem_1:addToGlobalSet()
test_ritem_2:addToGlobalSet()
-- assemble again
AssembleModule.Assemble()


print()
test_t_1:showDetail()
test_t_2:showDetail()
print()
test_m_1:showDetail()
test_m_2:showDetail()
test_m_3:showDetail()
test_m_4:showDetail()
print()
test_g_1:showDetail()
test_g_2:showDetail()
print()
test_ritem_1:showDetail()
test_ritem_2:showDetail()
print()

RItemPart = require("RenderItemPart")
RItemPart.ShowRenderLayers()
print()
