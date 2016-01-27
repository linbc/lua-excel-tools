package.cpath = package.cpath..';../bin/?.dll'

require 'util'

local Excel = require 'Excel'

function main( )
	local doc = Excel.new()
	--必须采用全路径,否则会有问题
	doc:open(U2G('D:/git/excel-helper/t.xlsx'))
	local sheet = doc:getSheet('Sheet1')
	assert(sheet)
	local data = sheet:getRange()
	local maxRow = sheet:getUseRange()
	for i=1,maxRow do
		local row = data[i]
		print('row:	',i, row and row[1] or nil,row and row[2] or nil)
		--row[3] = string.char(string.byte('a')+i)		
	end
	
	doc:save()
	doc:close()
	print('over!')
end

main()
