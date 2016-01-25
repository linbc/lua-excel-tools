require 'luaiconv'
require 'lfs'

function sleep(n)
   os.execute("sleep " .. n)
end

-- 编码转换
local function createIconv(to, from)  
	local cd = iconv.new(to, from)  
	return function(txt)  
	   return cd:iconv(txt)  
	end  
end  

G2U = createIconv('utf-8', 'gbk')  
U2G = createIconv('gbk', 'utf-8')  

-- 字符串分割
function split(str, delimiter)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

-- 获取目录下的文件列表
function getPathes(rootpath, pathes)
    pathes = pathes or {}

    local ret, files, iter = pcall(lfs.dir, rootpath)
    if ret == false then
        return pathes
    end
    for entry in files, iter do
        local next = false
        if entry ~= '.' and entry ~= '..' then
            local path = rootpath .. '/' .. entry
            local attr = lfs.attributes(path)
            if attr == nil then
                next = true
            end

            if next == false then 
                if attr.mode == 'directory' then
                    getPathes(path, pathes)
                else
                	path = string.gsub(path, '\\', '/')
                    table.insert(pathes, path)
                end
            end
        end
        next = false
    end
    return pathes
end

-- 目录是否存在
function dirExists( path )
	local currentdir = lfs.currentdir()
	local r, err = lfs.chdir(path)
	lfs.chdir(currentdir)
	return r
end

-- 获取路径  
function stripfilename(filename)  
    return string.match(filename, "(.+)/[^/]*%.%w+$")
end  
  
-- 获取文件名  
function strippath(filename)
    return string.match(filename, ".+/([^/]*%.%w+)$")
end  
  
-- 去除扩展名  
function stripextension(filename)  
    local idx = filename:match(".+()%.%w+$")  
    if(idx) then  
        return filename:sub(1, idx-1)  
    else  
        return filename  
    end  
end 

-- 获取文件扩展名
function getExtension(path)
    return path:match('.+%.(%w+)$')
end

local function _rmdir(path)
    path = string.gsub(path, '\\', '/')
    local lastChar = string.char(string.byte(path,string.len(path)))
    if lastChar ~= '/' then
    	path = path..'/'
    end
    local iter, dir_obj = lfs.dir(path)
    while true do
        local dir = iter(dir_obj)
      
        if dir == nil then break end
        if dir ~= "." and dir ~= ".." then
            local curDir = path..dir
            local mode = lfs.attributes(curDir, "mode") 
            if mode == "directory" then
                _rmdir(curDir.."/")
            elseif mode == "file" then
                lfs.rmdir(curDir)
            end
        end
    end
    local succ, des = lfs.rmdir(path)
    if des then print(des) end
    return succ
end

function rmdir(path)
    if dirExists(path) then
        _rmdir(path)
    end
end

function getServerTmpDir()
    local path = conf.rootPath..'/'..conf.projectPath..'/lua_s'
    if not dirExists( path ) then
        lfs.mkdir(path)
    end
    return path
end

function getClientTmpDir()
    local path = conf.rootPath..'/'..conf.projectPath..'/lua_c'
    if not dirExists( path ) then
        lfs.mkdir(path)
    end
    return path
end

-- 公式文件路径
function getConditionsPath()
    return conf.server_lua_dir..'/conditions.lua'
end    

-- 公式文件是否存在
function conditionsIsExists()
    local f, err=io.open(getConditionsPath(), 'r+')
    if not f then
        print(U2G('提示：找不到公式lua文件,请检查服务端lua目录配置'))
        return false
    end
    f:close()
    return true
end

-- lua文件头信息
fileHeaderLua =   '---------------------------------------------------------------------------------\n'..
                        '--------------------------以下代码为自动生成，请勿手工改动-----------------------\n'..
                        '---------------------------------------------------------------------------------\n'

-- as文件头信息
fileHeaderAS3 =   '//---------------------------------------------------------------------------------\n'..
                        '//--------------------------以下代码为自动生成，请勿手工改动-----------------------\n'..
                        '//---------------------------------------------------------------------------------\n'

-- 清理execl进程
function clearExecl()
    local pids = luacom.FindProcess('EXCEL.EXE')
    for _,pid in pairs(pids) do
        local P = winapi.process_from_id(pid)
        P:kill()
    end
end

-- 清理Lua文件
function clearLuaFile(dir)
    -- 获取子文件列表
    local pathes = {}
    getPathes(dir, pathes)
    for _, path in pairs(pathes) do
        if getExtension(path) == 'lua' then
            os.remove(path)
        end
    end
end

-- 清理As3文件
function clearAs3File(dir)
    -- 获取子文件列表
    local pathes = {}
    getPathes(dir, pathes)
    for _, path in pairs(pathes) do
        if getExtension(path) == 'as' then
            os.remove(path)
        end
    end
end

-- 打包目录下的lua文件到一个文件中
function packLuaFiles(path, filePath)
    if not dirExists(path) then
        return
    end
    os.remove(filePath)

    local data = fileHeaderLua
    local pathes = {}
    getPathes(path, pathes)
    for _, fpath in pairs(pathes) do
        if getExtension(fpath) == 'lua' then
            local f = io.open(fpath, 'r')
            local val = f:read("*a")
            data = data..string.sub(val, string.len(fileHeaderLua))
            f:close()
        end
    end
    local f = io.open(filePath, 'w')
    f:write(data)
    f:close()
end

-- 创建as3文件
function created_as3File(tName,  keys)
    local dir = conf.client_as_dir
    if not dirExists(dir) then
        return
    end

    local as3Name = ''
    local tokens = split(tName, '_')
    for i = 2, #tokens do
        local v = string.upper(string.sub(tokens[i], 1, 1)) .. string.sub(tokens[i], 2)
        as3Name = as3Name..v
    end
    as3Name = as3Name..'_T'
    local f
    local val = nil
    for i = 1, #keys do
        if string.find(keys[i].utype,  'C') then
            local t = '*'
            if keys[i].type == 'array' then
                t = 'Array'
            elseif keys[i].type == 'string' then
                t = 'String'
            elseif keys[i].type == 'int' then
                t = 'int'
            end
            val = (val or '')..'\n\t\t/**\n\t\t * '..keys[i].desc..'\n\t\t */\n\t\tpublic var '..keys[i].name..':'..t..';\n'
        end
    end
    if val then
        val = '\t\tpublic static const LUA_TABLE:String = "'..tName..'";\n'..val
        f = io.open(dir..'/'..as3Name..'.as', 'w')
        if f then
            f:write(fileHeaderAS3)
            f:write('\n\npackage cow.data.AppConst.lua.template\n{\n\tpublic class '..as3Name..'\n\t{\n')
            f:write(val)
            f:write('\t}\n}')
            f:close()
        end
    end
end

-- 生成客户端需要的资源文件
function created_clientDataFile(path)
    local dir = conf.client_data_dir
    if not dirExists(dir) then
        return
    end
    local fileName = 'tables.lua'
    local filePath = path..'/'..fileName
    packLuaFiles(path, filePath)
    -- 把公式文件内容一起打包进去
    local f = io.open(getConditionsPath(), 'r')
    local data = f:read("*a")
    f:close()
    f = io.open(filePath, 'a+')
    f:write('\n\n\n\n\n'..data)
    f:close()
	
	local outPath = dir..'/lua.data'
	local f, err=io.open(outPath, 'r+')
    if f then
		f:close()
		os.remove(outPath)
	end
    os.execute ('7z a -tzip '..outPath..' '..filePath)
end


-- 创建旧版模板工具表结构文件与数据文件并返回数据文件
function createdOldStuFile(tName,  keys)
    if not dirExists(conf.old_tool_data_dir) then
        return nil
    end

    local fileName = string.sub(tName, 4)
    if fileName == 'buff'
        or fileName == 'creature'
        or fileName == 'gameobject'
        or fileName == 'item'
        or fileName == 'mount'
    then
        fileName = fileName..'_template'
    elseif fileName == 'level' then
        fileName = 'char_level'
    elseif fileName == 'map'
        or fileName == 'suit'
    then
        fileName = fileName..'_info'
    elseif fileName == 'spell' then
        fileName = 'Spell_Template'
    end
    local f = io.open(conf.old_tool_data_dir..'/'..fileName..'.stu', 'w')

    local val = fileName..'\n#属性名|数据类型|备注|是否主键|非NULL|特殊数据结构|特殊数据长度|服务端生成|客户端生成|选项信息'
    local count = #keys
    for i = 1, count do
        local tssjjg = '0'
        local tssjcd = '0'
        local t = keys[i].type
        if t == 'number' then
            t = 'float'
        elseif t == 'string' then
            t = 'varchar'
            tssjcd = 50
		else
			if string.find(t, "array") then
				if string.len(t) == 5 then
					tssjcd = 40
				else
					tssjcd = string.sub(t, 7)
				end	
				t = 'float'
				tssjjg = '数组' 
			end			           
        end
        val = val..'\n'..keys[i].name..'|'
                ..t..'|'
                ..keys[i].desc..'|'
                ..(i == 1 and 1 or 0)..'|'
                ..(i == 1 and 1 or 0)..'|'
                ..tssjjg..'|'
                ..tssjcd..'|'
                ..(string.find(keys[i].utype,  'S') and 1 or 0)..'|'
                ..(string.find(keys[i].utype,  'C') and 1 or 0)..'|'
    end
    f:write(val)
    f:close()
    return io.open(conf.old_tool_data_dir..'/'..fileName..'.alldata', 'w')
end

-- 创建旧版模板工具表数据文件
function writeOldAllData(f,  data, keys)
    if not f then
        return
    end
    if not data or not data[1] or tonumber(data[1]) < 1 then
        return
    end
    local dataStr = nil
	local tempStr = nil
    -- 修复下后面的空数据
    for i = 1, #keys do
        dataStr = dataStr and dataStr..'|' or ''
		tempStr = data[i]        
		if tempStr and keys[i].type ~= "string" then
			tempStr = string.gsub(tempStr, '{', '')         -- 去掉table
			tempStr = string.gsub(tempStr, '}', '')         
		end
		dataStr = dataStr..(tempStr and tempStr or '')
    end
    if dataStr then
        if not fristWriteOldAllData then
            dataStr = '\n'..dataStr
        end        
        dataStr = string.gsub(dataStr, ',,', ',')       -- 去掉重复逗号
        f:write(dataStr)
        fristWriteOldAllData = false
    end
end

-- 创建服务端lua文件
function created_serverLuaFile()
    if true or not dirExists(conf.server_lua_dir) then
        --服务端lua文件暂由旧版模板工具生成
        return
    end
    packLuaFiles(getServerTmpDir(), conf.server_lua_dir..'/template.lua')
end