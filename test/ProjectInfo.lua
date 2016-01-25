-- 项目信息面板
local ProjectInfo = {}

-- 控件ID
local ID_EXCEL 			= 1
local ID_OLD_DATA 		= 2
local ID_SERVER_TMP 	= 3
local ID_SERVER_LUA		= 4
local ID_CLIENT_TMP 	= 5
local ID_CLIENT_DAT		= 6
local ID_CLIENT_AS		= 7
local ID_TEXT_CTRL 		= 8

-- 获取目录
local function getDirByBtnClick(btnID, cb, title)
	if not btnID or not cb then 
		return
	end
	window:Connect(btnID,  wx.wxEVT_COMMAND_BUTTON_CLICKED,  function (event)
	    local dialog = wx.wxDirDialog(window, title or 'Select Directory',
	                                      '',
	                                      0,
	                                      wx.wxPoint(50, 50))
	    if dialog:ShowModal() == wx.wxID_OK then
	    	local path = dialog:GetPath()
	    	path = string.gsub(path, '\\', '/')
	    	cb(path)
	    end
	    dialog:Destroy()
	end)
end

function ProjectInfo:create(mainFrame)
	self.mainFrame = mainFrame
	local parent = mainFrame.panel2
	local config = mainFrame.config

	local sizer = wx.wxBoxSizer(wx.wxVERTICAL)
	local staticBox1 = wx.wxStaticBox( parent, wx.wxID_ANY, U2G('数据相关配置'))
	local staticBox2 = wx.wxStaticBox( parent, wx.wxID_ANY, U2G('服务端相关配置'))
	local staticBox3 = wx.wxStaticBox( parent, wx.wxID_ANY, U2G('客户端相关配置'))
	local staticBox4 = wx.wxStaticBox( parent, wx.wxID_ANY, U2G('操作相关配置'))
	sizer:Add(staticBox1, 32, wx.wxALL + wx.wxGROW, 5)
	sizer:Add(staticBox2, 22, wx.wxALL + wx.wxGROW, 5)
	sizer:Add(staticBox3, 34, wx.wxALL + wx.wxGROW, 5)
	sizer:Add(staticBox4, 12, wx.wxALL + wx.wxGROW, 5)
	parent:SetSizer(sizer)
	sizer:SetSizeHints(parent)

	local excelButton1 = wx.wxButton(staticBox1, ID_EXCEL, U2G('Excel 目录:'), wx.wxPoint(20, 20)) 
	self.excelText1 = wx.wxStaticText(staticBox1, wx.wxID_ANY, conf.excel_dir, wx.wxPoint(20, 50))
	getDirByBtnClick(ID_EXCEL, function ( dir)
		conf.excel_dir = dir
		config:save()
		self.excelText1:SetLabel(conf.excel_dir)
	end)

	local odlTemplateButton = wx.wxButton(staticBox1, ID_OLD_DATA, U2G('旧版模板数据目录:'), wx.wxPoint(20, 80)) 
	self.odlTemplateText = wx.wxStaticText(staticBox1, wx.wxID_ANY, conf.old_tool_data_dir, wx.wxPoint(20, 110))
	getDirByBtnClick(ID_OLD_DATA, function ( dir)
		conf.old_tool_data_dir = dir
		config:save()
		self.odlTemplateText:SetLabel(conf.old_tool_data_dir)
	end)

	local serverButton2 = wx.wxButton(staticBox2, ID_SERVER_LUA, U2G('lua目录:'), wx.wxPoint(20, 20)) 
	local tipText = wx.wxStaticText(staticBox2, wx.wxID_ANY, U2G('服务端lua文件由旧版模板工具生成,这边把公式lua打包到客户端'), wx.wxPoint(100, 22))
	
	--tipText:SetStyle(0,10000,wx.wxTextAttr(wx.wxRED, wx.wxBLUE ))
	self.serverText2 = wx.wxStaticText(staticBox2, wx.wxID_ANY, conf.server_lua_dir, wx.wxPoint(20, 50))
	getDirByBtnClick(ID_SERVER_LUA, function ( dir)
		conf.server_lua_dir = dir
		config:save()
		self.serverText2:SetLabel(conf.server_lua_dir)
	end)
	
	local clientButton2 = wx.wxButton(staticBox3, ID_CLIENT_DAT, U2G('data目录:'), wx.wxPoint(20, 20)) 
	self.clientText2 = wx.wxStaticText(staticBox3, wx.wxID_ANY, conf.client_data_dir, wx.wxPoint(20, 50))
	getDirByBtnClick(ID_CLIENT_DAT, function ( dir)
		conf.client_data_dir = dir
		config:save()
		self.clientText2:SetLabel(conf.client_data_dir)
	end)

	local clientButton3 = wx.wxButton(staticBox3, ID_CLIENT_AS, U2G('as类目录:'), wx.wxPoint(20, 80)) 
	self.clientText3 = wx.wxStaticText(staticBox3, wx.wxID_ANY, conf.client_as_dir, wx.wxPoint(20, 110))
	getDirByBtnClick(ID_CLIENT_AS, function ( dir)
		conf.client_as_dir = dir
		config:save()
		self.clientText3:SetLabel(conf.client_as_dir)
	end)


	local optText1 = wx.wxStaticText( staticBox4, wx.wxID_ANY, U2G('table 前缀:'), wx.wxPoint(20, 26))
	self.optTextCtrl1 = wx.wxTextCtrl( staticBox4, wx.wxID_ANY, conf.table_prefix, wx.wxPoint(90, 23), wx.wxDefaultSize, wx.wxTE_PROCESS_ENTER )
	self.optTextCtrl1:Connect(wx.wxEVT_COMMAND_TEXT_UPDATED, function () 
		conf.table_prefix = self.optTextCtrl1:GetValue()
		config:save()
	end)
	local optText2 = wx.wxStaticText( staticBox4, wx.wxID_ANY, U2G('批次处理数:'), wx.wxPoint(200, 26))
	self.optTextCtrl2 = wx.wxTextCtrl( staticBox4, wx.wxID_ANY, tostring(conf.batch_num), wx.wxPoint(270, 23), wx.wxDefaultSize, wx.wxTE_PROCESS_ENTER )
	self.optTextCtrl2:Connect(wx.wxEVT_COMMAND_TEXT_UPDATED, function () 
		conf.batch_num = tonumber(self.optTextCtrl2:GetValue()) or 1
		config:save()
	end)

	-- 全部生成
	local buttonCreatedAll = wx.wxButton(staticBox4, wx.wxID_ANY, U2G('全部生成'), wx.wxPoint(380, 22)) 
	buttonCreatedAll:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, function () 
		if not dirExists(conf.excel_dir) then 
			print(U2G('生成失败：无效的Excel目录'))
			return
		end
		if not conditionsIsExists() then
			return
		end
		local server_dir_exists = true
		local client_dir_exists = true

		local tips = nil
		if not dirExists(getServerTmpDir()) then 
			tips = tips or ''
			tips = tips..'-无效的服务端lua目录'
			server_dir_exists = false
		else
			-- 清理目录
			clearLuaFile(getServerTmpDir())
		end
		if not dirExists(getClientTmpDir()) then 
			tips = tips or ""
			tips = tips..'-无效的客户端lua目录'
			client_dir_exists = false
		else
			-- 清理目录
			clearLuaFile(getClientTmpDir())
			clearAs3File(conf.client_as_dir)
		end
		if tips then
			print(U2G('提示：'..tips))
		end
		
		-- 获取子文件列表
		local pathes = {}
		getPathes(conf.excel_dir, pathes)
		-- 获取excel文件列表
		local excelFiles = {}
		for _, path in pairs(pathes) do
			if getExtension(path) == 'xlsx' then
				table.insert(excelFiles, path)
			end
		end
		filesTotal = #excelFiles
		filesConverted = 0
		self.mainFrame:updateConvertProgress()
		if filesTotal > 0 then
			self.mainFrame.panel0:Enable(false)
			window:SetStatusText(U2G('处理中，请稍后...'))
			for _, path in pairs(excelFiles) do
				self.mainFrame.excel.toLua(path, server_dir_exists, client_dir_exists,function ()
					self.mainFrame:updateConvertProgress()
				end)
			end		
			self.mainFrame.panel0:Enable(true)
			created_serverLuaFile()
			created_clientDataFile(getClientTmpDir())
			clearExecl()
			window:SetStatusText(U2G('处理完成。'))
		else
			print(U2G('提示：此目录下无可用表格'))
			self.mainFrame:updateConvertProgress()
			window:SetStatusText('', 2)
		end
	end)

	-- 单表生成
	local buttonCreated = wx.wxButton(staticBox4, wx.wxID_ANY, U2G('单表生成'), wx.wxPoint(460, 22)) 
	buttonCreated:Connect(wx.wxEVT_COMMAND_BUTTON_CLICKED, function () 
		local dlg = wx.wxFileDialog(window, "Choose Excel Files",
	                                conf.excel_dir, "", "Excel Files (*.xlsx)|*.xlsx",
	                                wx.wxFD_OPEN + wx.wxFD_FILE_MUST_EXIST + wx.wxFD_CHANGE_DIR )
		if dlg:ShowModal() == wx.wxID_OK then
			if not conditionsIsExists() then
				return
			end
	        filesTotal = 1
			filesConverted = 0
			window:SetStatusText(U2G('处理中，请稍后...'))
			self.mainFrame:updateConvertProgress()
	        local path = dlg:GetPath()
	        path = string.gsub(path, '\\', '/')
	       	self.mainFrame.panel0:Enable(false)
	       	self.mainFrame.excel.toLua(path, dirExists(getServerTmpDir()), dirExists(getClientTmpDir()),function ()
				self.mainFrame:updateConvertProgress()
			end)
			self.mainFrame.panel0:Enable(true)
			created_serverLuaFile()
			created_clientDataFile(getClientTmpDir())
			clearExecl()
			window:SetStatusText(U2G('处理完成。'))
			self.mainFrame:updateConvertProgress()
			window:SetStatusText('', 2)
	    end
	end)
end

function ProjectInfo:updateConfig( ... )
	-- body
	self.excelText1:SetLabel(conf.excel_dir)
	self.odlTemplateText:SetLabel(conf.old_tool_data_dir)
	self.serverText2:SetLabel(conf.server_lua_dir)
	self.clientText2:SetLabel(conf.client_data_dir)
	self.clientText3:SetLabel(conf.client_as_dir)
end

return ProjectInfo