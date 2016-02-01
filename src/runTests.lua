package.cpath = package.cpath..';../bin/?.dll'

require 'util'

local Excel = require 'Excel'
local lfs = require 'lfs'

function test_write( doc )
	--测试一下写入数据
	print('trace: begin!')
	local sheet = doc:getSheet('Sheet1')
	local testData,MAX_ROW,MAX_COLUMN = {}, 10000, 10
	for i=1,MAX_ROW do
		local r = {}
		for j=1,MAX_COLUMN do	
			if j%2 == 0 then
				r[j] = i*j
			else
				r[j] = os.time()
			end
		end	
		testData[i] = r
	end
	print('trace: data ready!')
	sheet:setRange('A1',testData, MAX_ROW, MAX_COLUMN)
	print('trace: data inserted!')
	doc:save()
end

function testSetColumn(doc)
	local sheet = doc:createSheet('testSetColumn')
	local data = {}
	data[1] = 'A'
	data[2] = 'B'
	data[3] = 'C'
	sheet:setColumn('A1',data)
	doc:save()
end

function testGetData(doc)
	local sheet = doc:getSheet('Sheet1')
	--测试一下读取数据后打印输出
	local data = sheet:getRange('A1',10, 1000)
	for i=1,1000 do
		local row = data[i]
		print('row:	',i, row and row[1] or nil,row and row[2] or nil)
	end
end

function main( )
	local doc = Excel.new()
	--必须采用全路径,否则会有问题
	doc:open(U2G(lfs.currentdir()..'/../t.xlsx'))
	assert(doc)
	test_write(doc)
	testSetColumn(doc)
	
	doc:close()
	print('over!')
end

main()
