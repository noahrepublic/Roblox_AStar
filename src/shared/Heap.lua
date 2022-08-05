local Heap = {}
Heap.__index = Heap

-- Functions --
--Private:

local function CompareTo(item1, item2)
	local f_Cost1 = item1.Distance + item1.G_Cost
	local f_Cost2 = item2.Distance + item2.G_Cost
	return f_Cost1 - f_Cost2
end
--Public:
function Heap.new()
	return setmetatable({
		items = {},
		item_count = 1,
	}, Heap)
end

function Heap:Add(item)
	item.HeapIndex = self.item_count
	self.items[self.item_count] = item
	self:SortUp(item)
	self.item_count = self.item_count + 1
end

function Heap:RemoveFirst()
	local first = self.items[1]
	self.item_count = self.item_count - 1
	self.items[1] = self.items[self.item_count]
	self.items[1].HeapIndex = 1
	self:SortDown(self.items[1])
	return first
end

function Heap:UpdateItem(item)
	self:SortUp(item)
end

function Heap:Count()
	return self.item_count
end

function Heap:Contains(item)
	return self.items[item.HeapIndex] == item
end

function Heap:SortUp(item: table)
	local parent = math.floor((item.HeapIndex - 1) / 2) + 1
	if parent == 0 then
		parent = 1
	end
	while true do
		local parent_item = self.items[parent]
		if CompareTo(item, parent_item) < 0 then
			self:Swap(item, parent_item)
		else
			break
		end
		parent = math.floor((item.HeapIndex - 1) / 2) + 1
	end
end

function Heap:SortDown(item)
	while true do
		local child_left = item.HeapIndex * 2 + 1
		local child_right = item.HeapIndex * 2 + 2
		local swap = 0
		if child_left < self.item_count then
			swap = child_left
			if child_right < self.item_count and CompareTo(self.items[child_left], self.items[child_right]) < 0 then
				swap = child_right
			end
			if CompareTo(item, self.items[swap]) < 0 then
				self:Swap(item, self.items[swap])
			else
				break
			end
		else
			break
		end
		task.wait()
	end
end

function Heap:Swap(item1, item2)
	self.items[item1.HeapIndex] = item2
	self.items[item2.HeapIndex] = item1
	local itemA_Index = item1.HeapIndex
	item1.HeapIndex = item2.HeapIndex
	item2.HeapIndex = itemA_Index
end

return Heap
