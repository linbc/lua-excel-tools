-------------------------------------------------------------
-- function

--数组倒序排列
local function orderByDesc( input )
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
local function _Dec2X( dec, x )
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
local function _numberTable2X(  number_tbl,x )
	local result = 0
	for i,v in ipairs(number_tbl) do
		print(result,x, i, v)
		result = result + v*math.pow(x, i - 1)
	end
	return result
end

local function test_Dec2X ()
	local kTestNumber = 9527
	local n1 = _Dec2X(kTestNumber, 10)
	-- table.foreach(n1, function ( _,v )
	-- 	print(v)
	-- end)
	assert(kTestNumber == _numberTable2X(n1, 10))
end
test_Dec2X()

-------------------------------------------------------------
-- class Sheet
local Sheet = {}


function Sheet.new(ptr)
	local o = {ptr = ptr}
	setmetatable(o, Sheet)
	Sheet.__index = Sheet
	return o
end

function Sheet:getRange(startRange, width, height)
end

return Sheet
