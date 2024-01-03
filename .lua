for _, key in next, getgc(true) do
   local function updateKey(instanceType)
      if pcall(function() return rawget(key, instanceType) end) and typeof(rawget(key, instanceType)) == 'table' and (rawget(key, instanceType))[1] == 'kick' then
         key.tvk = {
            'kick',
            function()
               return game.Workspace:WaitForChild('')
            end
         }
      end
   end

   updateKey('indexInstance')
   updateKey('namecallInstance')
end

local Players, Client, Mouse, RS, Camera =
    game:GetService("Players"),
    game:GetService("Players").LocalPlayer,
    game:GetService("Players").LocalPlayer:GetMouse(),
    game:GetService("RunService"),
    game.Workspace.CurrentCamera

local Circle = Drawing.new("Circle")
Circle.Color = Color3.new(1, 1, 1)
Circle.Thickness = 1

local UpdateFOV = function()
    if not Circle then
        return Circle
    end
    Circle.Visible = Rasma.FOV["Visible"]
    Circle.Radius = Rasma.FOV["Radius"] * 3
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + (game:GetService("GuiService"):GetGuiInset().Y))
    return Circle
end

RS.Heartbeat:Connect(UpdateFOV)

local ClosestPlrFromMouse = function()
    local Target, Closest = nil, 1 / 0
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v ~= Client and v.Character:FindFirstChild("HumanoidRootPart") then
            local Position, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if Circle.Radius > Distance and Distance < Closest and OnScreen then
                Closest = Distance
                Target = v
            end
        end
    end
    return Target
end

local WTS = function(Object)
    local ObjectVector = Camera:WorldToScreenPoint(Object.Position)
    return Vector2.new(ObjectVector.X, ObjectVector.Y)
end

local IsOnScreen = function(Object)
    local IsOnScreen = Camera:WorldToScreenPoint(Object.Position)
    return IsOnScreen
end

local FilterObjs = function(Object)
    if string.find(Object.Name, "Gun") then
        return
    end
    if table.find({"Part", "MeshPart", "BasePart"}, Object.ClassName) then
        return true
    end
end

local GetClosestBodyPart = function(character)
    local ClosestDistance = 1 / 0
    local BodyPart = nil
    if character and character:GetChildren() then
        for _, x in next, character:GetChildren() do
            if FilterObjs(x) and IsOnScreen(x) then
                local Distance = (WTS(x) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if Circle.Radius > Distance and Distance < ClosestDistance then
                    ClosestDistance = Distance
                    BodyPart = x
                end
            end
        end
    end
    return BodyPart
end

local Prey

task.spawn(
    function()
        while task.wait() do
            if Prey then
                if Rasma.Silent.Enabled and Rasma.Silent.ClosestPoint == true then
                    Rasma.Silent["Part"] = tostring(GetClosestBodyPart(Prey.Character))
                end
            end
        end
    end
)

local grmt = getrawmetatable(game)
local backupindex = grmt.__index
setreadonly(grmt, false)

grmt.__index =
    newcclosure(
    function(self, v)
        if Rasma.Silent.Enabled and Mouse and tostring(v) == "Hit" then
            Prey = ClosestPlrFromMouse()
            if Prey then
                local endpoint =
                    game.Players[tostring(Prey)].Character[Rasma.Silent["Part"]].CFrame +
                    (game.Players[tostring(Prey)].Character[Rasma.Silent["Part"]].Velocity * Rasma.Silent.Prediction)
                return (tostring(v) == "Hit" and endpoint)
            end
        end
        return backupindex(self, v)
    end
)
