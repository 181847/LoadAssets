这是一个用Lua帮助加载 **模型**、**材质**、**贴图** 的工程。

#AssembleModule
获取：

```lua
AssembleModule  = require("Assemble")
```

汇集模块，在这个模块中定义函数用来收集所有的资源。

域   |   解释  |   类型
-----|--------|--------
assembleSet  |  资源集合，所有被收集的资源在都在这里存储 |  table
logger  | 日志记录函数，汇集过程中发生的错误信息都会传递到这里  |  function
**Assemble**  |  汇集函数，汇集所有资源，添加资源到assembleSet中，并且检查汇集过程是否有错误，比如引用的文件不存在，引用的材质别名不存在等错误 |  function

##AssembleModule.**Assemble**
最重要的函数，用于收集所有的资源，并且检查资源的正确性

返回值序号 |   类型    |   解释
-------|--------------|-----
1  |  Boolean   |   true代表发生错误，false表示正常
2  |  table |  直接将AssembleModule.assembleSet返回，方便对其进行操作


#AssembleModule.assembleSet
这个table中分别包含以下内容：

域   | 解释    | 类型
-----|---------|-----
MaterialQueue  | 存储材质实例，内部以序号为键值存储材质以下同理  |  table
TextureQueue  |  存储贴图实例 |  table
GeometryQueue  |  几何网格实例 |  table
RenderItemQueue  |  渲染物体实例 |  table

上面提到的4个Queue都包含一个**n**域，存储了各个实例的总数，方便在C中遍历，


#RItemPart
包含所有和RenderItem相关的类定义和函数，以及一个全局的集合用来存储所有需要被获取的RenderItem对象。
调用

```lua
RItemPart = require('RenderItemPart')
```

即可返回这个模块。

域   |   解释  |   类型
-----|--------|--------
RenderItem  |   对RenderItem类的定义() |   class
RenderLayers    |   渲染层集合，使用渲染层的名字为键值，存储对应的层的序号（序号从0开始），包含一个n域，存储总的渲染层数量   |   table
RenderItemSet   |   以数组的形式存储所有需要被Assemble的渲染物体  |   table
AddRenderLayer  |   传入一个字符串，添加一个渲染层，对于已存在的层名称不做任何处理 |   function
ShowRenderLayers    | 显示所有的RenderLayer  |   function


##RenderItem
这是一个全局类，如果已经加载了RItemPart就可以在任何地方随处调用，这个类的实例包含以下关键属性 *（这不是全部）*。

属性名 |   解释  |   类型
------|---------|-------
geometry    | geometry的名字   |   string
subMesh  |  存储关于子网格的信息，其中的*name*域存储子网格的名称，在*assembleStage*之后，会增加两个与startIndex和endIndex，对应顶点的开始索引和结束索引 | table
material    | 材质的名字        |    string
renderLayer | 渲染层的名字    |   string  |  


以上的属性必须在初次创建RenderItem的实例的时候作为参数传入new中，程序会自动将renderLayer添加层的记录中。

```lua
test_ritem_1 = RenderItem.new('box', 'dirtyBricks', 'opaqueLayer')
```

方法名 |   解释  |   返回值
------|---------|----------
showDetail  |   向屏幕打印信息 |   无
addToGlobalSet  |   将当前的RenderItem添加到全局集合中，这样一来，这个RenderLayer才会被程序收集起来 | 无

#GeoPart
关于网格物体的信息模块，包含涉及到读取obj文件中的网格信息等，获取模块：

```lua
GeoPart = require('GeometryPart')
```

域   |   解释  |   类型
-----|--------|--------
Geometry    |   几何网格类，其实就是存储一个obj文件，在之后的使用中能够从obj中读取网格信息    |   class
GeometrySet |   网格集合，所有能够被真正访问的网格实例 |   table
MeshData    |   C库函数，包含一个new函数，能够创建一个meshData类，内部使用C来存储顶点信息  |   C库，table
FileModule  |   读取obj文件的函数模块    |   模块，table


##Geometry
存储和访问obj文件的类，在lua中我们为每一个geometry命名一个别名，在RenderItem中使用这个别名引用指定的Geometry。

属性名 |   解释  |   类型
------|---------|-------
name    | 几何网格的名字，注意不要和实例的名字搞混了   |   string
file    |   对应obj文件的名字，可以包含文件夹路径，程序会自动搜索这些文件      |    string
meshData  |  调用汇集过程之后才存在，从obj文件提取的网格信息 | userData，Lua::MeshData 
subMeshes  | 调用汇集过程之后才存在，从obj文件中读取到的子网格信息，一个子网格的名称为域，再存储一个**table{startIndex = *someNumber*, endIndex = *someNumber*}**  | table

创建：

```lua
test_g_1 = Geometry.new("box", "Tank.obj")
```

上面这段代码中，我们创建了一个别名为*box*的geometry，实际的网格信息来自一个叫“Tank.obj”文件，有了这个名叫*box*的geometry，我们就可以在renderItem中引用这个geometry了。

方法名 |   解释  |   返回值
------|---------|----------
showDetail  |   向屏幕打印信息 |   无
addToGlobalSet  |   添加几何实例到全局集中，等待汇集 | 无
readFile        | 读取obj文件，获取真实的网格信息，这个方法在汇集过程中自动调用 | 返回是否发生了错误，**true** 代表有错误发生，**false** 代表正常。

#MatPart

这是关于材质的部分  
获取模块：

```lua
MatPart = require("MaterialPart")
```

域   |   解释  |   类型
-----|--------|--------
Material    |   材质类 |   class
MaterialSet |   材质集合，以材质的名字(比如*whiteMat*)为键值，存储材质类的实例    |  table

##Material
材质类，定义一个材质的漫反射、fresnelR、粗糙程度、漫反射贴图、法线贴图

属性名 |   解释  |   类型
------|---------|-------
name  | 材质的别名，能够在RenderItem中引用  |  string
diffuseAlbedo   |   漫反射颜色，4个数字，RGBA |   table / array<number, 4>
fresnelR        |   材质的固有反射属性，3个数字  | table / array<number, 3>
roughness       |   粗糙程度            | number
diffuseMap      |   漫反射贴图别名，注意这**不**是贴图的文件名，和geometry类似， 只是一个贴图实例的别名，贴图由另外一个模块负责     |   string
normalMap       |   法线贴图别名      | string

创建：

```lua
test_m_2 = Material.new("whiteMat")
```

上面默认创建了一个别名为*whiteMat*的材质，初始漫反射颜色全为1（RGBA）， fresnelR全为0.01， 粗糙度为0.5，贴图别名全部为nil（即没有贴图）。

方法名 |   解释  |   返回值
------|---------|----------
showDetail  |   向屏幕打印信息 |   无
addToGlobalSet  |   添加材质到全局集中，等待汇集 | 无

#TexturePart

关于贴图材质的部分  
获取模块：

```lua
Tex = require("TexturePart")
```

域   |   解释  |   类型
-----|--------|--------
Texture |   贴图类     | class
TextureSet  | 以贴图的别名为键值存储贴图实例    | table

##Texture

贴图类，方便引用贴图文件

属性名 |   解释  |   类型
------|---------|-------
name   |    贴图别名    |   string
file    |   贴图文件    |   string

创建

```lua
test_t_1 = Texture.new("brick", "texture/brick.dds")
```

上面创建了一个别名为brick的贴图，引用文件texture/brick.dds

方法名 |   解释  |   返回值
------|---------|----------
showDetail  |   向屏幕打印信息 |   无
addToGlobalSet  |   添加贴图到全局集中，等待汇集 | 无



本工程中使用lua定义类的方法来自[云风的个人空间 : Lua 中实现面向对象](https://blog.codingnow.com/cloud/LuaOO)
