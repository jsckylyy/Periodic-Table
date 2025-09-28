--!nocheck
local Init = {}

-- @Services
local GetService = game.GetService
local Players = GetService(game, "Players")
local TweenService = GetService(game, "TweenService")
local UserInputService = GetService(game, "UserInputService")
local RunService = GetService(game, "RunService")

-- @Dependencies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Dictionary = require(ReplicatedStorage.Dictionaries.Elements)
local ElementIndex = require(ReplicatedStorage.Dictionaries.Index)

-- @Variables
local LOCAL_PLAYER = Players.LocalPlayer
local CAMERA = workspace.CurrentCamera
local CHARACTER = LOCAL_PLAYER and (LOCAL_PLAYER.Character or LOCAL_PLAYER.CharacterAdded:Wait())

-- @Utilities
local function safeDelay(seconds, fn, ...)
	if type(fn) == "function" then
		task.delay(seconds, fn, ...)
	end
end

local function Tween(instance, duration, props)
	assert(instance, "Tween: missing instance")
	assert(duration and type(duration) == "number", "Tween: invalid duration")

	local tweenInfo = TweenInfo.new(duration)
	local tween = TweenService:Create(instance, tweenInfo, props)
	tween:Play()

	safeDelay(duration + 0.5, function()
		if tween.Destroy then
			tween:Destroy()
		end
	end)

	return tween
end

local function zoomCam(amount, duration)
	if not CAMERA then return end
	Tween(CAMERA, duration, { FieldOfView = amount })
end

local function RotateToMouse(player, mousePosition)
	if not player or not player.Character or not player.Character.PrimaryPart then
		return
	end

	local root = player.Character.PrimaryPart
	local bg = Instance.new("BodyGyro")
	bg.Name = "Rotate"
	bg.Parent = root
	bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bg.P = 1e7
	bg.D = 1e4

	local target = Vector3.new(mousePosition.X, root.Position.Y, mousePosition.Z)
	bg.CFrame = CFrame.new(root.Position, target)

	safeDelay(0.2, function()
		if bg and bg.Destroy then
			bg:Destroy()
		end
	end)
end

local function _makeMouseRaycastParams(excludeList)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = excludeList or {}
	return params
end

local function getMouseHit()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = CAMERA:ViewportPointToRay(mousePos.X, mousePos.Y)
	local params = _makeMouseRaycastParams({ CHARACTER, workspace.Debris })
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	return result and result.Instance or nil
end

local function getMousePos()
	local mousePos = UserInputService:GetMouseLocation()
	local ray = CAMERA:ViewportPointToRay(mousePos.X, mousePos.Y)
	local params = _makeMouseRaycastParams({ CHARACTER, workspace.Debris })
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	return result and result.Position or nil
end

local function ApplyAttributes(target, elementNumber)
	local info = Dictionary[elementNumber]
	if not (target and info) then return end

	target:SetAttribute("Symbol", info.Symbol)
	target:SetAttribute("ElementName", info.ElementName)
	target:SetAttribute("AtomicNumber", info.AtomicNumber)
	target:SetAttribute("Description", info.Description)
	target:SetAttribute("Group", info.Group)
	target:SetAttribute("Period", info.Period)
	target:SetAttribute("AtomicMass", info.AtomicMass)
	target:SetAttribute("ElementGroup", info.ElementGroup)
end

local BackActive = false
local TargetPage = nil
local function EnableBackButton(backButton, enable, targetFrame)
	BackActive = enable
	TargetPage = targetFrame

	safeDelay(0.5, function()
		if enable then
			backButton.Visible = true
			if backButton.UIStroke then
				Tween(backButton.UIStroke, 1, {
					Transparency = backButton.UIStroke:GetAttribute("Transparency"),
					Thickness = backButton.UIStroke:GetAttribute("Thickness"),
				})
			end
			Tween(backButton, 1, {
				TextTransparency = backButton:GetAttribute("TextTransparency"),
				BackgroundTransparency = backButton:GetAttribute("BackgroundTransparency"),
			})
		end
	end)
end

local function EnableModesButton(modesButton, enable)
	safeDelay(0.5, function()
		if enable then
			modesButton.Visible = true
			if modesButton.UIStroke then
				Tween(modesButton.UIStroke, 1, {
					Transparency = modesButton.UIStroke:GetAttribute("Transparency"),
					Thickness = modesButton.UIStroke:GetAttribute("Thickness"),
				})
			end
			Tween(modesButton, 1, {
				TextTransparency = modesButton:GetAttribute("TextTransparency"),
				BackgroundTransparency = modesButton:GetAttribute("BackgroundTransparency"),
			})
		end
	end)
end

local function createBohrDiagram(centerPosition, electronCount)
	local nucleusRadius = 5
	local shellSpacing = 5
	local electronSize = 1

	local bohr = Instance.new("Model")
	bohr.Name = "BohrDiagram"
	bohr.Parent = workspace

	local shells = {}
	local remaining = electronCount or 0
	local shell = 1

	while remaining > 0 do
		local maxInShell = 2 * (shell ^ 2)
		local inShell = math.min(maxInShell, remaining)
		remaining = remaining - inShell

		local shellModel = Instance.new("Model")
		shellModel.Name = "Shell" .. tostring(shell)
		shellModel.Parent = bohr
		table.insert(shells, shellModel)

		for i = 1, inShell do
			local angle = (i - 1) * (2 * math.pi / inShell)
			local x = math.cos(angle) * shellSpacing * shell
			local z = math.sin(angle) * shellSpacing * shell

			local p = Instance.new("Part")
			p.Shape = Enum.PartType.Ball
			p.Size = Vector3.new(electronSize, electronSize, electronSize)
			p.Position = centerPosition + Vector3.new(x, 0, z)
			p.BrickColor = BrickColor.Blue()
			p.Material = Enum.Material.Neon
			p.Anchored = true
			p.CastShadow = false
			p.Parent = shellModel
			p.Transparency = 1
			Tween(p, 1, { Transparency = 0 })
			task.wait()
		end

		shell += 1
	end

	task.spawn(function()
		while bohr.Parent do
			for _, s in ipairs(shells) do
				if not s.Parent then break end
				for _, e in ipairs(s:GetChildren()) do
					if e:IsA("BasePart") then
						local relative = e.Position - centerPosition
						local ang = math.rad(1)
						local newX = relative.X * math.cos(ang) - relative.Z * math.sin(ang)
						local newZ = relative.X * math.sin(ang) + relative.Z * math.cos(ang)
						e.Position = centerPosition + Vector3.new(newX, 0, newZ)
					end
				end
			end
			task.wait()
		end
	end)

	return bohr
end

function Init.ClientListener()
	local player = LOCAL_PLAYER
	if not player then return end

	local character = player.Character or player.CharacterAdded:Wait()
	local gui = player:WaitForChild("PlayerGui"):WaitForChild("Table")
	local frame = gui.Frame

	local modesFrame = gui.ModeFrame
	local tableButton = modesFrame.Table
	local molarMassButton = modesFrame.MolarMass

	local molarInfoFrame = gui.MassInformation
	local molarMassPanel = gui.MolarMass

	local backButton = gui.Back
	local selectionStroke = gui.SelectStroke

	local information = gui.Information
	local elementTemplate = information.Template

	CAMERA.CameraType = Enum.CameraType.Scriptable
	local cameraPart = workspace:FindFirstChild("CameraPart")
	if cameraPart then
		CAMERA.CFrame = cameraPart.CFrame
	end

	local initialToggle = false

	local function PeriodicTable()
		task.wait(0.3)
		frame.Visible = true
		molarInfoFrame.Visible = false
		molarMassPanel.Visible = false

		safeDelay(0.5, function()
			initialToggle = true
		end)

		for index, info in pairs(Dictionary) do
			local elementFrame = frame.InteractiveElements:FindFirstChild(tostring(index))
			if not elementFrame then
				continue
			end

			elementFrame.Symbol.Text = info.Symbol
			elementFrame.ElementName.Text = info.ElementName
			elementFrame.AtomicNumber.Text = info.AtomicNumber

			for k, v in pairs(info) do
				elementFrame:SetAttribute(k, v)
			end

			if elementFrame:GetAttribute("Symbol") ~= info.Symbol then
				ApplyAttributes(elementFrame, index)
			end

			elementFrame.BackgroundColor3 = ElementIndex[info.ElementGroup].Color
			Tween(elementFrame, 1, {
				BackgroundTransparency = elementFrame:GetAttribute("BackgroundTransparency")
			})

			for _, child in ipairs(elementFrame:GetDescendants()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					Tween(child, 1, {
						BackgroundTransparency = child:GetAttribute("BackgroundTransparency"),
						TextTransparency = child:GetAttribute("TextTransparency")
					})
				end
			end

			elementFrame.Activated:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end
				if not initialToggle then return end

				information.Visible = true

				for i = #frame.InteractiveElements:GetChildren(), 1, -1 do
					local target = frame.InteractiveElements:GetChildren()[i]
					Tween(target, 1, { BackgroundTransparency = 1 })
					for _, y in ipairs(target:GetDescendants()) do
						if y:IsA("TextLabel") or y:IsA("TextButton") then
							Tween(y, 1, {
								BackgroundTransparency = 1,
								TextTransparency = 1
							})
						end
					end
				end

				task.delay(1, function()
					frame.Visible = false
				end)

				elementTemplate.BackgroundColor3 = ElementIndex[info.ElementGroup].Color
				elementTemplate.Symbol.Text = elementFrame:GetAttribute("Symbol")
				elementTemplate.ElementName.Text = elementFrame:GetAttribute("ElementName")
				elementTemplate.AtomicNumber.Text = elementFrame:GetAttribute("AtomicNumber")

				information.ElementName.Text = elementFrame:GetAttribute("ElementName")
				information.ElementGroup.Text = elementFrame:GetAttribute("ElementGroup")
				information.Group.Text = "Group: " .. tostring(elementFrame:GetAttribute("Group"))
				information.Period.Text = "Period: " .. tostring(elementFrame:GetAttribute("Period"))
				information.Description.Text = elementFrame:GetAttribute("Description")
				information.AtomicMass.Text = "Atomic Mass: " .. tostring(elementFrame:GetAttribute("AtomicMass")) .. "u"

				Tween(information, 1, {
					BackgroundTransparency = information:GetAttribute("BackgroundTransparency")
				})
				if information.UIStroke then
					Tween(information.UIStroke, 1, {
						Thickness = information.UIStroke:GetAttribute("Thickness"),
						Transparency = information.UIStroke:GetAttribute("Transparency")
					})
				end

				for _, e in ipairs(information:GetDescendants()) do
					if e:IsA("TextButton") or e:IsA("TextLabel") then
						Tween(e, 1, {
							TextTransparency = e:GetAttribute("TextTransparency"),
							BackgroundTransparency = e:GetAttribute("BackgroundTransparency")
						})
					end
				end

				gui.Frame:SetAttribute("SelectedElement", tostring(index))

				local nucleus = workspace:FindFirstChild("Nucleus")
				if nucleus then
					if nucleus.Transparency ~= 0 then
						Tween(nucleus, 1, { Transparency = 0 })
					end
					local bohr = createBohrDiagram(nucleus.Position, elementFrame:GetAttribute("AtomicNumber"))

					EnableBackButton(backButton, true, gui.Frame)

					task.spawn(function()
						repeat task.wait(0.3) until gui.Frame:GetAttribute("SelectedElement") ~= tostring(index)
						for _, part in ipairs(bohr:GetDescendants()) do
							if part:IsA("BasePart") then
								Tween(part, 1, { Transparency = 1 })
								task.wait()
							end
						end

						if nucleus then
							Tween(nucleus, 1, { Transparency = 1 })
						end

						task.delay(1, function()
							if bohr.Destroy then bohr:Destroy() end
						end)
					end)
				end
			end)

			elementFrame.MouseEnter:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end
				local h, s, _ = elementFrame.BackgroundColor3:ToHSV()
				local newValue = 0.7
				Tween(elementFrame, 1.5, { BackgroundColor3 = Color3.fromHSV(h, s, newValue) })
				Tween(elementFrame.ElementName, 0.5, { TextTransparency = 0 })
			end)

			elementFrame.MouseLeave:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end
				Task = Tween(elementFrame, 1, { BackgroundColor3 = ElementIndex[info.ElementGroup].Color })
				Tween(elementFrame.ElementName, 0.5, { TextTransparency = 1 })
			end)

			task.wait()
		end

		initialToggle = true
	end

	local function MolarMassMode()
		molarMassPanel.Visible = true
		local selected = {}

		for index, info in pairs(Dictionary) do
			local elementFrame = molarMassPanel.InteractiveElements:FindFirstChild(tostring(index))
			if not elementFrame then
				continue
			end

			elementFrame.Symbol.Text = info.Symbol
			elementFrame.ElementName.Text = info.ElementName
			elementFrame.AtomicNumber.Text = info.AtomicNumber

			for k, v in pairs(info) do
				elementFrame:SetAttribute(k, v)
			end

			if elementFrame:GetAttribute("Symbol") ~= info.Symbol then
				ApplyAttributes(elementFrame, index)
			end

			elementFrame.BackgroundColor3 = ElementIndex[info.ElementGroup].Color
			Tween(elementFrame, 1, { BackgroundTransparency = elementFrame:GetAttribute("BackgroundTransparency") })

			for _, child in ipairs(elementFrame:GetDescendants()) do
				if child:IsA("TextLabel") or child:IsA("TextButton") then
					Tween(child, 1, {
						TextTransparency = child:GetAttribute("TextTransparency"),
						BackgroundTransparency = child:GetAttribute("BackgroundTransparency")
					})
				end
			end

			elementFrame.Activated:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end

				local highlight = elementFrame:FindFirstChild("SelectStroke") or selectionStroke:Clone()
				highlight.Parent = elementFrame

				if table.find(selected, index) then
					local idx = table.find(selected, index)
					while idx do
						table.remove(selected, idx)
						idx = table.find(selected, index)
					end
					Tween(highlight, 0.5, { Transparency = 1, Thickness = 0 })
					safeDelay(0.5, function() if highlight.Destroy then highlight:Destroy() end end)
				else
					table.insert(selected, index)
					Tween(highlight, 0.5, { Transparency = 0, Thickness = 1 })
				end

				Tween(molarInfoFrame.Table, 0.3, { TextTransparency = 1 })
				safeDelay(0.3, function()
					Tween(molarInfoFrame.Table, 0.3, { TextTransparency = 0 })
					molarInfoFrame.Table.Text = table.concat(selected, " + ")
					local total = 0
					for _, n in ipairs(selected) do
						total = total + (Dictionary[n].AtomicMass or 0)
					end
					local rounded = math.floor(total * 100 + 0.5) / 100
					molarInfoFrame.Result.Text = tostring(rounded)
				end)
			end)

			elementFrame.MouseEnter:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end
				local h, s = elementFrame.BackgroundColor3:ToHSV()
				Tween(elementFrame, 1.5, { BackgroundColor3 = Color3.fromHSV(h, s, 0.7) })
				Tween(elementFrame.ElementName, 0.5, { TextTransparency = 0 })
			end)

			elementFrame.MouseLeave:Connect(function()
				if elementFrame.BackgroundTransparency > 0.5 then return end
				Tween(elementFrame, 1, { BackgroundColor3 = ElementIndex[info.ElementGroup].Color })
				Tween(elementFrame.ElementName, 0.5, { TextTransparency = 1 })
			end)

			task.wait()
		end

		molarInfoFrame.Visible = true
		Tween(molarInfoFrame, 1, { BackgroundTransparency = molarInfoFrame:GetAttribute("BackgroundTransparency") })
		if molarInfoFrame.UIStroke then
			Tween(molarInfoFrame.UIStroke, 1, {
				Thickness = molarInfoFrame.UIStroke:GetAttribute("Thickness"),
				Transparency = molarInfoFrame.UIStroke:GetAttribute("Transparency")
			})
		end
		Tween(molarInfoFrame.Frame, 1, { BackgroundTransparency = 0 })

		for _, e in ipairs(molarInfoFrame:GetDescendants()) do
			if e:IsA("TextButton") or e:IsA("TextLabel") then
				Tween(e, 1, {
					TextTransparency = e:GetAttribute("TextTransparency"),
					BackgroundTransparency = e:GetAttribute("BackgroundTransparency")
				})
			elseif e:IsA("UIStroke") then
				Tween(e, 1, {
					Thickness = e:GetAttribute("Thickness"),
					Transparency = e:GetAttribute("Transparency")
				})
			end
		end

		molarInfoFrame.Clear.Activated:Connect(function()
			Tween(molarInfoFrame.Clear, 0.5, { BackgroundColor3 = Color3.fromRGB(0, 0, 0), TextColor3 = Color3.fromRGB(255, 255, 255) })
			safeDelay(0.5, function()
				Tween(molarInfoFrame.Clear, 0.5, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0) })
			end)

			table.clear(selected)
			molarInfoFrame.Result.Text = " "

			Tween(gui.MassInformation.Table, 0.3, { TextTransparency = 1 })
			safeDelay(0.3, function()
				Tween(gui.MassInformation.Table, 0.3, { TextTransparency = 0 })
				gui.MassInformation.Table.Text = table.concat(selected, " + ")
			end)

			for _, v in ipairs(molarMassPanel.InteractiveElements:GetDescendants()) do
				if v:IsA("UIStroke") and v.Name == "SelectStroke" then
					Tween(v, 0.5, { Transparency = 1 })
					safeDelay(0.5, function() if v.Destroy then v:Destroy() end end)
				end
			end
		end)

		molarInfoFrame.Clear.MouseEnter:Connect(function()
			if molarInfoFrame.Clear:GetAttribute("MouseEnter") then return end
			molarInfoFrame.Clear:SetAttribute("MouseEnter", true)
			task.spawn(function()
				repeat
					if molarInfoFrame.Clear.UIStroke and molarInfoFrame.Clear.UIStroke.UIGradient then
						molarInfoFrame.Clear.UIStroke.UIGradient.Rotation += 1
					end
					task.wait()
				until not molarInfoFrame.Clear:GetAttribute("MouseEnter")
			end)
		end)

		molarInfoFrame.Clear.MouseLeave:Connect(function()
			molarInfoFrame.Clear:SetAttribute("MouseEnter", false)
		end)
	end

	for _, v in ipairs(gui:GetDescendants()) do
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
	end

	information.Visible = false

	local backStrokeActive = false
	backButton.MouseEnter:Connect(function()
		if backStrokeActive then return end
		backStrokeActive = true
		task.spawn(function()
			repeat
				if backButton.UIStroke and backButton.UIStroke.UIGradient then
					backButton.UIStroke.UIGradient.Rotation += math.random(1, 3)
				end
				task.wait()
			until not backStrokeActive
			backStrokeActive = false
		end)
	end)

	backButton.MouseLeave:Connect(function()
		backStrokeActive = false
	end)

	backButton.Activated:Connect(function()
		if not BackActive then return end
		BackActive = false
		gui.Frame:SetAttribute("SelectedElement", nil)

		if information.Visible then
			task.delay(1, function() information.Visible = false end)
		end

		for _, v in ipairs(gui:GetDescendants()) do
			if v:IsA("Frame") then
				Tween(v, 1, { BackgroundTransparency = 1 })
			elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
				Tween(v, 1, { BackgroundTransparency = 1, ImageTransparency = 1 })
			elseif (v:IsA("TextLabel") or v:IsA("TextButton")) and v.Name ~= "ModesButton" then
				Tween(v, 1, { BackgroundTransparency = 1, TextTransparency = 1 })
			elseif v:IsA("UIStroke") and v.Parent and v.Parent.Name ~= "ModesButton" then
				Tween(v, 1, { Thickness = 0, Transparency = 1 })
			end
		end

		if TargetPage then
			TargetPage.Visible = true
			Tween(TargetPage, 1, { BackgroundTransparency = TargetPage:GetAttribute("BackgroundTransparency") })
			for _, c in ipairs(TargetPage:GetDescendants()) do
				if c:IsA("TextButton") or c:IsA("TextLabel") then
					Tween(c, 1, {
						BackgroundTransparency = c:GetAttribute("BackgroundTransparency"),
						TextTransparency = c:GetAttribute("TextTransparency")
					})
				elseif c:IsA("UIStroke") then
					Tween(c, 1, { Thickness = c:GetAttribute("Thickness"), Transparency = c:GetAttribute("Transparency") })
				end
			end
		end
	end)

	modesFrame.Visible = true
	Tween(modesFrame, 1, { BackgroundTransparency = modesFrame:GetAttribute("BackgroundTransparency") })
	for _, v in ipairs(modesFrame:GetDescendants()) do
		if v:IsA("TextButton") or v:IsA("TextLabel") then
			Tween(v, 1, { TextTransparency = v:GetAttribute("TextTransparency"), BackgroundTransparency = v:GetAttribute("BackgroundTransparency") })
		elseif v:IsA("UIStroke") then
			Tween(v, 1, { Thickness = v:GetAttribute("Thickness"), Transparency = v:GetAttribute("Transparency") })
		end
	end

	local interactiveButtons = { tableButton, molarMassButton }
	for _, btn in ipairs(interactiveButtons) do
		btn.MouseEnter:Connect(function()
			if btn:GetAttribute("MouseEnter") then return end
			btn:SetAttribute("MouseEnter", true)
			task.spawn(function()
				repeat
					if btn.UIStroke and btn.UIStroke.UIGradient then
						btn.UIStroke.UIGradient.Rotation += 1
					end
					task.wait()
				until not btn:GetAttribute("MouseEnter")
			end)
		end)

		btn.MouseLeave:Connect(function()
			btn:SetAttribute("MouseEnter", false)
		end)

		btn.Activated:Connect(function()
			if btn.Transparency > 0.1 then return end
			local mode = btn.Name
			gui:SetAttribute("SelectedMode", mode)

			for _, v in ipairs(modesFrame:GetDescendants()) do
				if v:IsA("TextButton") or v:IsA("TextLabel") then
					Tween(v, 1, { BackgroundTransparency = 1, TextTransparency = 1 })
				elseif v:IsA("UIStroke") then
					Tween(v, 1, { Thickness = 0, Transparency = 1 })
				end
			end

			Tween(modesFrame, 1, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255, 255, 255) })
			safeDelay(1, function()
				Tween(modesFrame, 1, { BackgroundColor3 = modesFrame:GetAttribute("BackgroundColor"), BackgroundTransparency = 1 })
				safeDelay(1, function() modesFrame.Visible = false end)
			end)

			EnableModesButton(gui.ModesButton, true)

			if gui:GetAttribute("SelectedMode") == "Table" then
				PeriodicTable()
			elseif gui:GetAttribute("SelectedMode") == "MolarMass" then
				MolarMassMode()
			elseif gui:GetAttribute("SelectedMode") == "Conversion" then
			end
		end)
	end

	local modesStroke = false
	gui.ModesButton.MouseEnter:Connect(function()
		if modesStroke then return end
		modesStroke = true
		task.spawn(function()
			repeat
				if gui.ModesButton.UIStroke and gui.ModesButton.UIStroke.UIGradient then
					gui.ModesButton.UIStroke.UIGradient.Rotation += math.random(1, 3)
				end
				task.wait()
			until not modesStroke
			modesStroke = false
		end)
	end)

	gui.ModesButton.MouseLeave:Connect(function()
		modesStroke = false
	end)

	gui.ModesButton.Activated:Connect(function()
		BackActive = false
		gui.Frame:SetAttribute("SelectedElement", nil)

		for _, v in ipairs(gui:GetDescendants()) do
			if v:IsA("Frame") then
				Tween(v, 1, { BackgroundTransparency = 1 })
			elseif v:IsA("ImageLabel") or v:IsA("ImageButton") then
				Tween(v, 1, { BackgroundTransparency = 1, ImageTransparency = 1 })
			elseif v:IsA("TextLabel") or v:IsA("TextButton") then
				Tween(v, 1, { BackgroundTransparency = 1, TextTransparency = 1 })
			elseif v:IsA("UIStroke") then
				Tween(v, 1, { Thickness = 0, Transparency = 1 })
			end
		end

		modesFrame.Visible = true
		Tween(modesFrame, 1, { BackgroundTransparency = modesFrame:GetAttribute("BackgroundTransparency") })
		for _, v in ipairs(modesFrame:GetDescendants()) do
			if v:IsA("TextButton") or v:IsA("TextLabel") then
				Tween(v, 1, { BackgroundTransparency = v:GetAttribute("BackgroundTransparency"), TextTransparency = v:GetAttribute("TextTransparency") })
			elseif v:IsA("UIStroke") then
				Tween(v, 1, { Thickness = v:GetAttribute("Thickness"), Transparency = v:GetAttribute("Transparency") })
			end
		end
	end)
end

return Init
