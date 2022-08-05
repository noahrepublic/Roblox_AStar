local Pathfinding = {}
Pathfinding.__index = Pathfinding

local Nodes = {}
Nodes.__index = Nodes

local offsets = {
	["Right"] = Vector3.new(-1, 0, 0),
	["Left"] = Vector3.new(1, 0, 0),
	["Up"] = Vector3.new(0, 0, 1),
	["Down"] = Vector3.new(0, 0, -1),
	["Right Up"] = Vector3.new(-1, 0, 1),
	["Right Down"] = Vector3.new(-1, 0, -1),
	["Left Up"] = Vector3.new(1, 0, 1),
	["Left Down"] = Vector3.new(1, 0, -1),
}

local weights = {
	["Right"] = 1,
	["Left"] = 1,
	["Up"] = 1,
	["Down"] = 1,
	["Right Up"] = 2,
	["Right Down"] = 2,
	["Left Up"] = 2,
	["Left Down"] = 2,
}

local Heaps = require(script.Parent.Heap)

local function visualize(location)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.Size = Vector3.new(1, 1, 1)
	part.Position = location
	part.BrickColor = BrickColor.new("Bright red")
	part.Transparency = 0.5
	part.Parent = game.Workspace
end

-- Node Functions --

function Nodes.new(location)
	return setmetatable({
		Location = location,
		G_Cost = 0,
		Distance = 0,
		Parent = nil,
		HeapIndex = nil,

		_start = nil,
		_end = nil,
	}, Nodes)
end

function Nodes:GetNeighbours(blacklist, blacklist2)
	local neighbours = {}
	for direction, offset in pairs(offsets) do
		local neighbour = self.Location + offset
		if not blacklist[neighbour] and not blacklist2[neighbour] then
			neighbours[direction] = Pathfinding.Node(neighbour, self._start, self._end, direction)
		end
	end
	return neighbours
end

function Pathfinding.Node(location, start, end_location, direction)
	local node = Nodes.new(location)
	if start then
		node.G_Cost = (start - location).magnitude
		node.Distance = (end_location - location).magnitude
		node._start = start
		node._end = end_location
		if direction then
			node.G_Cost = node.G_Cost * weights[direction]
			node.Distance = node.Distance * weights[direction]
		end
	end
	return node
end

function Pathfinding.GeneratePath(start: Vector3, end_pos: Vector3, blacklist)
	local path = {} -- The final path
	local open_set = Heaps.new() -- The set of nodes to be evaluated
	local closed_set = {} -- The set of nodes already evaluated

	local start_time = os.clock()
	for i = 1, #blacklist do
		if typeof(blacklist[i]) == "Vector3" then
			blacklist[blacklist[i]] = true
		else
			blacklist[blacklist[i].Position] = true
		end
		if blacklist[i] == start then
			return {}
		end
	end
	-- Add the start node to the open set
	open_set:Add(Pathfinding.Node(start, start, end_pos, nil))
	table.insert(path, start)

	visualize(start)

	while open_set.item_count > 0 do
		local current = open_set:RemoveFirst()
		-- Add current to closed set
		table.insert(closed_set, current.Location)
		visualize(current.Location)

		-- Check if current is the end node
		if current.Location == end_pos then
			-- Add current to path
			table.insert(path, current.Location)
			-- Add current's parent to path
			while current.Parent do
				table.insert(path, current.Parent.Location)
				current = current.Parent
				task.wait()
			end
			print("Path found in " .. (os.clock() - start_time) .. " seconds")
			-- Return path
			return path
		end
		-- Get current's neighbours
		local neighbours = current:GetNeighbours(closed_set, blacklist)

		-- For each neighbour
		for _, neighbour in neighbours do
			visualize(neighbour.Location)
			local new_cost = current.G_Cost + (neighbour.Location - current.Location).magnitude
			if new_cost < neighbour.G_Cost or not table.find(open_set, neighbour) then
				-- Update neighbour's parent
				neighbour.Parent = current
				-- Update neighbour's G_Cost
				neighbour.G_Cost = new_cost
				-- Update neighbour's Distance
				neighbour.Distance = (end_pos - neighbour.Location).magnitude
				-- Add neighbour to open set
				if not open_set:Contains(neighbour) then
					open_set:Add(neighbour)
				end
			end
		end
		task.wait()
	end
	return path
end

return Pathfinding
