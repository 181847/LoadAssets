-- this is a module that contain useful function to read function,
-- and it have searchpath allow us to check if the file exist

_ENV = {_G = _G}
_G.setmetatable(_ENV, {__index = _G})

module = {}

md = require('MeshData')

-- where to find the file
module.searchpath = './?.obj;./Assets/Geometry/?.obj;'


-- use this pattern to extract the main file name
patternFileName = '([%w%d_]*)%.obj$'

patterPosition = 'v%s.*'
patternNormal = 'vn%s.*'
patternTexC = 'vt%s.*'
patternVertex = 'f%s.*'
patternVertexIndices = '%d*/%d*/%d*'

patternSubGeometry = 'g%s.*'
notSubGeometry = 'g default'

patternShape = '^g%s+(%w[%w%s]+)'

patternNumber = '%d*%.?%d*'

function module.addSearchPath(newpath)
    module.searchpath = module.searchpath..newpath..';'
end

-- use this function to check the specific file exist in the search path,
-- the name can contain folder sepretor such as 'Asset/Geometry/example.obj'
-- the name must have the extension name.
function module.findFile(filename)
    -- for example, 
    -- seperate 'Asset/Geometry/example.obj' to 'Asset/Geometry/example' and 'obj'
    local pureName, extension = string.match(filename, '(.-)%.(%w-)$')
    
    if not extension then
        return nil, 'missing extension name:'..filename
    end
    
    -- first we will replace the '?' with the pureName
    local replaceResult = string.gsub(module.searchpath, '(%?)', 
        function(cap)
            return pureName
        end
    )
    
    -- then for each single file path, we test it with the extension name
    -- use a local var to store the correct file name, here we use the closure
    local correctFile = ''
    string.gsub(replaceResult, '([^;]*);', 
        function(cap)
            if string.match(cap, '.*%.'..extension) then
                correctFile = cap
            end
            -- here we don't care about the replacement result,
            -- so just return an empty string.
            return ''
        end
    )
    
    -- is the file exist ?
    local file = io.open(correctFile, 'r')
    if file then
        file:close()
        return correctFile
    else
        return nil, 'file does not exist:'..filename
    end
end

-- use this function to read a file,
-- then return two table,
-- one is the meshData,
-- second is the subMeshes,
-- which for each subMesh name there are two index
-- that indicate where the index start and end.
function module.readObjFile(file, meshData, subMesh)    
    -- extract the file name: 'Tank_0.obj' -> 'Tank_0'
    file = string.match(file, patternFileName) or file
    file, msg = package.searchpath(file, module.searchpath)
    
    -- if file not exist, return nil
    if not file then
        return nil, 'cannot find the file'
    else
        -- notic that the file type changed,
        -- string -> file
        file = io.open(file, 'r')
        
        -- cannot open the file
        if not file then
            return nil, 'cannot open the file'
        end
    end
    
    local meshData = meshData or md.new()
    local subMesh = subMesh or {}
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
                subMesh[subName] = {startIndex = 0, endIndex = 0}
                
                -- read all the Indices
                while not stop do
                    arg , stop = coroutine.yield()
                    
                    -- number mean arg is a index 
                    -- we will set it as the startIndex
                    if type(arg) == 'number' then
                        -- is the index the first one ?
                        if subMesh[subName].startIndex == 0 then
                            subMesh[subName].startIndex = arg
                            -- in case some subMesh only have one vertex
                            -- we will also set the end Index.
                            subMesh[subName].endIndex = arg
                        else
                            -- the start Index has been initialized,
                            -- set the end Index whenever we get a second number.
                            subMesh[subName].endIndex = arg
                        end
                    elseif type(arg) == 'string' then
                        -- we get a subMesh name,
                        -- goto the outer loop
                        subName = arg
                        goto startSubMesh
                    end
                end -- while
            end -- while
        end -- function
    )
    
    -- start coroutine
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
        
        if subName and subName ~= 'default' then
            -- add the subMesh, we will just pass the name
            -- to the coroutine , it will take care of the 
            -- name and indices.
            cor_addMesh(subName, false)
        end
    end
    -- clean up
    file:close()
    -- send true for stop the coroutine
    cor_addMesh(nil, true)
    
    return meshData, subMesh
end

-- This function is just for print the subMesh.
function module.printSubMesh(sm)
    for k, v in pairs(sm) do
        print('SubMesh:', k, v)
        for ki, vi in pairs(v) do
            print(ki, vi)
        end
    end
end

return module
