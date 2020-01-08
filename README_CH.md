# Kong 请求头限制

Kong 自定义插件，根据特定的header来屏蔽请求，支持动态更新黑名单

## 注意：

有两个 handler，分别支持两种模式：

1. handler_warmup.lua: 在启动时，预加载所有黑名单，在运行期间，动态更新缓存。此模式只缓存黑名单数据，适合header对应的值域大，黑名单少的场景；
2. handler.lua 运行期间，先查询缓存，未命中则查询数据库。会逐渐缓存该header对应的所有值域，不在黑名单的会以 header_value: nil 的键值对缓存，适合值域小的场景；

选择其中一个handler，去掉另一个。你也可以修改代码，将这两种模式合并成一个handler。 


## 使用：

安装插件，修改Kong配置，加载自定义插件，运行命令：

``` shell
kong migrations up  # 第一次运行要初始化插件数据库
kong start  # 启动Kong
```

启动插件：
```
POST http://{{endpoint}}/routes/{{route}}/plugins 
Content-Type: application/x-www-form-urlencoded

name=header-restriction&config.header=your_header
```

运行期间查询黑名单：

```
GET  http://{{endpoint}}/header_blockList
```
新增黑名单：

```
POST http://{{endpoint}}/header_blockList
Content-Type: application/json

{
  "value":"the_block_value"
}
```

删除黑名单：

```
DELETE http://{{endpoint}}/header_blockList/{{you_value}}
```

