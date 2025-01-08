感谢B站UP漫游挨踢的分享，原项目地址：
https://github.com/manyouit/PasteAsHardlink

修复了原脚本的一个 Bug，该 Bug 导致 Windows 11 的资源管理器在打开多个标签页时，硬链接会被创建在该窗口最先打开的标签页中
现在，硬链接会被正确地创建在活跃的标签页中

由于修改为了 Autohotkey v2 脚本，因此不再支持 Autohotkey v1，请前往官网下载v2.0版本
https://www.autohotkey.com/

修复 Bug 使用的代码来自 autohotkey 官方论坛：
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907
