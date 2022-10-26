local InteractRemote = game:GetService("Workspace").Map.Buildings.UCS.Other.DeliveryJob.IPart.Interact
local Grabbables = game:GetService("Workspace").Grabable
local LocalPlayer = game.Players.LocalPlayer
local Players = game.Players
local DialogFrame = LocalPlayer.PlayerGui.UserGui.Dialog
local Events = game:GetService("ReplicatedStorage").Events
local Startup = tick()

local function Grab(Bool, Part)
  if Bool == true then
    Events.Grab:InvokeServer(Part, {}) 
  elseif Bool == false then
    Events.Ungrab:FireServer(Part, false, {})
  end
end

local function BetterRound(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function TP(Position : CFrame)

    if typeof(Position) == "Instance" then
        Position = Position.CFrame
    end

    if typeof(Position) == "Vector3" then
        Position = CFrame.new(Position)
    end
    
    if typeof(Position) == "CFrame" then
        LocalPlayer.Character:PivotTo(Position)
    else
        warn("[!] Invalid Argument Passed to TP()")
    end
    
end

function GetClosestPart(tables)
    local Distances = {}
    for i,v in pairs(tables) do
        Distances[i] = LocalPlayer:DistanceFromCharacter(v.Position)
    end
    local BestDistance = math.huge
    local Closest
    for i,v in pairs(Distances) do
        if v < BestDistance then
            BestDistance = v
            Closest = tables[i]
        end
    end
    return Closest
end

local repo = 'https://raw.githubusercontent.com/wally-rblx/LinoriaLib/main/'
local t = tostring(tick())

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/centerepic/RefineryCaves/main/library.lua?t='..t))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua?t='..t))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua?t='..t))()
local Version = "1.9a"

local Window = Library:CreateWindow({
    Title = 'sasware v'..Version.." | Public Build",
    Center = true, 
    AutoShow = true,
})

local Tabs = {
    Main = Window:AddTab('Main'),
    Automation = Window:AddTab('Automation'),
    Building = Window:AddTab('Building'),
    Stores = Window:AddTab('Stores'),
    ['UI Settings'] = Window:AddTab('UI Settings')
}

local TargetPart

local Hitboxes = {}

-- < Define Coroutines. >

function GetBlueprint(...)
    if not game.Players.LocalPlayer.Values.Blueprints:FindFirstChild(...) then
        local BlueprintValue = Instance.new("BoolValue", game.Players.LocalPlayer.Values.Blueprints)
        BlueprintValue.Value = true
        BlueprintValue.Name = (...)
    end
end

local AutoBoxCoro = coroutine.create(function()
    while task.wait(3) do
        if Toggles.BoxAutoFarm.Value == true then
            pcall(function()
                InteractRemote:FireServer()
                for i,v in pairs(getconnections(DialogFrame:WaitForChild("Yes",5).MouseButton1Click)) do
                    v:Fire()
                end
                local DeliveryBox = Grabbables:WaitForChild("DeliveryBox",10)
                wait(1)
                local GrabPart = DeliveryBox:FindFirstChildOfClass("Part")
                Grab(true,GrabPart)
                DeliveryBox:PivotTo(CFrame.new(DeliveryBox.Configuration.To.Value.Position + Vector3.new(0,3,0)))
                wait(0.5)
                Grab(false,GrabPart)
                DeliveryBox:Destroy()
            end)
        end
    end   
end)

local AutoMineCoro = coroutine.create(function()
    while task.wait(0.8) do
        pcall(function()
            if Toggles.MineAura.Value == true and LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                
                Hitboxes = {}
                
                for i,v in pairs(game:GetService("Workspace").WorldSpawn:GetChildren()) do
                    if v:FindFirstChild("Part") and not v:FindFirstChild("Stage1") then
                        table.insert(Hitboxes,v.Part)
                    end
                end

                local RockChosen
                RockChosen = GetClosestPart(Hitboxes).Parent

                local RockChosen = RockChosen.Rock:FindFirstChildOfClass("Model"):FindFirstChild("Part")

                TargetPart = RockChosen

                for i,v in pairs(LocalPlayer.Character:GetChildren()) do
                    if v:IsA("Tool") and v.Name:find("Pickaxe") then
                        v:Activate()
                    end
                end

            end
        end)
    end
end)

local IdleMoneyCoro = coroutine.create(function()
    while wait(11) do
        pcall(function()
            if Toggles.IdleIncome.Value == true then
                game:GetService("ReplicatedStorage").Events.TransferCash:FireServer(LocalPlayer,0.5)
            end
        end)
    end
end)

local AutoOreCoro = coroutine.create(function()
    while wait() do
        pcall(function()
            if Toggles.OreAutoFarm.Value == true and Options.OreDropdown.Value ~= nil then
                for _,Node in pairs(workspace.WorldSpawn:GetChildren()) do
                    if Node.RockString and Node.RockString.Value == Options.OreDropdown.Value then

                        TP(Node.Part.Position + Vector3.new(0,3,0))

                        for _,Ore in pairs(Node.Rock:FindFirstChildOfClass("Model"):GetChildren()) do
                            if Ore.Name ~= 'Hitbox' and Ore.Name ~= 'Bedrock' then
                                repeat
                                task.wait()

                                TargetPart = Ore

                                TP(Ore.Position - Vector3.new(0,3,0))

                                if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                                    local TTE
                                    for _,Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
                                        if Tool.Name:find("Pickaxe") then
                                            if TTE ~= nil then
                                                if Tool.Configuration and Tool.Configuration.Tier and Tool.Configuration.Tier.Value > TTE.Configuration.Tier.Value then
                                                    TTE = Tool
                                                end
                                            else
                                                TTE = Tool
                                            end
                                        end
                                    end
                                    LocalPlayer.Character.Humanoid:EquipTool(TTE)
                                end

                                LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
                                until
                                Ore.Parent ~= Node.Rock:FindFirstChildOfClass("Model") or (Toggles.OreAutoFarm.Value == false or Options.OreDropdown.Value == nil)
                            end
                        end
                    end
                end
                TargetPart = nil
            end
        end)
    end
end)

-- local function FillBlueprints(Table)
--     print("Filling blueprints!")
--     for i,v in pairs(Table) do
--         repeat
--             wait()
--             if Options.BlueprintMaterial.Value then
--                 print("Blueprint Material VALID.")
--                 for _,Node in pairs(workspace.WorldSpawn:GetChildren()) do
--                     if Node.RockString and Options.BlueprintMaterial.Value == Node.RockString.Value then
--                         print("Found a valid node!")

--                         TP(Node.Part.Position + Vector3.new(0,3,0))

--                         for _,Ore in pairs(Node.Rock:FindFirstChildOfClass("Model"):GetChildren()) do
--                             if Ore.Name ~= 'Hitbox' and Ore.Name ~= 'Bedrock' then
--                                 repeat
--                                 task.wait()

--                                 TargetPart = Ore

--                                 TP(Ore.Position - Vector3.new(0,3,0))

--                                 if not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
--                                     local TTE
--                                     for _,Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
--                                         if Tool.Name:find("Pickaxe") then
--                                             if TTE ~= nil then
--                                                 if Tool.Configuration and Tool.Configuration.Tier and Tool.Configuration.Tier.Value > TTE.Configuration.Tier.Value then
--                                                     TTE = Tool
--                                                 end
--                                             else
--                                                 TTE = Tool
--                                             end
--                                         end
--                                     end
--                                     LocalPlayer.Character.Humanoid:EquipTool(TTE)
--                                 end

--                                 LocalPlayer.Character:FindFirstChildOfClass("Tool"):Activate()
--                                 until
--                                 Ore.Parent ~= Node.Rock:FindFirstChildOfClass("Model") or (Options.BlueprintMaterial.Value == nil)
--                             end
--                         end
--                     end
--                 end
--             end

--             print("Mined!")

--             for _,grabable in pairs(workspace.Grabable:GetChildren()) do
--                 if grabable.Name == "MaterialPart" and grabable:FindFirstChild("Owner") and grabable.Owner.Value == LocalPlayer then
--                     print("found valid grabbable, checking if right material....")
--                     if grabable:FindFirstChild("Configuration") and Options.BlueprintMaterial.Value:find(grabable.Configuration:FindFirstChild("Data").MatInd.Value) then
--                         print("TPING x1 valid grabbable.")
--                         TP(grabable.Part)
--                         wait(0.2)
--                         grabable:PivotTo(v.Part)
--                     end
--                 end
--             end

--             TargetPart = nil
--         until v:FindFirstChild("Blueprint") == nil or Options.BlueprintMaterial.Value == nil
--     end
-- end

-- broken unfinished code above (shield your eyes)

-- < Define Coroutines. />


-- < Configure UI (Create tabs, toggles, etc.) >

local OreTeleports = Tabs.Main:AddLeftGroupbox('Ore Utilities')

OreTeleports:AddToggle('MineAura', {
    Text = 'Mine aura',
    Default = false,
    Tooltip = 'Automatically mines ores around you',
})

OreTeleports:AddToggle('TeleportMethod', {
    Text = 'Long Range Ore Teleport Method',
    Default = true,
    Tooltip = 'Uses a more stable method to teleport ores. [HIGHLY RECCOMENDED]',
})

OreTeleports:AddButton('Teleport all owned ores to player', function()
    local Lastore = nil
    local OP = LocalPlayer.Character.HumanoidRootPart.CFrame
    for i,v in pairs(Grabbables:GetChildren()) do
        if v.Name == "MaterialPart" and v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer and v.Part.Material ~= Enum.Material.Neon then
            local IsFar = true

            if Lastore ~= nil and (v.Part.Position - Lastore).Magnitude < 7 then
                IsFar = false
            end

            if IsFar == true then
                TP(v.Part)
            end

            Grab(true,v.Part)

            if Toggles.TeleportMethod.Value == true and IsFar == true then
                wait(0.2)
            else
                task.wait()
            end
            
            Lastore = v.Part.Position
            v:PivotTo(OP)
            wait()
        end
    end
    TP(OP)
end)

OreTeleports:AddButton('Teleport all owned ores to plot', function()
    local Lastore = nil

    local Myplot = nil

    for i,v in pairs(game:GetService("Workspace").Plots:GetChildren()) do
        if v.Owner and v.Owner.Value == LocalPlayer then
            Myplot = v.Base
        end
    end

    local OP = LocalPlayer.Character.HumanoidRootPart.CFrame
    for i,v in pairs(Grabbables:GetChildren()) do
        if v.Name == "MaterialPart" and v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer and v.Part.Material ~= Enum.Material.Neon and (v.Part.Position - Myplot.Position).Magnitude > 80 then
            local IsFar = true

            if Lastore ~= nil and (v.Part.Position - Lastore).Magnitude < 7 then
                IsFar = false
            end

            if IsFar == true then
                TP(v.Part)
            end

            Grab(true,v.Part)
            
            if Toggles.TeleportMethod.Value == true and IsFar == true then
                wait(0.2)
            else
                task.wait()
            end
            
            Lastore = v.Part.Position
            v:PivotTo(Myplot.CFrame + Vector3.new(0,4,0))
            wait()
        end
    end
    TP(OP)
end)

coroutine.resume(AutoMineCoro)
coroutine.resume(IdleMoneyCoro)
coroutine.resume(AutoBoxCoro)
coroutine.resume(AutoOreCoro)

local Teleports = Tabs.Main:AddLeftGroupbox('Teleports')

Teleports:AddButton('Teleport to plot', function()
    local Myplot = nil

    for i,v in pairs(game:GetService("Workspace").Plots:GetChildren()) do
        if v.Owner and v.Owner.Value == LocalPlayer then
            Myplot = v.Base
        end
    end

    TP(Myplot.CFrame + Vector3.new(0,4,0))
end)

local TPIDX = {}
TPIDX['Utility Convenient Store'] = Vector3.new(-1002.573, 4.25, -611.692)
TPIDX['Land Agency'] = Vector3.new(-1008, 4, -723)
TPIDX['Ore Sellary'] = Vector3.new(-422.667, 6.5, -77.358)
TPIDX['Utility Store'] = Vector3.new(-468.379, 5.75, -4.919)
TPIDX['Pickaxe Shop'] = Vector3.new(736.24, 2.25, 64.567)
TPIDX["M's Dealership"] = Vector3.new(709.589, 8.25, -997.523)
TPIDX['Mighty Furniture of ZD'] = Vector3.new(-1017.249, 4.25, 700.392)
TPIDX['Electronics Antishop'] = Vector3.new(-106.961, 240, 1122.705) 
TPIDX['Secret Stash'] = Vector3.new(-504.2, 4.25, -664.323)
TPIDX['Meteor Rug'] = Vector3.new(-3475.94, 18, 1040.367)

Teleports:AddDropdown('StoreTeleportDropDown', {
    Values = { 'Utility Convenient Store', 'Land Agency', 'Ore Sellary', 'Utility Store', 'Pickaxe Shop' , "M's Dealership", 'Mighty Furniture of ZD', 'Electronics Antishop', 'Secret Stash', 'Meteor Rug'},
    Default = nil,
    Multi = false,
    Text = 'Building Teleports',
    Tooltip = 'List of shops to teleport to.',
})

Options.StoreTeleportDropDown:OnChanged(function()
    if Options.StoreTeleportDropDown.Value ~= nil then
        TP(TPIDX[Options.StoreTeleportDropDown.Value])
        Options.StoreTeleportDropDown:SetValue(nil)
    end
end)

local TPIDX2 = {}
TPIDX2['Volcanium'] = Vector3.new(-2871.984, -776.293, 2789.415)
TPIDX2['Cloudnite'] = Vector3.new(472.196, 431.75, 1265.718)
TPIDX2['Emerald'] = Vector3.new(549.64, 273.75, 347.393)
TPIDX2['Marble'] = Vector3.new(520.628, 11.75, -973.84)
TPIDX2['Gold'] = Vector3.new(662.51, 16.5, -1502.161)

Teleports:AddDropdown('OreTeleportDropDown', {
    Values = {'Volcanium','Cloudnite','Emerald','Marble','Gold'},
    Default = nil,
    Multi = false,
    Text = 'Ore/Map teleports',
    Tooltip = 'List of locations to teleport to.',
})

Options.OreTeleportDropDown:OnChanged(function()
    if Options.OreTeleportDropDown.Value ~= nil then
        TP(TPIDX2[Options.OreTeleportDropDown.Value])
        Options.OreTeleportDropDown:SetValue(nil)
    end
end)

local MiscTab = Tabs.Main:AddLeftGroupbox('Miscellaneous')

MiscTab:AddButton('Spawn Meteor for FREE!', function()
    for i = 3,1,-1 do
        local OPos = LocalPlayer.Character.HumanoidRootPart.CFrame
        local Totem
        for i,v in pairs(game:GetService("Workspace").Grabable:GetChildren()) do
            if v.Name == "Meteorite Totem" and v:FindFirstChild("Shop") then
                Totem = v
            end
        end
        if Totem then
            TP(Totem.Ball)
            task.wait(0.2)
            Grab(true,Totem.Ball)
            TP(CFrame.new(workspace.Map.MeteoriteRoom.Piedestal.Touch.Position))
            Totem:PivotTo(CFrame.new(workspace.Map.MeteoriteRoom.Piedestal.Touch.Position))
            firetouchinterest(Totem.Ball,workspace.Map.MeteoriteRoom.Piedestal.Touch,1)
            wait()
            firetouchinterest(Totem.Ball,workspace.Map.MeteoriteRoom.Piedestal.Touch,0)
            TP(OPos)
        end
    end
end)

MiscTab:AddButton('Make Trusty Pickaxe', function()

    local OPos = LocalPlayer.Character.HumanoidRootPart.CFrame
   
    local StonePick
    local RustyPick
    local IronPick

    for i,v in pairs(game:GetService("Workspace").Grabable:GetChildren()) do
        if v.Name == "Boxed Stone Pickaxe" and v:FindFirstChild("Shop") then
            StonePick = v
        end
        if v.Name == "Boxed Rusty Pickaxe" and v:FindFirstChild("Shop") then
            RustyPick = v
        end
        if v.Name == "Boxed Iron Pickaxe" and v:FindFirstChild("Shop") then
            IronPick = v
        end
    end

    TP(StonePick.Part)

    wait(0.2)

    Grab(true,StonePick.Part)
    Grab(true,RustyPick.Part)
    StonePick:PivotTo(game:GetService("Workspace").Map.Objects.TrustIssues.Void.CFrame)
    RustyPick:PivotTo(game:GetService("Workspace").Map.Objects.TrustIssues.Void.CFrame)
    TP(IronPick.Part)

    wait(0.2)

    Grab(true,IronPick.Part)
    IronPick:PivotTo(game:GetService("Workspace").Map.Objects.TrustIssues.Void.CFrame)

    local LCON
    LCON = game:GetService("Workspace").Grabable.ChildAdded:Connect(function(Child)
        if Child.Name == "Tool" then
            task.wait(0.1)
            if Child:FindFirstChild("Owner") and Child:FindFirstChild("Owner").Value == LocalPlayer then
                TP(Child.Part)
                wait(0.2)
                Child.Part.Interact:FireServer()
                LCON:Disconnect()
                wait()
                TP(OPos)
            end
        end
    end)

    wait()

    TP(OPos)
end)

MiscTab:AddButton('Get Clientside Proton-24', function()
    game:GetService("ReplicatedStorage").Tools["Proton-24"]:Clone().Parent = LocalPlayer.Backpack
    game:GetService("ReplicatedStorage").Tools["Proton-24"]:Clone().Parent = LocalPlayer.StarterGear
end)

MiscTab:AddToggle('NoDrown', {
    Text = 'No drown',
    Default = false,
    Tooltip = 'Gives you infinite air capacity.',
})

MiscTab:AddToggle('UnlockAllBlueprints', {
    Text = 'Unlock All Blueprints',
    Default = false,
    Tooltip = 'Unlocks all blueprints for free.',
})

Toggles.UnlockAllBlueprints:OnChanged(function()
    if Toggles.UnlockAllBlueprints.Value == true then
        for i,v in pairs(game.ReplicatedStorage.Objects:GetChildren()) do
            if v:FindFirstChild("Configuration") and v.Configuration:FindFirstChild("Category") then
                GetBlueprint(v.Name)
            end
        end
    end
end)

Toggles.NoDrown:OnChanged(function()
    if Toggles.NoDrown.Value == true then
       LocalPlayer.PlayerGui.ClientScreenScript.Config.WaterPulseDamage.Capacity.Value = math.huge
    else
        LocalPlayer.PlayerGui.ClientScreenScript.Config.WaterPulseDamage.Capacity.Value = 100
    end
end)

local MoneyTab = Tabs.Main:AddRightGroupbox('Money Utilities')

MoneyTab:AddToggle('MoneyFullView', {
    Text = 'Accurate money value',
    Default = false,
    Tooltip = 'Displays your full money amount.',
})

LocalPlayer.Values.Saveable.Cash.Changed:Connect(function()
    if Toggles.MoneyFullView.Value == true then
        task.wait()
        LocalPlayer.PlayerGui.UserGui.Stats.Cash.Text = "$" .. LocalPlayer.Values.Saveable.Cash.Value
    end
end)

MoneyTab:AddToggle('IdleIncome', {
    Text = 'Idle Income',
    Default = false,
    Tooltip = 'Automatically dupes money. (SLOW)',
})

local AutofarmTab = Tabs.Automation:AddLeftGroupbox('Autofarms')

AutofarmTab:AddToggle('BoxAutoFarm', {
    Text = 'Box Delivery Autofarm',
    Default = false,
    Tooltip = 'Automatically delivers boxes for easy idle profit.',
})

Toggles.BoxAutoFarm:OnChanged(function()
    if Toggles.BoxAutoFarm.Value == true then
        TP(CFrame.new(InteractRemote.Parent.Position))
        wait(0.5)
    end
end)

AutofarmTab:AddToggle('OreAutoFarm', {
    Text = 'Auto Mine Ore',
    Default = false,
    Tooltip = 'Automatically mines chosen ore.',
})

Toggles.MineAura:OnChanged(function()
    if Toggles.OreAutoFarm.Value == true and Toggles.MineAura.Value == true then
        Toggles.OreAutoFarm:SetValue(false)
    end
end)

Toggles.OreAutoFarm:OnChanged(function()
    if Toggles.OreAutoFarm.Value == true and Toggles.MineAura.Value == true then
        Toggles.MineAura:SetValue(false)
    end
end)

-- < Generate Ore List. >

local OreList = {}
for i,v in pairs(game:GetService("ReplicatedStorage").Mineables:GetChildren()) do
    if v.Name ~= "NICELY_TILED_COPY_THIS_LOL" and v.Name ~= "Mythril" and v.Name ~= "Funny" and v:FindFirstChild("Stage1") and not v.Name:find("Tree") then
        table.insert(OreList,v.Name)  -- daz alot of conditionals cuh...
    end
end

AutofarmTab:AddDropdown('OreDropdown', {
    Values = OreList,
    Default = nil,
    Multi = false,
    Text = 'Target Ore',
    Tooltip = 'List of ores in the game (Automatically updated)',
})

local BlueprintFillerTab = Tabs.Building:AddLeftGroupbox('Blueprint Filler [adding soon™]')
Tabs.Stores:AddLeftGroupbox('Auto Buy [adding soon™]')

-- BlueprintFillerTab:AddButton("Fill all blueprints with material",function()
--     local bptbl = {}
--     local Myplot = nil

--     for i,v in pairs(game:GetService("Workspace").Plots:GetChildren()) do
--         if v.Owner and v.Owner.Value == LocalPlayer then
--             Myplot = v.Base
--         end
--     end

--     for i,v in pairs(Myplot:GetChildren()) do
--         if v:FindFirstChild("Blueprint") then
--             table.insert(bptbl,v)
--         end
--     end

--     print(#bptbl , "Blueprints unfilled.")

--     FillBlueprints(bptbl)
-- end)

-- BlueprintFillerTab:AddDropdown('BlueprintMaterial', {
--     Values = OreList,
--     Default = nil,
--     Multi = false,
--     Text = 'Fill Material',
--     Tooltip = 'List of ores in the game (Automatically updated)',
-- })

-- broken and i am LAZY to fix.

-- < Generate Ore List. />

-- < Configure UI (Create tabs, toggles, etc.) />


-- < Make sure 2 autofarms aren't enabled at once. >

Toggles.OreAutoFarm:OnChanged(function()
    if Toggles.BoxAutoFarm.Value == true and Toggles.OreAutoFarm.Value == true then
        Toggles.BoxAutoFarm:SetValue(false)
    end
end)

Toggles.BoxAutoFarm:OnChanged(function()
    if Toggles.BoxAutoFarm.Value == true and Toggles.OreAutoFarm.Value == true then
        Toggles.OreAutoFarm:SetValue(false)
    end
end)

-- < Make sure 2 autofarms aren't enabled at once. />

-- < Initialize and configure Linora addons. >

ThemeManager:SetLibrary(Library)

SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings() 

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' }) 

ThemeManager:SetFolder('Refinery_Caves')

SaveManager:SetFolder('Refinery_Caves/main')

SaveManager:BuildConfigSection(Tabs['UI Settings']) 

ThemeManager:ApplyToTab(Tabs['UI Settings'])

ThemeManager:ApplyTheme('Tokyo Night')

-- < Initialize and configure Linora addons. />

-- < Notify user everything has loaded. >

Library:Notify("All features loaded in " .. tostring(BetterRound(tick() - Startup,3)) .. " seconds.",3)
Library:Notify("Buy Arches Systems... it's just better.",7)

-- < Notify user everything has loaded. />

-- < Mouse spoofing (For mine aura.) >

local Mouse = LocalPlayer:GetMouse()
local oldIndex = nil 
oldIndex = hookmetamethod(game, "__index", function(self, Index)

    if self == Mouse and not checkcaller() and TargetPart and (Toggles.MineAura.Value == true or Toggles.OreAutoFarm.Value == true) then
        if Index == "Target" or Index == "target" then
            return TargetPart
        elseif Index == "Hit" or Index == "hit" then 
            return CFrame.new(TargetPart.Position)
        elseif Index == "X" or Index == "x" then 
            return oldIndex(self,"X")
        elseif Index == "Y" or Index == "y" then 
            return oldIndex(self,"Y")
        elseif Index == "UnitRay" then 
            return Ray.new(self.Origin, (self.Hit - self.Origin).Unit)
        end
    end

    return oldIndex(self, Index)
end)

-- < Mouse spoofing (For mine aura.) />
