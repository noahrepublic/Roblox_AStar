--[[ Grid Class
    Written for pathfinding

    Author: @noahrepublic
--]]

-- Variables --

local Grid = {}
Grid.__index = Grid

local Node = {}
Node.__index = Node

-- Node Class --
do
	function Node.new(_walkable: boolean, _position: Vector3, _grid_X: number, _grid_Y: number, _grid: table)
		local new_node = setmetatable({}, Node)
		new_node.walkable = _walkable
		new_node.position = _position
		new_node.grid_X = _grid_X
		new_node.grid_Y = _grid_Y
		new_node.grid = _grid

		new_node.parent = nil

		new_node.g_cost = 0
		new_node.h_cost = 0
		new_node.f_cost = 0

		return new_node
	end

	function Node:F_Cost()
		return self.g_cost + self.h_cost
	end

	function Node:GetNeighbours()
		local neighbours = {}

		for x = -1, 1 do
			for y = -1, 1 do
				if x == 0 and y == 0 then
					continue
				end
				local new_x = self.grid_X + x
				local new_y = self.grid_Y + y
				if new_x >= 0 and new_x < self.grid._grid_size_x and new_y >= 0 and new_y < self.grid._grid_size_y then
					local new_node
					if self.grid.grid[x] and self.grid.grid[x][y] then
						new_node = self.grid.grid[x][y]
						if new_node.walkable then
							table.insert(neighbours, new_node)
						end
					end
					continue
				end
			end
		end
		print(neighbours)
		return neighbours
	end
end

-- Grid Class --

function Grid.new(_grid_size: Vector2, _node_size: IntValue)
	local new_grid = setmetatable({}, Grid)

	new_grid.grid = nil

	-- Config --
	new_grid._grid_size = _grid_size
	new_grid._node_size = _node_size
	new_grid._node_diameter = new_grid._node_size * 2
	new_grid._grid_size_x = math.round(new_grid._grid_size.X / new_grid._node_diameter)
	new_grid._grid_size_y = math.round(new_grid._grid_size.Y / new_grid._node_diameter)
	new_grid:Create()
	return new_grid
end

function Grid:Create()
	self.grid = table.create(self._grid_size_x)
	local bottom_left = Vector3.new(0, 0, 0)
		- Vector3.new(1, 0, 0) * self._grid_size.x / 2
		- Vector3.new(0, 0, 1) * self._grid_size.y / 2

	local ignored = { game.Workspace.Baseplate } -- add blacklist system in future
	local params = OverlapParams.new()
	params.FilterDescendantsInstances = ignored
	for x = 1, self._grid_size_x, 1 do
		self.grid[x] = table.create(self._grid_size_y)
		for y = 1, self._grid_size_y do
			local position = bottom_left
				+ Vector3.new(1, 0, 0) * (x * self._node_diameter + self._node_size)
				+ Vector3.new(0, 0, 1) * (y * self._node_diameter + self._node_size)
			local walkable = game.Workspace:GetPartBoundsInRadius(position, self._node_size, params)
			self.grid[x][y] = Node.new(walkable, position, x, y, self)
		end
	end
	return Grid
end

function Grid:GetNodeFromPosition(_positon: Vector3)
	local percent_x = (_positon.X / self._grid_size.x) + 0.5
	local percent_y = (_positon.Z / self._grid_size.y) + 0.5
	percent_x = math.clamp(percent_x, 0, 1)
	percent_y = math.clamp(percent_y, 0, 1)

	local x = math.floor(self._grid_size_x * percent_x)
	local y = math.floor(self._grid_size_y * percent_y)
	return self.grid[x][y]
end

function Grid:GetNodeDistance(a, b)
	local distance_x = math.abs(a.grid_X - b.grid_X)
	local distance_y = math.abs(a.grid_Y - b.grid_Y)
	if distance_x > distance_y then
		return 14 * distance_y + 10 * (distance_x - distance_y)
	end
	return 14 * distance_x + 10 * (distance_y - distance_x)
end

function Grid:Visualize()
	local grid_visualize = Instance.new("Part")
	grid_visualize.Size = Vector3.new(self._grid_size.X, 1, self._grid_size.Y)
	grid_visualize.Anchored = true
	grid_visualize.CanCollide = false
	grid_visualize.Color = Color3.new(0, 0, 0)
	grid_visualize.Transparency = 0.3
	grid_visualize.Parent = game.Workspace

	if self.grid then
		for x = 1, self._grid_size_x do
			for y = 1, #self.grid[x] do
				local node = Instance.new("Part")
				node.Position = self.grid[x][y].position
				node.Size = Vector3.one * (self._node_size - 0.1)
				node.Anchored = true
				if self.grid[x][y].walkable then
					node.Color = Color3.new(0, 1, 0)
				else
					node.Color = Color3.new(1, 0, 0)
				end
				node.Parent = game.Workspace
			end
		end
	end
end

return Grid
