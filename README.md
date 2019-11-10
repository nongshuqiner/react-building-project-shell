这是一个快速搭建react项目的shell文件，他会在根目录下新建一个文件夹`ReactSubject`,并在'~/ReactSubject'下创建一个react项目：

```
sh react-building-project-shell.sh
```

>注意：别忘记配置支持 @ 文件映射 src 目录
alias: {
  ...
  '@': path.join(__dirname, '..', 'src'), // 添加这段内容
}
