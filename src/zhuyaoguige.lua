package.cpath = package.cpath..';../bin/?.dll'

require 'util'

local lfs = require 'lfs'
local Excel = require 'Excel'

--在数组中找到值
function findRowByID(idData, value)
	for i=1,#idData do
		if idData[i] == value then
			return i
		end
	end
end

function main( )
	local doc = Excel.new()
	--必须采用全路径,否则会有问题
	print()
	local path = U2G(lfs.currentdir()..'\\主要规格（2016.1.23）.xlsx')
	print('open file:'..path)
	doc:open(path)
	
	--测试一下读取数据后打印输出
	local fromSheet = doc:getSheet('试验')
	--图纸编号
	local idData = fromSheet:getColumn('I3')
	
	local function column2sheet(column, sheetName, dstColumn)
		local srcData = fromSheet:getColumn(column)
		
		--所有的表格图形编号都是在第一行的第三列
		local dstSheet = doc:createSheet(sheetName)
		local a = dstSheet:getColumn('A3')
		local values = {}
		for i=1,#a do
			--idData和fromData 的行号是相同维度的
			local row = findRowByID(idData, a[i])
			--print(sheetName, a[i], idData[row], srcData[row])
			table.insert(values, srcData[row] and srcData[row] or '')
		end
		dstSheet:setColumn(dstColumn..3,values)
		print(U2G(sheetName)..' is ok!')
	end
	
	--厦门	湖北	山东	安徽	四川
	--AI 	AJ		AK		AL		AM
	--X		N		M		W		O
	column2sheet('AI3', '厦门', 'X')
	column2sheet('AJ3', '湖北', 'N')
	column2sheet('AK3', '山东', 'M')
	column2sheet('AL3', '安徽', 'W')
	column2sheet('AM3', '四川', 'O')
	
	doc:save()
	doc:close()
	print('over!')
end

main()
