前置条件：系统：ubuntu16.04 安装git、nginx；
nginx配置文件访问列表，用于下载各节点配置文件；
ngixn配置文件/etc/nginx/sites-enabled/violas_node.conf：
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

各服务器开放40001,40002端口；

生成配置文件命令：
1、git clone http://148.70.43.108/zhaoyubin/violas_scripts.git &&　cd violas_scripts 
2、./build_config.sh
3、cd config  编辑ip_node文件，将部署的ip与节点绑定
例如：47fdee683e450c636184518cf048e5795c10cd385906f684431f4b32d5442950 52.151.2.66
4、cd .. && ./ip_config.sh

各节点部署命令：
1、curl -O http://51.140.241.96/deploy_node.sh && chmod 775 deploy_node.sh
2、sudo chmod 775 deploy_node.sh
3、./deploy_node.sh  #编译结束后会弹出输入ip的提示，输入本服务器的IP地址回车



部署脚本说明：
1、运行deploy_node.sh脚本后自动生成violascfg文件夹，所有节点配置文件以及启动后的数据文件均存放于此
2、部署时根据生成配置文件服务器的ip替换deploy_node.sh中和1中的IP


1、build_config.sh
实现功能：
(1)下载violas并编译;
(2)交互界面输入准备创建的节点数，根据输入数量生成节点配置文件;
(3)获取节点信息并输出到ip_node文件；
配置文件存放路径：~/violas_scripts/config
config目录文件清单：(1)0-n:各节点配置文件(2)faucet_keys:铸币秘钥(3)ip_node:用于节点与IP绑定

2、update_config.sh
实现功能：
(1)编辑*.seed_peers.config.toml和node.config.toml配置文件项，配置访问端口以及节点绑定ip使节点之间可以互相通信；
(2)将配置文件以及部署脚本打包并输出到nginx文件列表文件夹

3、randseed
用于生成配置文件时的随机种子

4、deploy_node.sh
实现功能：
(1)下载violas编译并启动节点;
(2)/etc/crontab中添加监控指令并下载monitor.sh、update_ip_config.sh、update_node.sh
运行脚本后自动生成~/violascfg文件夹，所有节点配置文件以及启动后的数据文件均存放于此。

5、monitor.sh
实现功能：：监控节点运行，每隔5秒检查节点进程是否存在，进程不存在则重启节点，可调整脚本中step参数变更监控时长

6、update_ip_config.sh
实现功能：某个节点ip变更后重新更新配置文件

7、update_node.sh
实现功能：用于violas版本更新后的升级
