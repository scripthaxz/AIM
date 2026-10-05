local P = game:GetService("Players")
local RS = game:GetService("RunService")

local plr = P.LocalPlayer

local charOn = false
local charTarget = nil
local oldAutoRotate = nil

local function getTorso(p)
	local char = p and p.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local torso = char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
	if not hum or hum.Health <= 0 or not torso then return nil end
	return torso
end

local function getNearestPlayer()
	local char = plr.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local nearest, distance = nil, math.huge
	for _, p in ipairs(P:GetPlayers()) do
		if p ~= plr then
			local torso = getTorso(p)
			if torso then
				local d = (root.Position - torso.Position).Magnitude
				if d < distance then distance = d nearest = p end
			end
		end
	end
	return nearest
end

RS:BindToRenderStep("CharSystem", Enum.RenderPriority.Camera.Value + 1, function()
	if not charOn then return end
	local char = plr.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local torso = getTorso(charTarget)
	if not root or not torso then
		charOn = false
		charTarget = nil
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and oldAutoRotate ~= nil then
			hum.AutoRotate = oldAutoRotate
		end
		oldAutoRotate = nil
		return
	end
	local targetPos = Vector3.new(torso.Position.X, root.Position.Y, torso.Position.Z)
	if (targetPos - root.Position).Magnitude > 0.01 then
		root.CFrame = CFrame.lookAt(root.Position, targetPos)
	end
end)

P.PlayerRemoving:Connect(function(p)
	if p == charTarget then
		charOn = false
		charTarget = nil
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum and oldAutoRotate ~= nil then
			hum.AutoRotate = oldAutoRotate
		end
		oldAutoRotate = nil
	end
end)

plr.CharacterAdded:Connect(function()
	charOn = false
	charTarget = nil
	oldAutoRotate = nil
end)

return {
	toggle = function()
		charOn = not charOn
		local char = plr.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if charOn then
			charTarget = getNearestPlayer()
			if hum then
				oldAutoRotate = hum.AutoRotate
				hum.AutoRotate = false
			end
		else
			charTarget = nil
			if hum and oldAutoRotate ~= nil then
				hum.AutoRotate = oldAutoRotate
			end
			oldAutoRotate = nil
		end
	end,
	isOn = function() return charOn end
}
