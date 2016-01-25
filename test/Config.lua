-- 配置文件处理
local Config = {}

local fileName = 'conf'

function Config:create()
	conf = {}
	conf.rootPath = string.gsub(lfs.currentdir(), '\\', '/')
end

function Config:reset()
	conf.excel_dir 				= U2G('请选择excel目录')
	conf.old_tool_data_dir 		= U2G('请选择旧版模板数据目录')

	conf.server_lua_dir 		= U2G('请选择服务端lua目录')

	conf.client_data_dir 		= U2G('请选择客户端data目录')
	conf.client_as_dir 			= U2G('请选择客户端as目录')

	conf.table_prefix 			= 'tb_'
	conf.batch_num 				= 100

	--conf.server_lua_dir 		= U2G('此功能暂不开放,请生成旧版模板数据，由旧版模板工具生成服务端数据')
end

function Config:load(path)
	self:reset()
	
	conf.projectPath = path
	local relativePath  = conf.projectPath..'/'..fileName..'.lua'
	conf.confPath = conf.rootPath..'/'..relativePath
	-- 配置文件
	local f, err=io.open(conf.confPath, 'r+')
	if not f then
		self:save()
		return
	end
	f:close()
	for k,v in pairs(package.loaded) do
		if k == fileName then
            package.loaded[k] = nil
        else
        	local a, b = string.find(k, '.'..fileName)
        	if b == string.len(k) then
        		package.loaded[k] = nil
        	end
        end
    end
	local __ = string.gsub(relativePath, '.lua', '')         -- 去掉.lua
	__ = string.gsub(__, '\\', '/')
	__ = string.gsub(__, '/', '.')
	require(__)
end

-- 保存配置
function Config:save()
	local f,e  = io.open(conf.confPath, 'w')
	f:write('conf = conf or {}\n')
	f:write("conf.excel_dir = '"..conf.excel_dir.."'\n")
	f:write("conf.old_tool_data_dir = '"..conf.old_tool_data_dir.."'\n")

	f:write("conf.server_lua_dir = '"..conf.server_lua_dir.."'\n")

	f:write("conf.client_data_dir = '"..conf.client_data_dir.."'\n")
	f:write("conf.client_as_dir = '"..conf.client_as_dir.."'\n")

	f:write("conf.table_prefix = '"..conf.table_prefix.."'\n")
	f:write("conf.batch_num = "..conf.batch_num.."\n")
	f:close()
end

return Config