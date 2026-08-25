-- @ScriptType: ModuleScript
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new()
	return setmetatable({ _items = {} }, Janitor)
end

function Janitor:Add(item)
	table.insert(self._items, item)
	return item
end

function Janitor:Destroy()
	for _, item in ipairs(self._items) do
		if typeof(item) == "RBXScriptConnection" then
			item:Disconnect()
		elseif typeof(item) == "Instance" then
			if item:IsA("AnimationTrack") then
				item:Stop()
			else
				item:Destroy()
			end
		elseif typeof(item) == "function" then
			item()
		end
	end
	table.clear(self._items)
end

return Janitor
