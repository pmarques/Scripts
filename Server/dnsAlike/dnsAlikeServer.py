#!/usr/bin/python

import socket
import sys

HOST = None               # Symbolic name meaning all available interfaces
PORT = 50000              # Arbitrary non-privileged port
s = None

for res in socket.getaddrinfo(HOST, PORT, socket.AF_UNSPEC, socket.SOCK_STREAM, 0, socket.AI_PASSIVE):
  af, socktype, proto, canonname, sa = res
  try:
    s = socket.socket(af, socktype, proto)
  except socket.error, msg:
    s = None
    continue
  try:
    s.bind(sa)
    s.listen(1)
  except socket.error, msg:
    s.close()
    s = None
    continue
  break

if s is None:
  print 'Could not open socket'
  sys.exit(1)

while 1:
  conn, addr = s.accept()
  print 'Connected by', addr

  try:
    running = True
    while running:
      data = conn.recv(1024)
      if not data:
        break
      f = open('ip.txt', 'w')
      f.write(data)
    # end while
  except Exception:
    print "lost connection, wait another..."

f.close()
conn.close()
