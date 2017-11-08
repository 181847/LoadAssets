require "class"

local module = {};

module.TextureSet = {}

function module.add(textureName, texturePath)
    -- Store the path accroding to the name,
    -- we will use the name for other object(such as material) to find the texture.
    module.TextureSet[textureName] = texturePath;
end

return module
