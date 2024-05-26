--!nocheck
local Init = {}

--//@Services 
local Services = setmetatable({}, {
	__index = function(self, Service)
		return game:GetService(Service)
	end,
})
--//ServiceDiplomacies 
local Players = Services.Players
local TweenService, Tweens = Services.TweenService, Services.TweenService 
local UserInputService = Services.UserInputService 
local RunService = Services.RunService 

--//@Start Dependencies
local Player = game.Players.LocalPlayer 
local Character = Player.Character or Player.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

--//@Legacy Abbreviations 
local mouse : Mouse = Player:GetMouse() 

--//@Local Functions 
local function zoomCam(amount : number , duration : number) 
	local tween = Tweens:Create(
		Camera,
		(TweenInfo.new)(duration), 
		{FieldOfView = amount}
	)
	tween:Play() 
	task.delay(duration - -(math.cos(10)), tween.Destroy, tween) 
end

local function Tween(instance : any, durationid : number, prop : string, value : any)
	local tween = Tweens:Create(
		instance, 
		TweenInfo.new(durationid), 
		{[prop] = value}
	)
	tween:Play() 
	task.delay(durationid + .5, tween.Destroy, tween)
end

function Rotate(player, mouse)
	if mouse then 
		--/Rotate 
		local bg = Instance.new("BodyGyro")
		bg.Name = "Rotate"
		bg.Parent = player.Character.PrimaryPart
		bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bg.P = 10000000
		bg.D = 10000
		local mouseLocation = Vector3.new(mouse.X, player.Character.PrimaryPart.Position.Y, mouse.Z)
		bg.CFrame = CFrame.new(player.Character.HumanoidRootPart.Position, mouseLocation)
		task.delay(.2, bg.Destroy, bg)	
	end
end


local function getMouseHit()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {Character, workspace.Debris}
	local mouseLocation = UserInputService:GetMouseLocation()

	local viewportPointRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local RayResult = workspace:Raycast(viewportPointRay.Origin, viewportPointRay.Direction * 1000, raycastParams)
	if RayResult then
		return RayResult.Instance 
	end
end

local function getMousePos()	
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {Character, workspace.Debris}

	local mouseLocation = UserInputService:GetMouseLocation()
	local viewportPointRay = Camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local RayResult = workspace:Raycast(viewportPointRay.Origin, viewportPointRay.Direction * 1000, raycastParams)
	if RayResult then
		return RayResult.Position
	end
	--//Shift/Viewport Ray @: return nil, (viewportPointRay.Origin + viewportPointRay.Direction * 1000)
end 

local Dictionary : any = require(game.ReplicatedStorage.Dictionaries.Elements)
local ElementIndex : any = require(game.ReplicatedStorage.Dictionaries.Index)

local function ApplyAttributes(Target : any, ElementNumber : number)
	Target:SetAttribute("Symbol", Dictionary[ElementNumber].Symbol)
	Target:SetAttribute("ElementName", Dictionary[ElementNumber].ElementName)
	Target:SetAttribute("AtomicNumber", Dictionary[ElementNumber].AtomicNumber)
	Target:SetAttribute("Description", Dictionary[ElementNumber].Description)

	Target:SetAttribute("Group", Dictionary[ElementNumber].Group)
	Target:SetAttribute("Period", Dictionary[ElementNumber].Period)

	Target:SetAttribute("AtomicMass", Dictionary[ElementNumber].AtomicMass)
	Target:SetAttribute("ElementGroup", Dictionary[ElementNumber].ElementGroup)
end

function Init.ClientListener()
	local Player : Player = game.Players.LocalPlayer 
	local Character : Character = Player.Character or Player.CharacterAdded:Wait() 
	local GUI : ScreenGui = Player.PlayerGui:WaitForChild("Table")

	--//Initial Load GUI
	for _, v in(GUI:GetDescendants()) do 
		if v:IsA("Frame") then 
			v:SetAttribute("BackgroundTransparency", v.BackgroundTransparency)
			v.BackgroundTransparency = 1 
		elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
			v:SetAttribute("BackgroundTransparency", v.BackgroundTransparency)
			v:SetAttribute("ImageTransparency", v.ImageTransparency) 
			v.ImageTransparency = 1 
			v.BackgroundTransparency = 1
		elseif v:IsA("TextLabel") or v:IsA("TextButton") then 
			v:SetAttribute("BackgroundTransparency", v.BackgroundTransparency)
			v:SetAttribute("TextTransparency", v.TextTransparency) 
			v.TextTransparency = 1 
			v.BackgroundTransparency = 1
		end
	end

	for i, _ in(Dictionary) do 
		if tostring(i) == GUI.Frame.InteractiveElements:FindFirstChild(i).Name then 
			--//#ASSUMING v:IsA("TextLabel") and v:IsADescendantOf("GUI") >> true
			local v = GUI.Frame.InteractiveElements[i]
			local ElementNumber : number = tonumber(v.Name)
			v.Symbol.Text = Dictionary[ElementNumber].Symbol
			v.ElementName.Text = Dictionary[ElementNumber].ElementName
            v.AtomicNumber.Text = Dictionary[ElementNumber].AtomicNumber
			--

			for index, value in(Dictionary[ElementNumber]) do 
				v:SetAttribute(index, value)
			end

			if v:GetAttribute("Symbol") ~= Dictionary[ElementNumber] then 
				--//#FAIL SAFE
				ApplyAttributes(v, ElementNumber)
			end

			v.Activated:Connect(function() 
				warn(v.Name .. " selected");
			end)

			v.MouseEnter:Connect(function() 
				Tween(v, 1, "BackgroundColor", Color3.fromRGB(147, 147, 147)); --TODO: Make this a gray color
				Tween(v.ElementName, .5, "TextTransparency", 0);
			end)

			v.MouseLeave:Connect(function() 
				Tween(v, 1, "BackgroundColor", ElementIndex[Dictionary[ElementNumber].ElementGroup].Color);
				Tween(v.ElementName, .5, "TextTransparency", 1);
			end)
		end
	end

end

function Init.ServerListener()
end

return Init 