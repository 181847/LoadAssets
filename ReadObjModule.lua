_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})

module = {}

md = require('MeshData')

patterPosition = 'v%s.*'
patternNormal = 'vn%s.*'
patternTexC = 'vt%s.*'
patternVertex = 'f%s.*'
patternVertexIndices = '%d*/%d*/%d*'

patternSubGeometry = 'g%s.*'
notSubGeometry = 'g default'

patternShape = '^g%s+(%w[%w%s]+)'

patternNumber = '%d*%.?%d*'

function addSubMesh(subMesh, name, startIndex, endIndex)
    subMesh[name] = {startIndex, endIndex}
end

-- use this function to read a file,
-- then return two table,
-- one is the meshData,
-- second is the subMeshes,
-- which for each subMesh name there are two index
-- that indicate where the index start and end.
function module.readFile(file, meshData, subMesh)
    file = io.open(file, 'r')
    
    local meshData = meshData or md.new()
    local subMesh = sumMesh or {}
    local vindex = 0
    
    function readNumbers(line)
        numbers = {}
        for number in string.gmatch(line, patternNumber) do
            numbers[#numbers + 1] = tonumber(number)
        end
        return numbers
    end
    
    -- create a coroutine to add subMesh
    cor_addMesh = coroutine.wrap(
        function (subMesh)
            local stop = nil
            local subName = ''
            
            -- each loop read a subMesh
            while not stop do
                -- get the first subMesh
                subName, stop = coroutine.yield()
                -- the 0 mean invalid index 
                -- we will use this to test if the subMesh
                -- have the startIndex
                ::startSubMesh::
                subMesh[subName] = {0, 0}
                
                -- read all the Indices
                while not stop do
                    arg , stop = coroutine.yield()
                    
                    -- number mean arg is a index 
                    -- we will set it as the startIndex
                    if type(arg) == 'number' then
                        -- is the index the first one ?
                        if subMesh[subName][1] == 0 then
                            subMesh[subName][1] = arg
                            -- in case some subMesh only have one vertex
                            -- we will also set the end Index.
                            subMesh[subName][2] = arg
                        else
                            -- the start Index has been initialized,
                            -- set the end Index whenever we get a second number.
                            subMesh[subName][2] = arg
                        end
                    elseif type(arg) == 'string' then
                        -- we get a subMesh name,
                        -- goto the outer loop
                        subName = arg
                        goto startSubMesh
                    end
                end -- while
            end -- while
        end
    )
    
    cor_addMesh(subMesh)
    
    -- read each line
    for line in file:lines() do
        -- add position
        if string.match(line, 'v%s.*') then
            -- read positions
            meshData:addPosition(table.unpack(readNumbers(line)))
        end
        
        -- add normal 
        if string.match(line, patternNormal) then
            meshData:addNormal(table.unpack(readNumbers(line)))
        end
        
        -- add textureCoord
        if string.match(line, patternTexC) then
            meshData:addTextureCoord(table.unpack(readNumbers(line)))
        end
        
        -- line look like 'f 4/4/4 3/3/3 3/3/3'
        if string.match(line, patternVertex) then
            for vertex in string.gmatch(line, patternVertexIndices) do
                numbers = readNumbers(vertex)
                
                -- sometimes there is not the tangentU, we just add a index 0
                while (#numbers < 4) do
                    numbers[#numbers + 1] = 0
                end
                meshData:addVertex(table.unpack(numbers))
                vindex = vindex + 1
                meshData:addIndex(vindex)
                cor_addMesh(vindex, false)
            end
        end
        
        subName = string.match(line, patternShape)
        --print("Debug: ", subName, patternShape, 'Line: ', line)
        
        if subName ~= 'default' and subName then
            -- add the subMesh, we will 
            cor_addMesh(subName, false)
        end
    end
    return meshData, subMesh
end

-- This function is just for print the subMesh.
function module.printSubMesh(sm)
    for k, v in pairs(sm) do
        print(k, v)
        for ki, vi in pairs(v) do
            print(ki, vi)
        end
    end
end

return module
