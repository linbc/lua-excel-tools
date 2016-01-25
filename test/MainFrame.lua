-- 项目信息面板
local MainFrame = {}


function MainFrame:create()
	-- 创建窗体
	local w = 800
	local h = 600
	window=wx.wxFrame(wx.NULL,wx.wxID_ANY, 'Excel to lua Tool', wx.wxDefaultPosition, wx.wxSize(w, h), wx.wxRESIZE_BORDER+wx.wxSYSTEM_MENU+wx.wxCAPTION+wx.wxCLOSE_BOX)
	window:Show(true)
	window:CreateStatusBar(3)
	window:SetStatusWidths({100, 40, -1})
	window:SetStatusText(U2G('欢迎使用本工具'))

	self.window = window
	-- 主面板
	local panel0 = wx.wxPanel(window, wx.wxID_ANY)
	panel0:SetSize(w, h)
	local sizer0 = wx.wxBoxSizer(wx.wxHORIZONTAL)
	local panel1 = wx.wxPanel(panel0, wx.wxID_ANY, 
								wx.wxDefaultPosition, 
								wx.wxDefaultSize)
	local panel2 = wx.wxPanel(panel0, wx.wxID_ANY,
								wx.wxDefaultPosition, 
								wx.wxDefaultSize)

	local panel1StaticBox = wx.wxStaticBox( panel0, wx.wxID_ANY, U2G('项 目'))
	local panel1BoxStaticBoxSizer = wx.wxStaticBoxSizer( panel1StaticBox, wx.wxVERTICAL );
	panel1BoxStaticBoxSizer:Add(panel1, 1, wx.wxALL + wx.wxGROW, 5)

	local panel2BoxStaticBox = wx.wxStaticBox( panel0, wx.wxID_ANY, U2G('信 息'))
	local panel2BoxStaticBoxSizer = wx.wxStaticBoxSizer( panel2BoxStaticBox, wx.wxVERTICAL );
	panel2BoxStaticBoxSizer:Add(panel2, 1, wx.wxALL + wx.wxGROW, 5)

	sizer0:Add(panel1BoxStaticBoxSizer, 1, wx.wxALL + wx.wxGROW, 5)
	sizer0:Add(panel2BoxStaticBoxSizer, 3, wx.wxALL + wx.wxGROW, 5)
	panel0:SetSizer(sizer0)
	sizer0:SetSizeHints(panel0)

	self.panel0 = panel0
	self.panel1 = panel1
	self.panel2 = panel2
	self.panel2:Show(false)

	self.config = require('Config')
	self.config:create()

	self.projectMgr = require('ProjectMgr')
	self.projectMgr:create(self)

	self.projectInfo = require('ProjectInfo')
	self.projectInfo:create(self)

	self.excel = require('Excel')
end

-- 刷新生成进度显示
function MainFrame:updateConvertProgress()
	window:SetStatusText(filesTotal == 0 and '' or string.format("%u%%", filesConverted / filesTotal * 100) , 1)
end

return MainFrame