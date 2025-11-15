-- Roblox Executor Script: Multi-Save Pos / Teleport GUI with Logs (Wall/Barrier Bypass)
-- Supports up to 50 saved positions. Logs shows list with individual TP buttons.
-- Paste ENTIRE script into executor (Synapse X, Krnl, etc.).
-- Fully client-side, INSTANT CFrame teleport + fixes for walking glitches/slowdown.
-- Added "Clear Logs" button in Logs menu to clear all saved positions.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local savedPositions = {}  -- Table for up to 50 CFrames (index 1 = newest)

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

-- Main Frame (taller for 3 buttons)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 170)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

-- Save Pos Button
local saveButton = Instance.new("TextButton")
saveButton.Size = UDim2.new(1, -20, 0, 40)
saveButton.Position = UDim2.new(0, 10, 0, 10)
saveButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
saveButton.Text = "Save Pos"
saveButton.TextColor3 = Color3.fromRGB(255, 255, 255)
saveButton.TextScaled = true
saveButton.Font = Enum.Font.GothamBold
saveButton.Parent = mainFrame

local saveCorner = Instance.new("UICorner")
saveCorner.CornerRadius = UDim.new(0, 8)
saveCorner.Parent = saveButton

-- Teleport to Last Pos Button (teleports to newest saved pos)
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(1, -20, 0, 40)
tpButton.Position = UDim2.new(0, 10, 0, 60)
tpButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
tpButton.Text = "Teleport to Pos"
tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
tpButton.TextScaled = true
tpButton.Font = Enum.Font.GothamBold
tpButton.Parent = mainFrame

local tpCorner = Instance.new("UICorner")
tpCorner.CornerRadius = UDim.new(0, 8)
tpCorner.Parent = tpButton

-- Logs Button
local logsButton = Instance.new("TextButton")
logsButton.Size = UDim2.new(1, -20, 0, 40)
logsButton.Position = UDim2.new(0, 10, 0, 110)
logsButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
logsButton.Text = "Logs"
logsButton.TextColor3 = Color3.fromRGB(255, 255, 255)
logsButton.TextScaled = true
logsButton.Font = Enum.Font.GothamBold
logsButton.Parent = mainFrame

local logsBtnCorner = Instance.new("UICorner")
logsBtnCorner.CornerRadius = UDim.new(0, 8)
logsBtnCorner.Parent = logsButton

-- Logs Frame (popup to the right, slightly taller for clear button)
local logsFrame = Instance.new("Frame")
logsFrame.Size = UDim2.new(0, 320, 0, 470)
logsFrame.Position = UDim2.new(0, 220, 0, 10)
logsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
logsFrame.BorderSizePixel = 0
logsFrame.Visible = false
logsFrame.Parent = screenGui

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 10)
logsCorner.Parent = logsFrame

-- Top Bar for Logs (draggable)
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.Position = UDim2.new(0, 0, 0, 0)
topBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
topBar.Parent = logsFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = topBar

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Saved Positions (Max: 50)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = topBar

-- ScrollingFrame for logs
local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Size = UDim2.new(1, -10, 1, -90)
scrollingFrame.Position = UDim2.new(0, 5, 0, 45)
scrollingFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
scrollingFrame.BorderSizePixel = 0
scrollingFrame.ScrollBarThickness = 8
scrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
scrollingFrame.Parent = logsFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollingFrame

-- UIListLayout for scrolling entries
local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = scrollingFrame

-- Auto-canvas size update
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

-- Clear Logs Button (at bottom of logs frame)
local clearButton = Instance.new("TextButton")
clearButton.Size = UDim2.new(1, -20, 0, 35)
clearButton.Position = UDim2.new(0, 10, 1, -40)
clearButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
clearButton.Text = "Clear Logs"
clearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clearButton.TextScaled = true
clearButton.Font = Enum.Font.GothamBold
clearButton.Parent = logsFrame

local clearCorner = Instance.new("UICorner")
clearCorner.CornerRadius = UDim.new(0, 8)
clearCorner.Parent = clearButton

-- Function to get HRP
local function getHRP()
    return player.Character and player.Character:FindFirstChild("HumanoidRootPart")
end

-- Instant Teleport function (direct CFrame + anchor/velocity reset, no glitches/slowdown)
local function teleportTo(cframe)
    local hrp = getHRP()
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    if not hrp or not cframe then return end
    
    -- Anchor to prevent physics interference
    hrp.Anchored = true
    
    -- Instant set
    hrp.CFrame = cframe
    
    -- Reset velocity and humanoid state for normal movement
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait(0.01)  -- Tiny wait for state sync
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    
    -- Unanchor
    hrp.Anchored = false
end

-- Refresh logs function
local function refreshLogs()
    for _, child in pairs(scrollingFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name == "Entry" then
            child:Destroy()
        end
    end
    
    for i = 1, #savedPositions do
        local cframe = savedPositions[i]
        local pos = cframe.Position
        local posStr = string.format("[%.0f, %.0f, %.0f]", pos.X, pos.Y, pos.Z)
        
        local entryFrame = Instance.new("Frame")
        entryFrame.Name = "Entry"
        entryFrame.Size = UDim2.new(1, 0, 0, 35)
        entryFrame.BackgroundTransparency = 1
        entryFrame.LayoutOrder = i
        entryFrame.Parent = scrollingFrame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -65, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = "Pos #" .. i .. " " .. posStr
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = entryFrame
        
        local entryTpBtn = Instance.new("TextButton")
        entryTpBtn.Size = UDim2.new(0, 55, 1, 0)
        entryTpBtn.Position = UDim2.new(1, -60, 0, 0)
        entryTpBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
        entryTpBtn.Text = "TP"
        entryTpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        entryTpBtn.TextScaled = true
        entryTpBtn.Font = Enum.Font.GothamBold
        entryTpBtn.TextYAlignment = Enum.TextYAlignment.Center
        entryTpBtn.Parent = entryFrame
        
        local entryTpCorner = Instance.new("UICorner")
        entryTpCorner.CornerRadius = UDim.new(0, 5)
        entryTpCorner.Parent = entryTpBtn
        
        entryTpBtn.MouseButton1Click:Connect(function()
            teleportTo(cframe)
        end)
    end
end

-- Save Position (newest first, max 50)
saveButton.MouseButton1Click:Connect(function()
    local hrp = getHRP()
    if hrp then
        table.insert(savedPositions, 1, hrp.CFrame)
        if #savedPositions > 50 then
            table.remove(savedPositions)
        end
        saveButton.Text = "Saved! (" .. #savedPositions .. ")"
        task.wait(1.5)
        saveButton.Text = "Save Pos"
        if logsFrame.Visible then
            refreshLogs()
        end
    end
end)

-- Teleport to newest pos
tpButton.MouseButton1Click:Connect(function()
    if #savedPositions == 0 then return end
    tpButton.Text = "TPing..."
    teleportTo(savedPositions[1])
    task.wait(0.5)
    tpButton.Text = "Teleport to Pos"
end)

-- Toggle Logs
logsButton.MouseButton1Click:Connect(function()
    logsFrame.Visible = not logsFrame.Visible
    if logsFrame.Visible then
        refreshLogs()
    end
end)

-- Clear Logs
clearButton.MouseButton1Click:Connect(function()
    savedPositions = {}
    refreshLogs()
    clearButton.Text = "Cleared!"
    task.wait(1)
    clearButton.Text = "Clear Logs"
end)

-- Main Frame Draggable
local mainDragging, mainDragInput, mainDragStart, mainStartPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        mainDragging = true
        mainDragStart = input.Position
        mainStartPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                mainDragging = false
            end
        end)
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        mainDragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if mainDragging and mainDragInput then
        local delta = mainDragInput.Position - mainDragStart
        mainFrame.Position = UDim2.new(mainStartPos.X.Scale, mainStartPos.X.Offset + delta.X, mainStartPos.Y.Scale, mainStartPos.Y.Offset + delta.Y)
    end
end)

-- Logs TopBar Draggable
local logsDragging, logsDragInput, logsDragStart, logsStartPos
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        logsDragging = true
        logsDragStart = input.Position
        logsStartPos = logsFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                logsDragging = false
            end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        logsDragInput = input
    end
end)
RunService.RenderStepped:Connect(function()
    if logsDragging and logsDragInput then
        local delta = logsDragInput.Position - logsDragStart
        logsFrame.Position = UDim2.new(logsStartPos.X.Scale, logsStartPos.X.Offset + delta.X, logsStartPos.Y.Scale, logsStartPos.Y.Offset + delta.Y)
    end
end)

print("Multi-Save Teleport GUI loaded! (Max 50 positions, Logs menu with Clear button ready, Instant normal TP with glitch fixes)")
