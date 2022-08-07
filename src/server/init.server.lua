local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Pathfinding = require(ReplicatedStorage.Common.Pathfinding)
local path
task.spawn(function()
	path = Pathfinding.GeneratePath(Vector3.new(0, 0, 0), Vector3.new(5, 0, 0), {})
end)
repeat
	task.wait()
until path ~= nil

print("COMPLETE")
print(path)

for i = 1, #path do
	local part = Instance.new("Part")
	part.Size = Vector3.new(1, 1, 1)
	part.Position = path[i]
	part.Anchored = true
	part.CanCollide = false
	part.Color = Color3.new(1, 0, 0)
	part.Parent = game.Workspace
end
