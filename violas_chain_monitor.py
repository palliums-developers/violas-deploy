#!/usr/bin/python3
  
import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.mime.multipart import MIMEMultipart
from smtplib import SMTP_SSL

import http.client
import urllib
import json

import os
import psutil
import time

def violas_error_sendmail(IP,error_file,servername,*receivers):
    #******设置发送邮件参数******
    # 第三方 SMTP 服务
    mail_host = "smtp.exmail.qq.com"  #设置服务器
    mail_user = "zyb@palliums.org"   #用户名
    mail_pass = "Qaz!123456"   #口令 
    
    sender = 'zyb@palliums.org'
    receivers = receivers 

    #创建一个带附件的实例
    message = MIMEMultipart()
    message['From'] = Header("violas", 'utf-8')
    message['To'] =  Header("zyb@palliums.org", 'utf-8')
    subject = servername + ' error info'
    message['Subject'] = Header(subject, 'utf-8')
    
    #邮件正文内容
    message.attach(MIMEText('这是' + servername + '[' + IP + ']报错信息，详见附件。', 'plain', 'utf-8'))
    
    # 构造附件1，传送当前目录下的 violas_log.txt 文件
    # violas_log = path + "/violas_error_log.txt"
    att1 = MIMEText(open(error_file, 'rb').read(), 'base64', 'utf-8')
    att1["Content-Type"] = 'application/octet-stream'
    # 这里的filename可以任意写，写什么名字，邮件中显示什么名字
    att1["Content-Disposition"] = 'attachment; filename="violas_error_log.txt"'
    message.attach(att1)

    try:
        # 使用25端口发送邮件
        # smtpObj = smtplib.SMTP() 
        # smtpObj.connect(mail_host, 25)    # 25 为 SMTP 端口号
    
        # 使用465端口发送邮件
        smtpObj = SMTP_SSL(mail_host)
        smtpObj.login(mail_user,mail_pass)  
        smtpObj.sendmail(sender, receivers, message.as_string())
        with open(log_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ "邮件发送成功\n")
        f.close()
    except smtplib.SMTPException as e:
        with open(log_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ "Error: 无法发送邮件\n")
            f.write(e + "\n")
        f.close()

def send_sms(apikey, text, mobile):
    #******设置发送短信参数******
    #服务地址
    sms_host = "sms.yunpian.com"
    voice_host = "voice.yunpian.com"
    #端口号
    port = 443
    #版本号
    version = "v2"
    #查账户信息的URI
    user_get_uri = "/" + version + "/user/get.json"
    #智能匹配模板短信接口的URI
    sms_send_uri = "/" + version + "/sms/single_send.json"

    """
    通用接口发短信
    """
    params = urllib.parse.urlencode({'apikey': apikey, 'text': text, 'mobile':mobile})
    headers = {
        "Content-type": "application/x-www-form-urlencoded",
        "Accept": "text/plain"
    }
    conn = http.client.HTTPSConnection(sms_host, port=port, timeout=30)
    conn.request("POST", sms_send_uri, params, headers)
    response = conn.getresponse()
    response_str = response.read()
    conn.close()
    return response_str

def violas_error_sendsms(IP,servername,error_file,mobile):
    #修改为您的apikey.可在官网（http://www.yunpian.com)登录后获取
    apikey = "c1c127eca677a50d341ded26d3022196"
    #修改为您要发送的手机号码，多个号码用逗号隔开
    # mobile = "18810656022"
    #修改为您要发送的短信内容
    text = "【Violas】您的 "+ servername + " 服务 " + IP + " 出现错误，请及时处理。"
    #查账户信息
    # print(get_user_info(apikey))
    #调用智能匹配模板接口发短信
    sms_info = send_sms(apikey,text,mobile)
    with open(error_file,'a',encoding = 'utf-8') as f:
        f.write("*************************************************************\n")            
        f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+"\n")
        f.write(sms_info.decode('utf-8') + "\n")
    f.close()

def checkprocess(processname):
    pl = psutil.pids()
    for pid in pl:
        if psutil.Process(pid).name() == processname:
            return pid

def get_filename(dir):
    cFileNumber = 0
    # dir = 'D:\workspace\python_workspace' #指定文件夹的路径
    for root, dirs, files in os.walk(dir):                      #遍历该文件夹
        for file in files:                                      #遍历刚获得的文件名files
            (filename, extension) = os.path.splitext(file)      #将文件名拆分为文件名与后缀
            if (extension == '.gz'):                             #判断该后缀是否为.c文件
                # cFileNumber= cFileNumber+1                      #记录.c文件的个数为对应文件号
                # print(cFileNumber, os.path.join(root,filename)) #输出文件号以及对应的路径加文件名
                # print("PLACE_RAM(" + filename + ')')           #以PLACE_RAM(文件名)形式输出文件名
                (filename, extension) = os.path.splitext(filename)
                return filename

def loopMonitor(IP,processname,servername,log_file,error_file):
    if isinstance(checkprocess(processname),int):
        print("The[ " + servername + " ]status is normal")
        with open(error_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")            
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ " The[ " + servername + " ]status is normal.\n")
        f.close()       
    else:
        print("The[ " + servername + " ]status is error")
        with open(error_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")            
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ " The[ " + servername + " ]status is error,Please check the log.\n")
            f.write("error info:\n")
            if os.path.exists(log_file):
                with open(log_file,encoding = 'utf-8') as fo:
                    txt=fo.readlines()
                keys=[k for k in range(0,len(txt))]
                result={k:v for k,v in zip(keys,txt[::-1])}
                num = 200
                if num >= len(txt):
                    num=len(txt)
                for i in range(num):
                    
                    f.write(result[num-1-i] + "\n")
                fo.close()
            else:
                f.write(log_file + " no exist!\n")           
        f.close()
        os.system("sh start.sh") #尝试重新启动服务

        violas_error_sendmail(IP,error_file,servername,*receivers)
        violas_error_sendsms(IP,servername,error_file,mobile)
    time.sleep(600)
    loopMonitor(IP,processname,servername,log_file,error_file)

if __name__ == '__main__':
    path = os.path.dirname(os.path.realpath(__file__))
    processname = "libra-node" #设置进程名称
    servername= "Violas Chain"   #设置服务名称
    log_file = path + "/violas.log"    #设置日志文件路径
    error_file = path + "/violas_error_log.txt"  #设置发送错误邮件日志路径
    IP = get_filename(path)          #设置部署服务器IP
    mobile = "18810656022"  #设置接收短信的手机号，多个号码用逗号隔开
    receivers = ['zyb@palliums.org']  #设置接收邮件人列表，多个接收人用逗号隔开
    loopMonitor(IP,processname,servername,log_file,error_file)
