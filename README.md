前置条件：
1、系统：ubuntu16.04 18.04 安装git、nginx；
2、各服务器开放40002,50001端口；
3、nginx配置文件访问列表，用于各节点下载对应的配置文件；
ngixn配置文件/etc/nginx/sites-enabled/violas_nginx.conf：
```json
server {
	listen 80;
	location / {
		root /home/ops/deploy_node;
		autoindex on;#开启目录浏览
		autoindex_format html;#以html风格将目录展示在浏览器中
		autoindex_exact_size off;#切换为 off 后， 以可读的方式显示文件大小， 单位为 KB、 MB 或者 GB
		autoindex_localtime on;#以服务器的文件时间作为显示的时间
	}
}
```

部署步骤：
主服务器下载代码并编译：
1、git clone https://github.com/palliums-developers/violas-deploy.git  violas_scripts &&　cd violas_scripts 
2、./build_config.sh
备注：
运行build_config.sh时需要输入部署的节点数量、主服务器IP以及所有部署服务器的IP，以逗号分隔

各节点部署命令：
1、curl -O http://IP(主服务器IP)/deploy_node.sh && chmod 775 deploy_node.sh
2、./deploy_node.sh  #运行时弹出输入ip的提示，输入本服务器的IP地址回车
备注：
运行deploy_node.sh脚本时需要输入本节点ip，运行结束后自动生成violascfg文件夹，所有节点配置文件、脚本以及violas链启动后的数据文件均存放于此


部署脚本说明：
1、build_config.sh
实现功能：
(1)下载violas并编译;
(2)交互界面输入准备创建的节点数、部署服务器IP以及所有节点的IP（以逗号分隔），根据输入信息生成节点配置文件;
(3)将配置文件以及部署脚本打包并输出到nginx文件列表文件夹,路径：~/deploy_node
初始配置文件（mint.key、waypoint、随机种子等）存放路径：~/violas_scripts/config

2、deploy_node.sh
实现功能：
(1)下载violas源码并启动节点;
(2)运行时输入本节点IP地址，自动下载配置文件并启动节点
运行脚本后自动生成~/violascfg文件夹，所有节点配置文件以及启动后的数据文件均存放于此。

3、randseed
用于生成配置文件时的随机种子

4、start.sh
实现功能：启动节点

5、stop.sh
实现功能：关闭节点

6、clean_db_start.sh
实现功能：清除数据并重新启动节点

6、violas_error_send.py
实现功能：监控程序，通过监控pid进程号，如果violas节点异常断开后，自动读取报错日志并短信和手机通知运维人员，同时尝试重新启动节点

7、cli.sh
实现功能：violas客户端连接工具

8、violas_nginx.conf
实现功能：nginx配置文件访问列表，用于各节点下载对应的配置文件
