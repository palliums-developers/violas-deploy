前置条件：
1、系统：ubuntu16.04 18.04 安装git、nginx；
2、各服务器开放40002,50001端口；
3、nginx配置文件访问列表，用于各节点下载对应的配置文件；
ngixn配置文件路径/etc/nginx/sites-enabled/violas_nginx.conf：
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
1、运行编译脚本<build_config.sh>，根据提示信息输入需要部署节点的数量、IP地址等信息，脚本运行结束后会显示运行结果并显示配置文件路径以及验证节点和全节点下载链接；
2、登录需要部署的验证节点和全节点服务器，使用第一步骤生成的链接，使用curl下载部署脚本<deploy_node.sh>；
运行如下面命令（注：全节点和验证节点下载的链接不同，根据第一步骤生成的链接下载）：
curl -O http://IP(主服务器IP)/deploy_node.sh && chmod 775 deploy_node.sh
3、登录各服务器运行部署脚本，根据提示输入对应IP自动完成部署并启动节点，部署后配置文件、脚本以及数据文件存放路径：/home/ops/violascfg


部署脚本说明：
1、build_config.sh
实现功能：
(1)下载violas并编译;
(2)交互界面输入准备部署的节点数、部署服务器IP以及所有节点的IP（以逗号分隔），根据输入信息生成节点配置文件;
(3)将配置文件以及部署脚本打包并输出到nginx文件列表文件夹,路径：$HOME/deploy_node
初始配置文件以及mint.key存放路径：$HOME/violas-deploy/config

2、deploy_node.sh
实现功能：
运行时输入本节点IP地址，自动下载配置文件并启动节点
运行脚本后自动生成$HOME/violascfg文件夹，所有节点配置文件以及启动后的数据文件均存放于此。

3、randseed
用于生成配置文件时的随机种子,使用swarm方式生成配置文件未用到

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

9、config.ini
实现功能：初始化配置文件，记录邮件、短信等配置信息，部署后需要手动上传到服务器的violascfg文件夹
