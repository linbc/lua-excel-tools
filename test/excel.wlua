
package.cpath = package.cpath..';./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;'
require 'wx'
require 'luacom'
require 'winapi'
require 'Util'
-----------------------------------------------------------------
local mainFrame = require('MainFrame')
mainFrame:create()

wx.wxGetApp():MainLoop()
