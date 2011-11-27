#!/usr/bin/env python

#
# Copyright (C) 2011 by Patrick F. Marques @K2C
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

__author__     = "Patrick F. Marques"
__copyright__  = "Copyright 2011, Patrick F. Marques @ K2C"
__credits__    = ["Patrick F. Marques", "K2C"]
__license__    = "MIT"
__version__    = "0.1"
__maintainer__ = "Patrick Marques"
__email__      = "patrick.marques@k2c.eu"
__status__     = "Production"

import threading
import logging
  
LOG = logging.getLogger("cli")
logging.basicConfig(format='%(asctime)s - %(levelname)s - %(message)s')

class CLI(threading.Thread):
  """Use CLI"""
  def __init__(self, staticParams = None, logLevel = logging.ERROR):
    threading.Thread.__init__ (self)

    self.cmdList = {"exit": self.stop}
    self.cmdList["h"] = self.listCMD
    self.running = True
    self.staticParams = staticParams

    LOG.setLevel(logLevel)
    LOG.debug("CLI init")

  def add(self, name, func):
    self.cmdList[name] = func

  def confOnExit(self, fun, params = None):
    self.onExitFun = fun
    self.onExitPrams = params

  def run(self):
    LOG.debug("Start CLI main loop")
    while self.running:
      try:
        inp = raw_input(">> ")
        if len(inp) <= 0:
          continue
        parts = inp.split(' ',1)
        cmd = parts[0].lower()
        params = parts[1] if len(parts) > 1 else None
        self.process(cmd, params)
      except:
        print '-'*60
        LOG.exception("Something is going wrong...")
        print '-'*60
    # END while
    self.onExit()

  def process(self, cmd, params):
    try:
      func = self.cmdList[cmd]
    except KeyError:
      print "Unknown command [%s]" % cmd
      return
    func(params, self.staticParams)

  def stop(self, params, _):
    LOG.debug("Stop CLI main loop")
    self.running = False
    print "Have a nice day :)"

  def listCMD(self, params, _):
    LOG.debug("List all available commands")
    for f in self.cmdList:
      print " * %s" % (f)

  def onExit(self):
    LOG.debug("Call on Exit handler")
    if hasattr(self, 'onExitFun'):
      self.onExitFun(self.onExitPrams)
#end Class CLI

def helpCMD(_, __):
  print "Simple test... run/execute 'exit' to exit from it!"

def test():
  """main function"""
  cli = CLI()
  cli.add("help", helpCMD)
  cli.start()
  cli.join()

if __name__ == "__main__":
    test()
