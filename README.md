# Kong-header-restriction
A plugin for Kong to blacklist requests based on values set in a header  that support dynamic update

## note:

there are two handlers in the code , support two different modules:

1. handler_warmup.lua: preload all blockList when Kong start, only cache the blockList items . this mode is suitable for scenarios where the header corresponds to a large range and only few blacklist .
2. handler.lua  Lazy loading, Retrieves the value from the cache. If the cache does not have value (miss),  Retrieves from the database . this mode All value ranges corresponding to the header will be cached gradually . Those that is not in the blacklist will be cached with the key-value pairs of header_value : nil , which is suitable for scenarios where the header corresponds to a small range. 

choose one ,remove another. or you can change the code yourself, merge them to one handler.

## use：

copy the header-restriction directory to your path /kong/plugins/ ,edit kong configuration : /kong/constants.lua, add "header-restriction" , then run :

``` shell
kong migrations up  # init database of this plugin, only needed the first time
kong start
```

enable plugin (on a route or a service or global)：
```
POST http://{{endpoint}}/routes/{{route}}/plugins 
Content-Type: application/x-www-form-urlencoded

name=header-restriction&config.header=your_header
```

get the blockList：

```
GET  http://{{endpoint}}/header_blockList
```

add blockList：

```
POST http://{{endpoint}}/header_blockList
Content-Type: application/json

{
  "value":"the_block_value"
}
```

remove blockList：

```
DELETE http://{{endpoint}}/header_blockList/{{you_value}}
```
