local Pathfinding = {}
Pathfinding.__index = Pathfinding

local Node = {}
Node.__index = Node

-- Variables --

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

local Grids = require(game.ReplicatedStorage.Common.Grid)
local Heaps = require(script.Parent.Heap)

-- Functions --

function Pathfinding.CalculateCosts(_node, _start: Vector3, _end: Vector3)
	_node.g_cost = (_node.position - _start).magnitude
	_node.h_cost = (_end - _node.position).magnitude
	_node.f_cost = _node.g_cost + _node.h_cost
	return _node.f_cost -- do I return?
end

function Pathfinding.GeneratePath(_start: Vector3, _end: Vector3, blacklist: table)
	local d = (_end - _start).Magnitude
	local Grid = Grids.new(Vector2.new(d, d), 1)

	local path = {}
	local start_node = Grid:GetNodeFromPosition(_start)
	local end_node = Grid:GetNodeFromPosition(_end)

	local open_set = Heaps.new(function(a, b)
		return b.f_cost - a.f_cost
	end)
	local closed_set = {}
	open_set:Insert(start_node)

	while #open_set > 0 do
		print("yo")
		local current_node = open_set:Pop()
		table.insert(closed_set, current_node)
		if current_node == end_node then
			table.insert(path, current_node.position)
			while current_node.parent do
				table.insert(path, current_node.parent.position)
				current_node = current_node.parent
			end
		end

		for _, node in pairs(current_node:GetNeighbours()) do
			if not node.walkable or table.find(closed_set, node) then
				continue
			end

			local new_move_cost = current_node.g_cost + Grid:GetNodeDistance(current_node, node)

			local contains = table.find(open_set, node)
			if (new_move_cost < current_node.g_cost) or not contains then
				node.g_cost = new_move_cost
				node.h_cost = Grid:GetNodeDistance(node, end_node)
				node.f_cost = node.g_cost + node.h_cost
				node.parent = current_node

				if not contains then
					print("adding..")
					open_set:Insert(node)
				end
			end
		end
	end
end

return Pathfinding
