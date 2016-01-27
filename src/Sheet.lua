-------------------------------------------------------------
-- function

--数组倒序排列
function table.orderByDesc( input )
	local output = {}
	local count = #input
	while count > 0 do
		table.insert(output, input[count] )
		count = count -1 
	end
	return output
end

--进制转换，英文不行只好用拼音
--@dec 10进制数据，好吧，只要是数字就呆以了
--@x 进制，最常见的当然是二、八、十六、进制
function math.dec2X( dec, x )
	--计算结果存储在这里
	local new_number = {}

	--算法如下：
		--9527 = 9*(10^3)+5*(10^2)+2*(10^1)+7*(10^0)
		--7 = 9527%10, 2 = (9527-7)%100/100
		--f(n) = (dec % (x^i) - f(n-1))/x
		--f(0) = 0
	--a参数代表第几位，返回是否继续
	local function f( a )
		assert(a >= 1)
		local mod = dec % math.pow(x, a)
		local last_mod = (a == 1) and 0 or assert(new_number[a-1])
		new_number[a] = (mod - last_mod)/math.pow(x, a - 1)
		--取整数部分
		new_number[a] = math.modf(new_number[a])
		return mod ~= dec
	end
	--该函数取得某位值
	local i = 1
	while f(i) do
		i = i + 1
	end
	
	return new_number
end

--将某个数据转成X进制
--以 9527，10进制为例，{7, 2, 5, 9}
function math.numberTable2X(  number_tbl,x )
	local result = 0
	for i,v in ipairs(number_tbl) do
		result = result + v*math.pow(x, i - 1)
	end
	return result
end

-- local function test_Dec2X ()
-- 	local kTestNumber = 9527
-- 	local n1 = math.dec2X(kTestNumber, 10)
-- 	-- table.foreach(n1, function ( _,v )
-- 	-- 	print(v)
-- 	-- end)
-- 	assert(kTestNumber == math.numberTable2X(n1, 10))
-- end
-- test_Dec2X()

-------------------------------------------------------------
-- class Sheet
local Sheet = {}


function Sheet.new(ptr)
	local o = {sheet = ptr}
	setmetatable(o, Sheet)
	Sheet.__index = Sheet
	return o
end

--AA相当于10进制27
function Sheet:getColumnNumber( s )
	local number_tbl = {}
	for k,_ in string.gmatch(s, '%u') do 
		local n = string.byte(k) - string.byte('A') + 1
		assert(n <= 26 and n > 0)
		table.insert(number_tbl, n) 
	end
	number_tbl = table.orderByDesc(number_tbl)
	return math.numberTable2X(number_tbl, 26)
end

function Sheet:getColumnString( num )
	--由于这个26进制比较奇怪,如果以时间举例就是0点不叫0点而叫24点
	--所以在计算进制前先-1，好了以后个位补1
	local number_tbl = math.dec2X(num - 1, 26)
	number_tbl[1] = number_tbl[1] + 1

	for i,v in ipairs(number_tbl) do		
		number_tbl[i] = string.char(string.byte('A') + v -1 )
	end
	--倒序一下
	number_tbl = table.orderByDesc(number_tbl)
	--字符串拼接一下
	local s = ''
	for _,v in ipairs(number_tbl) do
		s = s .. v
	end
	return s
end

--测试
assert(Sheet.getColumnNumber(nil, 'A') == 1)
assert(Sheet.getColumnNumber(nil, 'Z') == 26)
assert(Sheet.getColumnNumber(nil, 'AA') == 27)
assert(Sheet.getColumnNumber(nil, 'IV') == 256)
assert(Sheet.getColumnString(nil, 1) == 'A')
assert(Sheet.getColumnString(nil, 27) == 'AA')
assert(Sheet.getColumnString(nil, 256) == 'IV')
assert(Sheet.getColumnString(nil, 26) == 'Z')

function Sheet:getRangeString( startRange, width, height )
	assert(type(startRange) == 'string')
	--获得起点行号，及起点的列编号
	local startRow = string.gsub(startRange, '%u+', '')
	local startColumn = string.gsub(startRange, '%d+', '')
	--列编号相当于26进制的数字，我们把他转成10进制整数便于运算
	startRow = tonumber(startRow)
	startColumn = self:getColumnNumber(startColumn)
	local endRow, endColumn = assert(startRow) + height, startColumn + width
	--转成字母形式
	endColumn = self:getColumnString(endColumn)

	return startRange..':'..endColumn..endRow
end

--@startRange 起点格子编号：如AB189, AB列-189行
--@width 宽度几格
--@height 高度
function Sheet:getRange(startRange, width, height)
	--如果没有输入这个参数,默认使用最大
	startRange = startRange or 'A1'
	width = width or self.sheet.Usedrange.columns.count
	height = height or self.sheet.Usedrange.Rows.count
	
	local range = self.sheet:Range(self:getRangeString(startRange, width, height))
	return range.Value2
end

function Sheet:getUseRange()
	return self.sheet.Usedrange.Rows.count,
		self.sheet.Usedrange.columns.count
end

return Sheet
