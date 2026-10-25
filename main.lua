
--[[
    JOJOv4 - Fruit Finder
    Base de interface e detecção visual
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

_G.JOJOv4 = _G.JOJOv4 or {
    Notify = true,
    Mode = "Tween Fruit",
    AutoStore = false,
    AutoJoinTeam = false,
    Team = "Pirates",

    FruitList = {
        "Mammoth", "Buddha", "Dough",
        "Leopard", "Venom", "Dragon",
        "Gravity", "Rumble", "T-Rex",
        "Control", "Spirit", "Gas",
        "Shadow", "Kitsune"
    }
}

local config = _G.JOJOv4

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "JOJOv4"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(280, 220)
frame.Position = UDim2.new(0.5, -140, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(105, 65, 200)
title.Text = "JOJOv4 | FRUIT FINDER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 48)
status.Size = UDim2.new(1, -20, 0, 35)
status.BackgroundTransparency = 1
status.Text = "Pronto para procurar"
status.TextColor3 = Color3.new(1, 1, 1)
status.TextScaled = true
status.Parent = frame

local function createButton(text, y)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(10, y)
    button.Size = UDim2.new(1, -20, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(65, 55, 95)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = text
    button.TextScaled = true
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = button

    return button
end

local scanButton = createButton("Procurar frutas", 90)
local listButton = createButton("Mostrar lista de frutas", 132)
local closeButton = createButton("Fechar", 174)

-- Detecção básica de objetos com nomes configurados
local function findFruit()
    local found = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()

        for _, fruitName in ipairs(config.FruitList) do
            if name:find(fruitName:lower(), 1, true) then
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    table.insert(found, obj)
                    break
                end
            end
        end
    end

    return found
end

scanButton.MouseButton1Click:Connect(function()
    status.Text = "Procurando..."

    task.spawn(function()
        local fruits = findFruit()
        status.Text = "Encontradas: " .. #fruits

        if config.Notify then
            pcall(function()
                game:GetService("StarterGui"):SetCore(
                    "SendNotification",
                    {
                        Title = "JOJOv4",
                        Text = "Frutas detectadas: " .. #fruits,
                        Duration = 4
                    }
                )
            end)
        end
    end)
end)

listButton.MouseButton1Click:Connect(function()
    local fruits = findFruit()
    local names = {}

    for _, fruit in ipairs(fruits) do
        table.insert(names, fruit.Name)
    end

    status.Text = #names > 0
        and table.concat(names, ", "):sub(1, 80)
        or "Nenhuma fruta detectada"
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

print("JOJOv4 carregado!")
