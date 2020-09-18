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

def violas_error_sendmail(path,ip,log_file):
    #******设置发送邮件参数******
    # 第三方 SMTP 服务
    mail_host="smtp.exmail.qq.com"  #设置服务器
    mail_user="zyb@palliums.org"    #用户名
    mail_pass="Qaz!123456"   #口令 
    
    sender = 'zyb@palliums.org'
    receivers = ['zyb@palliums.org'] 

    #创建一个带附件的实例
    message = MIMEMultipart()
    message['From'] = Header("violas", 'utf-8')
    message['To'] =  Header("zyb@palliums.org", 'utf-8')
    subject = 'Violas chain error info'
    message['Subject'] = Header(subject, 'utf-8')
    
    #邮件正文内容
    message.attach(MIMEText('这是violas[' + ip + ']报错信息，详见附件。', 'plain', 'utf-8'))
    
    # 构造附件1，传送当前目录下的 violas_log.txt 文件
    violas_log = path + "/violas_error_log.txt"
    att1 = MIMEText(open(violas_log, 'rb').read(), 'base64', 'utf-8')
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

def violas_error_sendsms(ip,log_file):
    #修改为您的apikey.可在官网（http://www.yunpian.com)登录后获取
    apikey = "c1c127eca677a50d341ded26d3022196"
    #修改为您要发送的手机号码，多个号码用逗号隔开
    mobile = "18810656022"
    #修改为您要发送的短信内容
    text = "【Violas】您的violas服务 " + ip + " 出现错误，请及时处理。"
    #查账户信息
    # print(get_user_info(apikey))
    #调用智能匹配模板接口发短信
    sms_info = send_sms(apikey,text,mobile)
    with open(log_file,'a',encoding = 'utf-8') as f:
        f.write("*************************************************************\n")            
        f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+"\n")
        f.write(sms_info.decode('utf-8'))
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

def loopMonitor(path,log_file):
    nohup_file = path + "/violas.log"
    if isinstance(checkprocess("libra-node"),int):
        print("The violas chain status is normal")
        with open(log_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")            
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ " The violas chain status is normal.\n")
        f.close()       
    else:
        print("The violas chain status is error")
        with open(log_file,'a',encoding = 'utf-8') as f:
            f.write("*************************************************************\n")            
            f.write("TIME:" +time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))+ " The violas chain status is error,Please check the log.\n")
            f.write("error info:\n")
            if os.path.exists(nohup_file):
                with open(nohup_file,encoding = 'utf-8') as fo:
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
                f.write(nohup_file + " no exist!\n")           
        f.close()
        os.system("sh start.sh")

        #设置部署文件的路径，获取文件名(文件名是以ip命名的)
        IP = get_filename(path)
        violas_error_sendmail(path,IP,log_file)
        violas_error_sendsms(IP,log_file)
    time.sleep(600)
    loopMonitor(path,log_file)

if __name__ == '__main__':
    path = os.path.dirname(os.path.realpath(__file__))
    log_file = path + "/violas_error_log.txt"
    loopMonitor(path,log_file)
