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

local BackActive = false 
local TargetPage = nil

local function EnableBackButton(BackButton : TextButton, Boolean : boolean, TargetFrame : Frame)
	BackActive = Boolean
	TargetPage = TargetFrame
	--
	task.delay(.5, function() 
		if Boolean then 
			BackButton.Visible = true 
			Tween(BackButton.UIStroke, 1, "Transparency", BackButton.UIStroke:GetAttribute("Transparency"))
			Tween(BackButton.UIStroke, 1, "Thickness", BackButton.UIStroke:GetAttribute("Thickness"))
			Tween(BackButton, 1, "TextTransparency", BackButton:GetAttribute("TextTransparency"))
			Tween(BackButton, 1, "BackgroundTransparency", BackButton:GetAttribute("BackgroundTransparency"))
		end
	end)
end

function Init.ClientListener()
	local Player : Player = game.Players.LocalPlayer 
	local Character : Character = Player.Character or Player.CharacterAdded:Wait() 

	local GUI : ScreenGui = Player.PlayerGui:WaitForChild("Table")
	local Frame : Frame = GUI.Frame 
	local BackButton : TextButton = GUI.Back
	local SelectionStroke : UIStroke = GUI.SelectStroke

	local Information : Frame = GUI.Information 
	local InformationName : TextLabel = Information.ElementName
	local ElementTemplate : TextButton = Information.Template 
	local InformationAtomicMass : TextLabel = Information.AtomicMass
	local InformationElementGroup : TextLabel = Information.ElementGroup
	local InformationPeriod : TextLabel = Information.Period
	local InformationGroup : TextLabel = Information.Group
	local InformationDescription : TextLabel = Information.Description

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
		elseif v:IsA("UIStroke") then 
			v:SetAttribute("Thickness", v.Thickness)
			v:SetAttribute("Transparency", v.Transparency)
			v.Thickness = 0 
			v.Transparency = 1
		end
	end
	
	Information.Visible = false 
	
	local BackStrokeActive = false 
	BackButton.MouseEnter:Connect(function()
		if BackStrokeActive then return end 
		BackStrokeActive = true 
		task.spawn(function() 
			repeat 
				--Tween(BackButton.UIStroke.UIGradient, 1, "Rotation", BackButton.UIStroke.UIGradient.Rotation + math.random(1,3))
				BackButton.UIStroke.UIGradient.Rotation += math.random(1,3)
				task.wait()
			until not BackStrokeActive
			BackStrokeActive = false 
		end)
	end)
	
	BackButton.MouseLeave:Connect(function()
		if not BackStrokeActive then return end 
		BackStrokeActive = false 
	end)
	BackButton.Activated:Connect(function()
		if BackActive then 
			BackActive = false 
			if Information.Visible then 
				task.delay(1, function() 
					Information.Visible = false 
				end)
			end
			--
			for _, v in(GUI:GetDescendants()) do 
				if v:IsA("Frame") then 
					Tween(v, 1, "BackgroundTransparency", 1)
				elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
					Tween(v, 1, "BackgroundTransparency", 1)
					Tween(v, 1, "ImageTransparency", 1)
				elseif v:IsA("TextLabel") or v:IsA("TextButton") then 
					Tween(v, 1, "BackgroundTransparency", 1)
					Tween(v, 1, "TextTransparency", 1)
				elseif v:IsA("UIStroke") then 
					Tween(v, 1, "Thickness", 0)
					Tween(v, 1, "Transparency", 1)
				end
			end
			--
			TargetPage.Visible = true
			Tween(TargetPage, 1, "BackgroundTransparency", TargetPage:GetAttribute("BackgroundTransparency"))
			for _, v in(TargetPage:GetDescendants()) do 
				if v:IsA("TextButton") or v:IsA("TextLabel") then 
					Tween(v, 1, "BackgroundTransparency", v:GetAttribute("BackgroundTransparency"))
					Tween(v, 1, "TextTransparency", v:GetAttribute("TextTransparency"))
				elseif v:IsA("UIStroke") then 
					Tween(v, 1, "Thickness", v:GetAttribute("Thickness"))
					Tween(v, 1, "Transparency", v:GetAttribute("Transparency"))
				end
			end
		end
	end)

	for i, _ in(Dictionary) do 
		if tostring(i) == GUI.Frame.InteractiveElements:WaitForChild(i).Name then 
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

			Tween(v, 1, "BackgroundTransparency", v:GetAttribute("BackgroundTransparency"))
			v.BackgroundColor3 = ElementIndex[Dictionary[ElementNumber].ElementGroup].Color
			for _, v in(v:GetDescendants()) do 
				if v:IsA("TextLabel") or v:IsA("TextButton") then
					Tween(v, 1, "BackgroundTransparency", v:GetAttribute("BackgroundTransparency"))
					Tween(v, 1, "TextTransparency", v:GetAttribute("TextTransparency"))
				end
			end

			v.Activated:Connect(function() 
				if v.BackgroundTransparency > .5 then return end 
				Information.Visible = true 
				--warn(v.Name .. " selected");
				for index = #GUI.Frame.InteractiveElements:GetChildren(), 1, -1 do 
					local Target = GUI.Frame.InteractiveElements[index]
					Tween(Target, 1, "BackgroundTransparency", 1)
					for _, y in(Target:GetDescendants()) do 
						if y:IsA("TextLabel") or y:IsA("TextButton") then
							Tween(y, 1, "BackgroundTransparency", 1)
							Tween(y, 1, "TextTransparency", 1)
						end
					end
					--task.wait()
				end
				task.delay(1, function() 
					GUI.Frame.Visible = false 
				end)
				--
				ElementTemplate.BackgroundColor3 = ElementIndex[Dictionary[ElementNumber].ElementGroup].Color
				ElementTemplate.Symbol.Text = v:GetAttribute("Symbol")
				ElementTemplate.ElementName.Text = v:GetAttribute("ElementName")
				ElementTemplate.AtomicNumber.Text = v:GetAttribute("AtomicNumber")

				InformationName.Text = v:GetAttribute("ElementName")
				InformationElementGroup.Text = v:GetAttribute("ElementGroup")
				InformationGroup.Text = "Group: " .. v:GetAttribute("Group")
				InformationPeriod.Text = "Period: " .. v:GetAttribute("Period")
				InformationDescription.Text = v:GetAttribute("Description")
				InformationAtomicMass.Text = "Atomic Mass: " .. v:GetAttribute("AtomicMass") .. "u"

				Tween(Information, 1, "BackgroundTransparency", Information:GetAttribute("BackgroundTransparency"))
				Tween(Information.UIStroke, 1, "Thickness", Information.UIStroke:GetAttribute("Thickness"))
				Tween(Information.UIStroke, 1, "Transparency", Information.UIStroke:GetAttribute("Transparency"))
				for _, TextElements in(Information:GetDescendants()) do 
					if TextElements:IsA("TextButton") or TextElements:IsA("TextLabel") then 
						Tween(TextElements, 1, "TextTransparency", TextElements:GetAttribute("TextTransparency"))
						Tween(TextElements, 1, "BackgroundTransparency", TextElements:GetAttribute("BackgroundTransparency"))
					end
				end
				EnableBackButton(BackButton, true, GUI.Frame)
			end)

			v.MouseEnter:Connect(function()
				if v.BackgroundTransparency > .5 then return end 
				local hue, saturation = v.BackgroundColor3:ToHSV()
				local newValue = 7 / 10 

				Tween(v, 1.5, "BackgroundColor3", Color3.fromHSV(hue, saturation, newValue)); 
				Tween(v.ElementName, .5, "TextTransparency", 0);
			end)

			v.MouseLeave:Connect(function() 
				if v.BackgroundTransparency > .5 then return end 
				Tween(v, 1, "BackgroundColor3", ElementIndex[Dictionary[ElementNumber].ElementGroup].Color);
				Tween(v.ElementName, .5, "TextTransparency", 1);
			end)
			task.wait()
		end
	end

end


return Init 