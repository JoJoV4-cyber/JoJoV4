
--[[
    JOJOv4 - Fruit Finder
    Busca automatica e diagnostico de objetos
    Inicio automatico ao executar
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

    FruitNames = {
        "Mammoth", "Buddha", "Dough",
        "Leopard", "Venom", "Dragon",
        "Gravity", "Rumble", "T-Rex",
        "Control", "Spirit", "Gas",
        "Shadow", "Kitsune"
    }
}

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("JOJOv4")
if oldGui then
    oldGui:Destroy()
end

local running = true
local scanning = false
local autoScan = CONFIG.AutoScan
local results = {}

-- Interface
local gui = Instance.new("ScreenGui")
gui.Name = "JOJOv4"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(300, 270)
frame.Position = UDim2.new(0.5, -150, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(105, 65, 200)
title.Text = "JOJOv4 | FRUIT FINDER"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 48)
status.Size = UDim2.new(1, -20, 0, 42)
status.BackgroundTransparency = 1
status.Text = "Iniciando busca..."
status.TextColor3 = Color3.new(1, 1, 1)
status.TextScaled = true
status.Parent = frame

local resultsLabel = Instance.new("TextLabel")
resultsLabel.Position = UDim2.fromOffset(10, 92)
resultsLabel.Size = UDim2.new(1, -20, 0, 66)
resultsLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 52)
resultsLabel.TextColor3 = Color3.new(1, 1, 1)
resultsLabel.Text = "Aguardando resultados..."
resultsLabel.TextWrapped = true
resultsLabel.TextScaled = true
resultsLabel.Parent = frame

local function makeButton(label, y)
    local button = Instance.new("TextButton")
    button.Position = UDim2.fromOffset(10, y)
    button.Size = UDim2.new(1, -20, 0, 34)
    button.BackgroundColor3 = Color3.fromRGB(65, 55, 95)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = label
    button.TextScaled = true
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = button

    return button
end

local scanButton = makeButton("Procurar agora", 164)
local autoButton = makeButton("Auto Scan: LIGADO", 202)
local closeButton = makeButton("Fechar", 240)

local function notify(message)
    if not CONFIG.Notify then
        return
    end

    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "JOJOv4",
            Text = message,
            Duration = 4
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
            local name = obj.Name:lower()

            for _, fruitName in ipairs(CONFIG.FruitNames) do
                if name:find(fruitName:lower(), 1, true) then
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
    status.Text = "Procurando objetos..."

    local ok, data = pcall(findCandidates)

    if ok then
        results = data

        if #results == 0 then
            resultsLabel.Text = "Nenhum candidato encontrado."
            status.Text = "Busca concluida."
        else
            local lines = {}

            for i, obj in ipairs(results) do
                if i > 3 then
                    break
                end

                local pos = getPosition(obj)
                if pos then
                    table.insert(lines, string.format(
                        "%s: %.0f, %.0f, %.0f",
                        obj.Name, pos.X, pos.Y, pos.Z
                    ))
                else
                    table.insert(lines, obj.Name)
                end
            end

            resultsLabel.Text = table.concat(lines, "\n")
            status.Text = "Candidatos: " .. #results
            notify("Busca concluida: " .. #results ..
                " objeto(s) candidato(s)")
        end
    else
        status.Text = "Erro; nova tentativa depois."
        warn("[JOJOv4] Erro durante a busca:", data)
    end

    scanning = false
end

scanButton.MouseButton1Click:Connect(function()
    task.spawn(scan)
end)

autoButton.MouseButton1Click:Connect(function()
    autoScan = not autoScan
    autoButton.Text = autoScan
        and "Auto Scan: LIGADO"
        or "Auto Scan: DESLIGADO"

    status.Text = autoScan
        and "Busca automatica ativada."
        or "Busca automatica pausada."
end)

closeButton.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- Comeca sozinho, sem exigir clique
task.spawn(function()
    task.wait(1)

    while running and gui.Parent do
        if autoScan then
            local ok, err = pcall(scan)

            if not ok then
                warn("[JOJOv4] Falha inesperada:", err)
            end
        end

        task.wait(CONFIG.ScanInterval)
    end
end)

print("[JOJOv4] Carregado; busca automatica iniciada.")