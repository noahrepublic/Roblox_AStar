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

--[[local offsets = {
	["Right"] = Vector3.new(-1, 0, 0),
	["Left"] = Vector3.new(1, 0, 0),
	["Up"] = Vector3.new(0, 0, 1),
	["Down"] = Vector3.new(0, 0, -1),
}]]

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
	}, Nodes)
end

function Nodes:CompareTo(nodeTo_Compare)
	local compare = self.Distance + self.G_Cost - nodeTo_Compare.Distance - nodeTo_Compare.G_Cost
	if compare == 0 then
		compare = self.Distance - nodeTo_Compare.Distance
	end
	return -compare
end

function Nodes:GetNeighbours(blacklist)
	local neighbours = {}
	for direction, offset in pairs(offsets) do
		local neighbour = self.Location + offset
		if not blacklist[neighbour] then
			neighbours[direction] = Pathfinding.Node(neighbour) -- I NEED THE START STUFF HERE
		end
	end
	return neighbours
end

function Pathfinding.Node(location, start, end_location, Parent)
	local node = Nodes.new(location)
	if start then
		node.G_Cost = (start - location).magnitude
		node.Distance = (end_location - location).magnitude
		print(node.G_Cost, node.Distance)
		if Parent then
			node.Parent = Parent
		end
	end
	return node
end

function Pathfinding.GeneratePath(start: Vector3, end_pos: Vector3, blacklist: table)
	local path = {} -- The final path
	local open_set = {} -- The set of nodes to be evaluated
	local closed_set = {} -- The set of nodes already evaluated

	local start = os.clock()
	for i = 1, #blacklist do
		if typeof(blacklist[i]) == "Vector3" then
			blacklist[blacklist[i]] = true
		else
			blacklist[blacklist[i].Location] = true
		end
		if blacklist[i] == start then
			return {}
		end
		table.insert(closed_set, blacklist[i])
	end
	-- Add the start node to the open set
	table.insert(open_set, Pathfinding.Node(start, start, end_pos, nil))
	table.insert(path, start)

	while #open_set > 0 do
		local current, index = open_set[1], nil
		-- Calculate lowest F_Cost
		for i = 2, #open_set do
			if
				open_set[i].G_Cost + open_set[i].Distance < current.G_Cost + current.Distance
				or open_set[i].G_Cost + open_set[i].Distance == current.G_Cost + current.Distance
					and open_set[i].Distance < current.Distance
			then
				current = open_set[i], i
			end
		end
		-- Remove current from open set
		table.remove(open_set, index)
		-- Add current to closed set
		table.insert(closed_set, current)
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
			print("Path found in " .. (os.clock() - start) .. " seconds")
			-- Return path
			return path
		end
		-- Get current's neighbours
		local neighbours = current:GetNeighbours(closed_set)

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
				if not table.find(open_set, neighbour) then
					table.insert(open_set, neighbour)
				end
			end
		end
		task.wait()
	end
	return path
end

return Pathfinding
