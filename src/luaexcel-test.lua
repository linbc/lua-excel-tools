

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

-------------------------------------------------------------
-- class Sheet
local Sheet = {}

function Sheet.new(ptr)
	local o = {ptr = ptr}
	setmetatable(o, Sheet)
	Sheet.__index = Sheet
	return o
end

function Sheet:getRange(startRange, width_or_endRange, height)
end

-------------------------------------------------------------
-- class Excel
local Excel = {}

function Excel.new()
	local o = {}
	setmetatable(o, Excel)
	Excel.__index = Excel
	return o
end

function Excel:open(path)
	assert(self:isExist(path))
	
	local excel = luacom.GetObject('Excel.Application') or luacom.CreateObject('Excel.Application')
	assert(excel)
	self.excel = excel
	
	excel.Application.DisplayAlerts = false
	local book = excel.WorkBooks:Open(G2U(path),nil,ReadOnly)
	book.Saved = false
	self.book = book
	
end

function Excel:close()
	if self.book then
		self.book:Close()
	end
	if self.excel then
		self.excel.Application:Quit()
	end
end

function Excel:getSheet(name)
	local e = luacom.GetEnumerator(self.excel.Sheets)
	local sheet = e:Next()
	while sheet do
		if sheet.Name == name then
			return sheet
		end
		sheet = e:Next()
	end
	return nil
end

function Excel:isExist(path)
	local t=io.open(path, 'r')
	if not t then
		return false
	else
	 	t:close()
		return true
	end
end

function Excel:close()
end
