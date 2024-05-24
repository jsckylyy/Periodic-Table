local Init = {}
--#SERVICE CODE 

local Dictionary : any = require(game.ReplicatedStorage.Dictionaries.Elements)
local ElementIndex : any = require(game.ReplicatedStorage.Dictionaries.Index)

local function Tween(Instance, Duration, Property, Value): ?
end

local ApplyAttributes(Target : any, ElementNumber : number): ?
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
    local GUI : ScreenGui = Player.PlayerGui:FindFirstChild("PeriodicTabe")
    
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

    for _, v in(GUI.InteractiveElements:GetChildren()) do 
        if v.Name == Dictionary[v.Name] then 
            --//#ASSUMING v:IsA("TextLabel") and v:IsADescendantOf("GUI") >> true
            local ElementNumber : number = tonumber(v.Name)
            v.Symbol.Text = Dictionary[ElementNumber].Symbol
            v.AtomicMass.Text = Dictionary[ElementNumber].AtomicMass
            v.ElementName.Text = Dictionary[ElementNumber].ElementName
            --

            for index, value in(Dictionary[ElementNumber]) do 
                v:SetAttribute(index, value)
            end

            if v:GetAttribute("Symbol") != Dictionary[ElementNumber] then 
                --//#FAIL SAFE
               ApplyAttributes(v, ElementNumber)
            end

            v.Activated:Connect(function() 
                warn(v.Name .. " selected");
            end)

            v.MouseEnter:Connect(function() 
                Tween(v, 1, "BackgroundColor", Color3.fromRGB(255,255,255)) --TODO: Make this a gray color
                Tween(v.ElementName, .5, "TextTransparency", 0)
            end)

            v.MouseLeave:Connect(function() 
                Tween(v, 1, "BackgroundColor", Index[Dictionary[ElementNumber].ElementGroup].Color)
                Tween(v.ElementName, .5, "TextTransparency", 1)
            end)
        end
    end

end

function Init.ServerListener()
end

return Init 