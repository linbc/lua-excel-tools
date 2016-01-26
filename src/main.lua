package.cpath = package.cpath..';./src/?.lua;./bin/?.dll'

require 'util'

local Excel = require 'Excel'

function main( )
	local doc = Excel.new()
	--必须采用全路径,否则会有问题
	doc:open(U2G('D:/git/excel-helper/src/测试文件.xls'))
	local sheet = doc:getSheet('Sheet1')
	assert(sheet)
	local data = sheet:getRange('A1',8, 2)
	table.foreach(data[1],function(k,v)
		print(v)
	end)
	doc:close()
end

main()