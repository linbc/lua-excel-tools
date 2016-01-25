-- 项目管理面板
local ProjectMgr = {}

function ProjectMgr:create(mainFrame)
	self.mainFrame = mainFrame
	local parent = mainFrame.panel1

	-- 校验配置根目录
	self.rootPath = conf.rootPath..'/data'
	if not dirExists(self.rootPath) then
		lfs.mkdir(self.rootPath)
	end

	local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
	local staticBox1 = wx.wxStaticBox(parent, wx.wxID_ANY, '')
	local listBox = wx.wxListBox(parent, wx.wxID_ANY, 
								wx.wxDefaultPosition,
	                            wx.wxDefaultSize)
	self.listBox = listBox

	local button = wx.wxButton(staticBox1, wx.wxID_ANY, 
								U2G('新 建'),
								wx.wxPoint(10, 10),
	                        	wx.wxSize(60, 20))
	local button2 = wx.wxButton(staticBox1, wx.wxID_ANY, 
								U2G('删 除'),
							 	wx.wxPoint(80, 10),
	                            wx.wxSize(60, 20))

	sizer:Add(listBox,  10, wx.wxALL + wx.wxGROW, 5)
	sizer:Add(staticBox1, 1, wx.wxALL + wx.wxGROW, 5)
	parent:SetSizer(sizer)
	sizer:SetSizeHints(parent)
	
	button:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, function () 
		local val = wx.wxGetTextFromUser(U2G("请输入项目名称"), U2G("新建项目"), '')
		if not val or string.len(val) == 0 then
			return
		end
		local dir = self.rootPath..'/'..val
		if not dirExists(dir) then
			lfs.mkdir(dir)
		end
		self:updateProject(listBox, val)
	end)

	button2:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, function () 
		local selName = listBox:GetStringSelection()
		local val = wx.wxMessageBox(U2G("是否删除["..selName.."]项目"), U2G("警告"), wx.wxOK + wx.wxCANCEL + wx.wxCENTRE)
		if val == wx.wxOK then
			local dir = self.rootPath..'/'..selName
			if not dirExists(dir) then
				return
			end
			rmdir(dir)
			self:updateProject(listBox)
		end
	end)

	listBox:Connect(wx.wxEVT_COMMAND_LISTBOX_SELECTED, function () 
		self:selectProject(listBox, listBox:GetStringSelection())
	end)

	self:updateProject(listBox)
end

-- 刷新项目列表
function ProjectMgr:updateProject(listBox, stringSelection)
	local pathes = pathes or {}
    ret, files, iter = pcall(lfs.dir, self.rootPath)
    if ret then
		for entry in files, iter do
			local next = false
			if entry ~= '.' and entry ~= '..' then
			    local path = self.rootPath .. '/' .. entry
			    local attr = lfs.attributes(path)
			    if attr == nil then
			        next = true
			    end
			    if next == false then 
			        if attr.mode == 'directory' then
			            table.insert(pathes, entry)
			        end
			    end
			end
			next = false
		end
    end
    listBox:Clear()
	listBox:Set(pathes)
	self:selectProject(listBox, stringSelection)
end

function ProjectMgr:selectProject(listBox, stringSelection)
	if not stringSelection then
		listBox:SetSelection(0)
	else
		listBox:SetStringSelection(stringSelection)
	end

	stringSelection = listBox:GetStringSelection()

	self.mainFrame.config:load('data/'..stringSelection)
	if self.mainFrame.projectInfo then
		self.mainFrame.projectInfo:updateConfig()
	end
	self.mainFrame.panel2:Show(true)
end

return ProjectMgr

