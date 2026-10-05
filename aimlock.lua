local P = game:GetService("Players")
local RS = game:GetService("RunService")

local plr = P.LocalPlayer
local cam = workspace.CurrentCamera

local OffsetU = 0
local OffsetD = 0
local aimOn = false
local aimTarget = nil

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

RS:BindToRenderStep("AimSystem", Enum.RenderPriority.Camera.Value + 1, function()
	cam = workspace.CurrentCamera
	if not aimOn then return end
	local torso = getTorso(aimTarget)
	if not torso then
		aimOn = false
		aimTarget = nil
		return
	end
	local focus = cam.Focus.Position
	local dist = (cam.CFrame.Position - focus).Magnitude
	local dir = torso.Position - focus
	if dir.Magnitude > 0.1 then
		local camPos = focus - dir.Unit * dist
			+ Vector3.new(0, OffsetU, 0)
			+ cam.CFrame.RightVector * OffsetD
		cam.CFrame = CFrame.lookAt(camPos, torso.Position)
	end
end)

P.PlayerRemoving:Connect(function(p)
	if p == aimTarget then
		aimOn = false
		aimTarget = nil
	end
end)

plr.CharacterAdded:Connect(function()
	aimOn = false
	aimTarget = nil
end)

return {
	toggle = function()
		aimOn = not aimOn
		aimTarget = aimOn and getNearestPlayer() or nil
	end,
	isOn = function() return aimOn end
}
