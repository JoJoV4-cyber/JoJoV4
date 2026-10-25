
--[[
    JOJOv4 | Blox Fruits Finder
    Auto Start + Auto Find
    Lista de frutas lendarias e miticas
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
if not player then
    warn("[JOJOv4] Jogador local indisponivel.")
    return
end

local CONFIG = {
    AutoScan = true,
    ScanInterval = 15,
    Notify = true,

    -- Nomes atuais e antigos para compatibilidade.
    FruitNames = {
        -- Lendarias
        "Quake",
        "Buddha",
        "Love",
        "Creation",
        "Spider",
        "Sound",
        "Phoenix",
        "Portal",
        "Lightning",
        "Rumble",
        "Pain",
        "Paw",
        "Blizzard",

        -- Miticas
        "Dragon",
        "Kitsune",
        "Yeti",
        "Leopard",
        "Tiger",
        "Gas",
        "Dough",
        "Spirit",
        "Soul",
        "Control",
        "Venom",
        "Shadow",
        "Gravity",
        "Mammoth",
        "T-Rex",
        "Magnet",
        "Meme"
    }
}

-- Remover interface anterior
local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("JOJOv4")

if oldGui then
    oldGui:Destroy()
end

local running = true
local scanning = false
local results = {}

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "JOJOv4"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(300, 245)
frame.Position = UDim2.new(0.5, -150, 0.25, 0)
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
status.Position = UDim2.fromOffset(10, 45)
status.Size = UDim2.new(1, -20, 0, 55)
status.BackgroundTransparency = 1
status.Text = "Iniciando busca automatica..."
status.TextColor3 = Color3.new(1, 1, 1)
status.TextWrapped = true
status.TextScaled = true
status.Parent = frame

local resultLabel = Instance.new("TextLabel")
resultLabel.Position = UDim2.fromOffset(10, 102)
resultLabel.Size = UDim2.new(1, -20, 0, 70)
resultLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
resultLabel.TextColor3 = Color3.new(1, 1, 1)
resultLabel.Text = "Aguardando resultados..."
resultLabel.TextWrapped = true
resultLabel.TextScaled = true
resultLabel.Parent = frame

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(10, y)
    button.Size = UDim2.new(1, -20, 0, 30)
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

local scanButton = makeButton("Procurar agora", 178)
local closeButton = makeButton("Fechar", 212)

local function notify(message)
    if not CONFIG.Notify then
        return
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "JOJOv4",
            Text = message,
            Duration = 3
        })
    end)
end

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    end

    if obj:IsA("Model") then
        local ok, pivot = pcall(function()
            return obj:GetPivot()
        end)

        if ok then
            return pivot.Position
        end
    end

    return nil
end

local function findCandidates()
    local found = {}
    local seen = {}

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not running then
            break
        end

        if obj:IsA("Model") or obj:IsA("BasePart") then
            local objectName = obj.Name:lower()

            for _, fruitName in ipairs(CONFIG.FruitNames) do
                if objectName:find(fruitName:lower(), 1, true) then
                    if not seen[obj] then
                        seen[obj] = true
                        table.insert(found, obj)
                    end
                    break
                end
            end
        end
    end

    return found
end

local function scan()
    if not running or scanning then
        return
    end

    scanning = true
    status.Text = "Procurando objetos candidatos..."

    local ok, data = pcall(findCandidates)

    if ok then
        results = data

        if #results == 0 then
            status.Text = "Busca concluida."
            resultLabel.Text = "Nenhum candidato encontrado."
        else
            local lines = {}

            for i, obj in ipairs(results) do
                if i > 4 then
                    break
                end

                local pos = getPosition(obj)

                if pos then
                    table.insert(lines, string.format(
                        "%s (%.0f, %.0f, %.0f)",
                        obj.Name, pos.X, pos.Y, pos.Z
                    ))
                else
                    table.insert(lines, obj.Name)
                end
            end

            status.Text = "Candidatos encontrados: " .. #results
            resultLabel.Text = table.concat(lines, "\n")
            notify("Candidatos encontrados: " .. #results)
        end
    else
        status.Text = "Erro na busca; tentando novamente."
        warn("[JOJOv4] Erro:", data)
    end

    scanning = false
end

scanButton.MouseButton1Click:Connect(function()
    task.spawn(scan)
end)

closeButton.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- Auto Start: comeca sem clicar
task.spawn(function()
    task.wait(1)

    while running and gui.Parent do
        scan()
        task.wait(CONFIG.ScanInterval)
    end
end)

print("[JOJOv4] Carregado. Busca automatica iniciada.")
