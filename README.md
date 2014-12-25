DDKit
=====
说在前面的话，首先我是一个不善表达技术专业名词的人。  
特别鸣谢
-----
感谢AFNetworking,提供了简便的HTTP请求方式；  
感谢SQLitePersistentObject，让数据库存储与CoreData一样简单；    
感谢JTObjectMappings,让Objective-C也有映射机制。  
工具简介
-----
1.本工具的主要功能是对模型与HTTP请求的封装，简化Model层的开发成本；
2.本工具中的DDBasicModel继承了SQLitePersisentObject，直接用于数据库存储，并且我在重载了save的方法，保证了数据库的多线程情况下的安全存储；同时也保证了数据的读取优先原则；  
3.本工具中包含了我自身开发过程中遇到的学习代码。
使用方法
-----
首先你要保证你的CocoaPods里的代码是存在的；
你只要继承了DDBasicModel以后就可以根据自己的业务创建模型 完成JsonMapping 和JsonNode的重载；

Dejohn Dong's Demo Project
