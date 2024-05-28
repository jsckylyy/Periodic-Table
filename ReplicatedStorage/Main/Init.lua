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

local function EnableModesButton(ModesButton : TextButton, Boolean : boolean)
	task.delay(.5, function() 
		if Boolean then 
			ModesButton.Visible = true 
			Tween(ModesButton.UIStroke, 1, "Transparency", ModesButton.UIStroke:GetAttribute("Transparency"))
			Tween(ModesButton.UIStroke, 1, "Thickness", ModesButton.UIStroke:GetAttribute("Thickness"))
			Tween(ModesButton, 1, "TextTransparency", ModesButton:GetAttribute("TextTransparency"))
			Tween(ModesButton, 1, "BackgroundTransparency", ModesButton:GetAttribute("BackgroundTransparency"))
		end
	end)
end

function createBohrDiagram(centerPosition: Vector3, Electrons : number)
	local nucleusRadius : number = 5
	local electronShellDistance : number = 5
	local electronSize : number = 1

	local bohrModel : Model = Instance.new("Model")
	bohrModel.Name = "BohrDiagram"
	bohrModel.Parent = game.Workspace

	local electronShells : any = {}
	local electronsLeft = Electrons
	local shellNumber = 1

	while electronsLeft > 0 do
		local maxElectronsInShell = 2 * shellNumber^2
		local electronsInShell = math.min(maxElectronsInShell, electronsLeft)
		electronsLeft = electronsLeft - electronsInShell

		local Shell : Model = Instance.new("Model")
		Shell.Name = "Shell" .. shellNumber
		Shell.Parent = bohrModel
		table.insert(electronShells, Shell)

		for i = 1, electronsInShell do
			local Angle = (i - 1) * (2 * math.pi / electronsInShell)
			local x = math.cos(Angle) * electronShellDistance * shellNumber
			local z = math.sin(Angle) * electronShellDistance * shellNumber

			local Electron : BasePart = Instance.new("Part")
			Electron.Shape = Enum.PartType.Ball
			Electron.Size = Vector3.new(electronSize, electronSize, electronSize)
			Electron.Position = centerPosition + Vector3.new(x, 0, z)
			Electron.BrickColor = BrickColor.Blue()
			Electron.Material = Enum.Material.Neon
			Electron.Anchored = true
			Electron.Parent = Shell
			Electron.Transparency = 1 
			Electron.CastShadow = false 
			Tween(Electron, 1, "Transparency", 0)
			task.wait()
		end
		shellNumber += 1
	end
	task.spawn(function()
		while true do
			for _, shell in pairs(electronShells) do
				if not shell or not shell.Parent then
					break
				end

				for _, electron in pairs(shell:GetChildren()) do
					if electron:IsA("Part") then
						local angle = math.rad(1)  -- Adjust the speed of rotation here
						local position = electron.Position - centerPosition
						local newX = position.X * math.cos(angle) - position.Z * math.sin(angle)
						local newZ = position.X * math.sin(angle) + position.Z * math.cos(angle)
						electron.Position = centerPosition + Vector3.new(newX, 0, newZ)
					end
				end
			end
			task.wait()
		end
	end)
	return bohrModel
end

function Init.ClientListener()
	local Player : Player = game.Players.LocalPlayer 
	local Character : Character = Player.Character or Player.CharacterAdded:Wait() 

	local GUI : ScreenGui = Player.PlayerGui:WaitForChild("Table")
	local Frame : Frame = GUI.Frame 

	local Modes : Frame = GUI.ModeFrame 
	local TableButton : TextButton = Modes.Table 

	local MolarMassButton : TextButton = Modes.MolarMass 
	local MolarInformation : Frame = GUI.MassInformation 
	local MolarMass : Frame = GUI.MolarMass

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

	local Camera : Camera = workspace.CurrentCamera
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = workspace:WaitForChild("CameraPart").CFrame

	local InitialToggle = false 

	local function PeriodicTable()
		task.wait(.3)
		Frame.Visible = true
		GUI.MassInformation.Visible = false 
		GUI.MolarMass.Visible = false 
		task.delay(.5, function() 
			InitialToggle = true 
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
					if not InitialToggle then return end
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
					GUI.Frame:SetAttribute("SelectedElement", v.Name)
					--//BOHR DIAGRAM
					local Nucleus : UnionOperation = workspace.Nucleus
					if Nucleus.Transparency ~= 0 then 
						Tween(Nucleus, 1, "Transparency", 0)
					end
					local Bohr = createBohrDiagram(Nucleus.Position, v:GetAttribute("AtomicNumber"))
					EnableBackButton(BackButton, true, GUI.Frame)
					task.spawn(function() 
						repeat task.wait(.3) until GUI.Frame:GetAttribute("SelectedElement") ~= v.Name
						for _, v in(Bohr:GetDescendants()) do 
							if v:IsA("BasePart") then 
								Tween(v, 1, "Transparency", 1)
								task.wait()
							end
						end
						Tween(Nucleus, 1, "Transparency", 1)
						task.delay(1, Bohr.Destroy, Bohr)
					end)
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
		InitialToggle = true 
	end

	local function MolarMass()
		GUI.MolarMass.Visible = true 
		local SelectedElements = {}
		--
		for i, _ in(Dictionary) do 
			if tostring(i) == GUI.MolarMass.InteractiveElements:WaitForChild(i).Name then 
				--//#ASSUMING v:IsA("TextLabel") and v:IsADescendantOf("GUI") >> true
				local v = GUI.MolarMass.InteractiveElements[i]
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
					local Highlight = v:FindFirstChild("SelectStroke") or SelectionStroke:Clone() 
					Highlight.Parent = v 
					if table.find(SelectedElements, ElementNumber) then 
						--warn("Removing " .. ElementNumber .. " from table")
						local index = table.find(SelectedElements, ElementNumber)
						while index do
							table.remove(SelectedElements, index)
							index = table.find(SelectedElements, ElementNumber)
						end
						--table.remove(SelectedElements, ElementNumber)
						Tween(Highlight, .5, "Transparency", 1)
						Tween(Highlight, .5, "Thickness", 0)
						task.delay(.5, Highlight.Destroy, Highlight)
					else 
						table.insert(SelectedElements, ElementNumber)
						Tween(Highlight, .5, "Transparency", 0)
						Tween(Highlight, .5, "Thickness", 1)
					end
					Tween(GUI.MassInformation.Table, .3, "TextTransparency", 1)
					task.delay(.3, function() 
						Tween(GUI.MassInformation.Table, .3, "TextTransparency", 0)
						GUI.MassInformation.Table.Text = table.concat(SelectedElements, " + ")
						--
						local TotalMass = 0
						for _, AtomicNumber in(SelectedElements) do 
							TotalMass += Dictionary[AtomicNumber].AtomicMass
						end
						TotalMass = math.floor(TotalMass * 100)
						MolarInformation.Result.Text = tostring(TotalMass/100)
					end)
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
		MolarInformation.Visible = true 
		Tween(MolarInformation, 1, "BackgroundTransparency", MolarInformation:GetAttribute("BackgroundTransparency"))
		Tween(MolarInformation.UIStroke, 1, "Thickness", MolarInformation.UIStroke:GetAttribute("Thickness"))
		Tween(MolarInformation.UIStroke, 1, "Transparency", MolarInformation.UIStroke:GetAttribute("Transparency"))
		Tween(MolarInformation.Frame, 1, "BackgroundTransparency", 0)
		for _, TextElements in(MolarInformation:GetDescendants()) do 
			if TextElements:IsA("TextButton") or TextElements:IsA("TextLabel") then 
				Tween(TextElements, 1, "TextTransparency", TextElements:GetAttribute("TextTransparency"))
				Tween(TextElements, 1, "BackgroundTransparency", TextElements:GetAttribute("BackgroundTransparency"))
			elseif TextElements:IsA("UIStroke") then 
				Tween(TextElements, 1, "Thickness", TextElements:GetAttribute("Thickness"))
				Tween(TextElements, 1, "Transparency", TextElements:GetAttribute("Transparency"))
			end
		end
		
		MolarInformation.Clear.Activated:Connect(function()
			Tween(MolarInformation.Clear, .5, "BackgroundColor3", Color3.fromRGB(0, 0, 0))
			Tween(MolarInformation.Clear, .5, "TextColor3", Color3.fromRGB(255, 255, 255))
			task.delay(.5, function() 
				Tween(MolarInformation.Clear, .5, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
				Tween(MolarInformation.Clear, .5, "TextColor3", Color3.fromRGB(0, 0, 0))
			end)
			--
			table.clear(SelectedElements)
			
			MolarInformation.Result.Text = " "

			Tween(GUI.MassInformation.Table, .3, "TextTransparency", 1)
			task.delay(.3, function() 
				Tween(GUI.MassInformation.Table, .3, "TextTransparency", 0)
				GUI.MassInformation.Table.Text = table.concat(SelectedElements, " + ")
			end)
			for _, v in(GUI.MolarMass.InteractiveElements:GetDescendants()) do 
				if v:IsA("UIStroke") and v.Name == "SelectStroke" then 
					Tween(v, .5, "Transparency", 1)
					task.delay(.5, v.Destroy, v)
				end
			end
		end)
		--
		MolarInformation.Clear.MouseEnter:Connect(function()
			if MolarInformation.Clear:GetAttribute("MouseEnter") then return end 
			MolarInformation.Clear:SetAttribute("MouseEnter", true)
			task.spawn(function() 
				repeat
					MolarInformation.Clear.UIStroke.UIGradient.Rotation += 1
					task.wait()
				until not MolarInformation.Clear:GetAttribute("MouseEnter")
			end)

		end)

		MolarInformation.Clear.MouseLeave:Connect(function()
			if not MolarInformation.Clear:GetAttribute("MouseEnter") then return end 
			MolarInformation.Clear:SetAttribute("MouseEnter", false)
		end)
		--
		
	end
	--//Initial Load GUI
	for _, v in(GUI:GetDescendants()) do 
		if v:IsA("Frame") then 
			v:SetAttribute("BackgroundTransparency", v.BackgroundTransparency)
			v:SetAttribute("BackgroundColor", v.BackgroundColor3)
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
		--task.wait()
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
			GUI.Frame:SetAttribute("SelectedElement", nil)
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
				elseif v:IsA("TextLabel") or v:IsA("TextButton") and v.Name ~= "ModesButton" then 
					Tween(v, 1, "BackgroundTransparency", 1)
					Tween(v, 1, "TextTransparency", 1)
				elseif v:IsA("UIStroke") and v.Parent.Name ~= "ModesButton" then 
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

	Modes.Visible = true 
	Tween(Modes, 1, "BackgroundTransparency", Modes:GetAttribute("BackgroundTransparency"))
	for _, v in(Modes:GetDescendants()) do 
		if v:IsA("TextButton") or v:IsA("TextLabel") then 
			Tween(v, 1, "TextTransparency", v:GetAttribute("TextTransparency"))
			Tween(v, 1, "BackgroundTransparency", v:GetAttribute("BackgroundTransparency"))
		elseif v:IsA("UIStroke") then 
			Tween(v, 1, "Thickness", v:GetAttribute("Thickness"))
			Tween(v, 1, "Transparency", v:GetAttribute("Transparency"))
		end
	end

	local InteractiveButtons = {}
	table.insert(InteractiveButtons, TableButton)
	table.insert(InteractiveButtons, MolarMassButton)

	for _, InteractiveElement in(InteractiveButtons) do 
		InteractiveElement.MouseEnter:Connect(function()
			if InteractiveElement:GetAttribute("MouseEnter") then return end 
			InteractiveElement:SetAttribute("MouseEnter", true)
			task.spawn(function() 
				repeat
					InteractiveElement.UIStroke.UIGradient.Rotation += 1
					task.wait()
				until not InteractiveElement:GetAttribute("MouseEnter")
			end)

		end)

		InteractiveElement.MouseLeave:Connect(function()
			if not InteractiveElement:GetAttribute("MouseEnter") then return end 
			InteractiveElement:SetAttribute("MouseEnter", false)
		end)

		InteractiveElement.Activated:Connect(function()
			if InteractiveElement.Transparency > .1 then return end 
			local Mode = InteractiveElement.Name 
			GUI:SetAttribute("SelectedMode", Mode)

			for _, v in(Modes:GetDescendants()) do 
				if v:IsA("TextButton") or v:IsA("TextLabel") then 
					Tween(v, 1, "BackgroundTransparency", 1)
					Tween(v, 1, "TextTransparency", 1)
				elseif v:IsA("UIStroke") then 
					Tween(v, 1, "Thickness", 0)
					Tween(v, 1, "Transparency", 1)
				end
			end
			Tween(Modes, 1, "BackgroundTransparency", 0)
			Tween(Modes, 1, "BackgroundColor3", Color3.fromRGB(255, 255, 255))
			task.delay(1, function() 
				Tween(Modes, 1, "BackgroundColor3", Modes:GetAttribute("BackgroundColor"))
				Tween(Modes, 1, "BackgroundTransparency", 1)
				task.delay(1, function() Modes.Visible = false end)
			end)
			
			EnableModesButton(GUI.ModesButton, true)
			if GUI:GetAttribute("SelectedMode") == "Table" then 
				PeriodicTable()
			end

			if GUI:GetAttribute("SelectedMode") == "MolarMass" then 
				MolarMass()
			end
			
			if GUI:GetAttribute("SelectedMode") == "Conversion" then 
				--Conversion()
			end
		end)
		
	end

	local ModesStroke = false 
	GUI.ModesButton.MouseEnter:Connect(function()
		if ModesStroke then return end 
		ModesStroke = true 
		task.spawn(function() 
			repeat 
				GUI.ModesButton.UIStroke.UIGradient.Rotation += math.random(1,3)
				task.wait()
			until not ModesStroke
			ModesStroke = false 
		end)
	end)

	GUI.ModesButton.MouseLeave:Connect(function()
		if not ModesStroke then return end 
		ModesStroke = false 
	end)

	GUI.ModesButton.Activated:Connect(function()
		BackActive = false 
		GUI.Frame:SetAttribute("SelectedElement", nil)
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
		Modes.Visible = true 
		Tween(Modes, 1, "BackgroundTransparency", Modes:GetAttribute("BackgroundTransparency"))
		for _, v in(Modes:GetDescendants()) do 
			if v:IsA("TextButton") or v:IsA("TextLabel") then 
				Tween(v, 1, "BackgroundTransparency", v:GetAttribute("BackgroundTransparency"))
				Tween(v, 1, "TextTransparency", v:GetAttribute("TextTransparency"))
			elseif v:IsA("UIStroke") then 
				Tween(v, 1, "Thickness", v:GetAttribute("Thickness"))
				Tween(v, 1, "Transparency", v:GetAttribute("Transparency"))
			end
		end
	end)

end


return Init 