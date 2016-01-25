-- Excel相关操作
local Excel = {}

local columns = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'}

-- 处理的文件总数
filesTotal = 0
-- 已处理的文件数
filesConverted= 0
-- 当前处理的文件名
curFileName = ''

-- 生成lua
function Excel.toLua(path, createdServer, createdClient, updateProgressFunc)
  	local excel = luacom.GetObject('Excel.Application')
  	if not excel then
		excel = luacom.CreateObject('Excel.Application')
	end
	if excel ==  nil then 
		error('Object is not create') 
	end
	excel.Application.DisplayAlerts = false
	local t=io.open(path, 'r')
	if not t then
		-- 文件不存在
		excel.Application:quit()
		excel = nil
		filesConverted = filesConverted + 1
		if updateProgressFunc then
			updateProgressFunc()
		end
		return
	else
	 	t:close()
	end
	-- 当前处理的文件名
	curFileName = strippath(path)
	excel.Visible = false
	local book = excel.WorkBooks:Open(G2U(path),nil,ReadOnly)
	book.Saved = false
	local e = luacom.GetEnumerator(excel.Sheets)
	local sheet = e:Next()
	while sheet do
		if string.find(sheet.Name, conf.table_prefix) == 1 then
			Excel.sheetToTable(sheet, createdServer, createdClient)
		end
		sheet = e:Next()
	end
	sheet = nil
	e = nil
	book:Close()
	book = nil
	excel.Application:Quit()
	excel = nil
	filesConverted = filesConverted + 1
	if updateProgressFunc then
		updateProgressFunc()
	end
	collectgarbage()
end

-- 读取表格
function Excel.sheetToTable(sheet, createdServer, createdClient)
	-- 表名
	local tName = sheet.name
	window:SetStatusText(string.format('%s : %s --> lua : %u%%', curFileName, tName, 0), 2)

	local maxRows = sheet.Usedrange.Rows.count
	local maxColumns = sheet.Usedrange.columns.count
	local columnName = ''
	local num = math.floor((maxColumns - 1) / 26)
	if num > 0 then
		columnName = columnName..columns[num]
	end
	local idx = maxColumns % 26
	if idx == 0 then
		idx = 26
	end
	columnName = columnName..columns[idx]
	-- 表字段集合
	local keys = {}
	local range = sheet:Range('A1:'..columnName..4)    --读一个区域
	local data = range.Value2
	local idx = 1
	while true do
		local key = data[3][idx]
		if not key or string.len(key) == 0 then
			break
		end
		-- 字段结构体
		local keyStruct = {}
		keyStruct.name = key 						-- 字段的名称
		keyStruct.type = data[2][idx]		-- 字段的类型
		keyStruct.desc = data[4][idx]		-- 字段的说明
		keyStruct.utype = data[1][idx]      -- 字段使用类型		
		table.insert(keys, keyStruct)
		idx = idx + 1
	end
	data = nil
	range = nil

	-- 创建lua数值表文件
	local lua_sf = nil
	if createdServer then
		-- 写入table前部分
		lua_sf = Excel.writeTableFront('S', tName, keys)
	end
	local lua_cf = nil
	if createdClient then
		-- 写入table前部分
		lua_cf = Excel.writeTableFront('C', tName, keys)
	end

	-- 创建旧版模板表结构文件
	local oldDataFile = createdOldStuFile(tName, keys)
	fristWriteOldAllData = true
	-- 生成客户端模版类
	if lua_cf then
		created_as3File(tName, keys)
	end
	-- 写入数据
	local idx = 5
	while idx < maxRows + 1 do
		local toColumn = idx + conf.batch_num
		if toColumn > maxRows then
			toColumn = maxRows
		end
		local range = sheet:Range('A'..idx..':'..columnName..toColumn)    --读一个区域
		local data = range.Value2
		for i = 1, #data do
			local id = idx + i - 1
			-- 写入table数据
			Excel.writeTableData(lua_sf, 'S', data[i], keys)
			Excel.writeTableData(lua_cf, 'C', data[i], keys)
			writeOldAllData(oldDataFile, data[i], keys)
			window:SetStatusText(string.format('%s : %s --> lua : %u%%', curFileName, tName, (toColumn - 5) / (maxRows - 5) * 100), 2)
			v = nil
		end
		data = nil
		range = nil
		idx = toColumn + 1
	end
	-- 写入table结尾
	Excel.writeTableBack(lua_sf)
	Excel.writeTableBack(lua_cf)
	-- 关闭文件
	if lua_sf then
		lua_sf:close()
	end
	if lua_cf then
		lua_cf:close()
	end

	if oldDataFile then
		oldDataFile:close()
	end
end

-- 写入table前部分包含 表名 字段说明
function Excel.writeTableFront(utype, tName,  keys)
	local f
	local val = nil
	for i = 1, #keys do
		if string.find(keys[i].utype,  utype) then
			val = (val or '')..'\t--  '..keys[i].name..':'..keys[i].type..'\t'..keys[i].desc..'\n'
		end
	end
	if utype == 'S' then
		f = io.open(getServerTmpDir()..'/'..tName..'.lua', 'w')
	elseif utype == 'C' then
		local dir = getClientTmpDir()
		if not dirExists(dir) then
			lfs.mkdir(dir)
		end
		f = io.open(dir..'/'..tName..'.lua', 'w')
	end
	if f then
		f:write(fileHeaderLua)
		f:write('\n\n'..tName..' = {\n')
		if val then
			f:write(val)
		end
	end
	return f
end

-- 写入table数据
function Excel.writeTableData(f, utype, data,  keys)
	if not f then
		return
	end
	if not data[1] then
		return
	end
	local dataStr = '\t['..data[1]..'] = {'
	for i = 1, #keys do
		if string.find(keys[i].utype,  utype) then
			local val
			if keys[i].type == 'int' or keys[i].type == 'number' then
				val = data[i] or 0
			elseif keys[i].type == 'array' then
				val = '{'..(data[i] or '')..'}'
			else
				val = '"'..(data[i] or '')..'"'
			end
			dataStr = dataStr..keys[i].name..' = '..val..','
		end
	end
	dataStr = dataStr..'},\n'
	f:write(dataStr)
end

function Excel.writeTableBack(f)
	if f then
		f:write('}\n')
	end
end

return Excel