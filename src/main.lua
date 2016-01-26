package.cpath = package.cpath..';./src/?.lua;./bin/?.dll'

require 'luacom'
require 'winapi'
require 'luaiconv'

local Excel = require 'Excel'

function main( )
	local doc = Excel.new()
	doc:open('t.xlsx')
	doc:close()
end
