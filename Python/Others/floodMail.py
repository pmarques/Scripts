#!/usr/bin/python
# -*- coding: utf-8 -*-

import smtplib  
from email.mime.text import MIMEText
from time import sleep
import sys

smptServer = 'smtp.gmail.com:587'
numberMessages = 10 * 1000 * 1000 # Flood... :D

fromaddr = 'From Complete Name <a@b.c>'
toaddrs  = 'To User Name <d@e.f>'  

# Credentials (if needed)  
username = '<username>'
password = '<password>'

# The actual mail send  
server = smtplib.SMTP( smptServer ) 
server.starttls()  
server.login(username,password)  

write = sys.stdout.write
for i in range( numberMessages ):
  msg = MIMEText('content' )
  msg['Subject'] = '<subject>'
  msg['From'] = fromaddr
  msg['To'] = toaddrs
  msg = msg.as_string()
  server.sendmail(fromaddr, toaddrs, msg)
  write('\r%4d' % (i + 1))
  sys.stdout.flush()
  sleep(5)

print "\nDone :)"
server.quit()
