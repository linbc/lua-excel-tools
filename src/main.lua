package.cpath = package.cpath..';../bin/?.dll'

require 'util'

local Excel = require 'Excel'

function test_write( sheet )
	--测试一下写入数据
	print('trace: begin!')
	local testData,MAX_ROW,MAX_COLUMN = {}, 10000, 10
	for i=1,MAX_ROW do
		local r = {}
		for j=1,MAX_COLUMN do			
			r[j] = i*j
		end	
		testData[i] = r
	end
	print('trace: data ready!')
	sheet:setRange('A1',testData, MAX_ROW, MAX_COLUMN)
	print('trace: data inserted!')
end

function main( )
	local doc = Excel.new()
	--必须采用全路径,否则会有问题
	doc:open(U2G('D:/git/excel-helper/t.xlsx'))
	local sheet = doc:getSheet('Sheet1')
	assert(sheet)
--	test_write(sheet)
--	doc:save()

	--测试一下读取数据后打印输出
	local data = sheet:getRange('A1',10, 1000)
	for i=1,1000 do
		local row = data[i]
		print('row:	',i, row and row[1] or nil,row and row[2] or nil)
		--row[3] = string.char(string.byte('a')+i)		
	end
	
	
	doc:close()
	print('over!')
end

main()
