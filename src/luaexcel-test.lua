

require 'luacom'
require 'winapi'
require 'luaiconv'

-------------------------------------------------------------
-- 编码转换
local function createIconv(to, from)  
	local cd = iconv.new(to, from)  
	return function(txt)  
	   return cd:iconv(txt)  
	end  
end  

G2U = createIconv('utf-8', 'gbk')  
U2G = createIconv('gbk', 'utf-8')  

-- 清理execl进程
function clearExecl()
    local pids = luacom.FindProcess('EXCEL.EXE')
    for _,pid in pairs(pids) do
        local P = winapi.process_from_id(pid)
        P:kill()
    end
end