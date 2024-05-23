local Init = {}
--#SERVICE CODE 

local function Tween(Instance, Duration, Property, Value): ?
end

local Dictionary : any = require(game.ReplicatedStorage.Dictionaries.Elements)
local ElementIndex : any = require(game.ReplicatedStorage.Dictionaries.Index)

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
            local ElementNumber : number = tonumber(v.Name)
            v.Symbol.Text = Dictionary[ElementNumber].Abbreviation
            v.AtomicMass.Text = Dictionary[ElementNumber].AtomicMass
            v.ElementName.Text = Dictionary[ElementNumber].ElementName
            --
            v:SetAttribute("Symbol", Dictionary[ElementNumber].Abbreviation)
            v:SetAttribute("ElementName", Dictionary[ElementNumber].ElementName)
            v:SetAttribute("AtomicNumber", Dictionary[ElementNumber].AtomicNumber)
            v:SetAttribute("Description", Dictionary[ElementNumber].Description)

            v:SetAttribute("Group", Dictionary[ElementNumber].Group)
            v:SetAttribute("Period", Dictionary[ElementNumber].Period)

            v:SetAttribute("AtomicMass", Dictionary[ElementNumber].AtomicMass)
            v:SetAttribute("ElementGroup", Dictionary[ElementNumber].ElementGroup)

            v.Activated:Connect(function() 
                warn(v.Name .. " selected")
            end)

            v.MouseEnter:Connect(function() 

            end)

            v.MouseLeave:Connect(function() 

            end)
        end
    end

end

function Init.ServerListener()
end

return Init 