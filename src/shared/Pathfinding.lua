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

-- Node Functions --

function Nodes.new(location)
	return setmetatable({
		Location = location,
		G_Cost = 0,
		Distance = 0,
		Parent = nil,
	}, Nodes)
end

function Nodes:GetNeighbours(blacklist)
	local neighbours = {}
	for direction, offset in pairs(offsets) do
		local neighbour = self.Location + offset
		if not blacklist[neighbour] then
			neighbours[direction] = Pathfinding.Node(neighbour)
		end
	end
	return neighbours
end

function Pathfinding.Node(location, start, end_location, Parent)
	local node = Nodes.new(location)
	if start then
		node.G_Cost = (location - start).magnitude
		node.Distance = (end_location - location).magnitude
		node.Parent = Parent
	end
	return node
end

function Pathfinding.GeneratePath(start: Vector3, end_pos: Vector3, blacklist: table)
	local path = {} -- The final path
	local open_set = {} -- The set of nodes to be evaluated
	local closed_set = {} -- The set of nodes already evaluated

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
	table.insert(open_set, Pathfinding.Node(start, nil, end_pos, nil))
	table.insert(path, start)

	while #open_set > 0 do
		local starting_node = open_set[1]
		local current = starting_node
		local ignore_set = closed_set
		for i = 1, #open_set do
			table.insert(ignore_set, open_set[i].Location)
		end
		for _, neighbour in pairs(current:GetNeighbours(ignore_set)) do
			table.insert(open_set, neighbour)
		end
		for i = 2, #open_set, 1 do -- Get lowest cost node
			if
				open_set[i].Distance + open_set[i].G_Cost < current.Distance + current.G_Cost
				or current.Distance == 0
			then
				current = open_set[i]
			end
		end

		table.remove(open_set, 1)
		table.insert(closed_set, current.Location)

		current.Parent = starting_node
		if current.Location == end_pos then
			local node = current
			while node.Parent do
				table.insert(path, node.Location)
				node = node.Parent
			end
			table.insert(path, node.Location)
			return path
		end
		task.wait()
	end
	return path
end

return Pathfinding
