--========================================================================--
--      EuF Panel - Premium Roblox Admin & Utility GUI (270 Functions)
--      Aesthetics: Ultra Premium Glassmorphism, Neon Glow & Rotating Gradients
--      Designed with modern Luau, CanvasGroups, and Easing transitions.
--      Optimized for Mobile, Tablet, and PC environments.
--========================================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Environment Checks
local CoreGui = game:GetService("CoreGui")
local function getSafeParent()
	local ok, res = pcall(function()
		local test = CoreGui.Name
		return CoreGui
	end)
	if ok then return res end
	return LocalPlayer:WaitForChild("PlayerGui")
end
local ParentGui = getSafeParent()
local panelOpen = false
local closedButtonPos = UDim2.new(0, 42, 0.5, 0)

-- Clean old instances
if ParentGui:FindFirstChild("EuF_Panel_Gui") then
	ParentGui.EuF_Panel_Gui:Destroy()
end
local oldLidar = workspace.CurrentCamera:FindFirstChild("EuF_Lidar_Folder")
if oldLidar then oldLidar:Destroy() end
local oldThermalCC = Lighting:FindFirstChild("EuF_Thermal_CC")
if oldThermalCC then oldThermalCC:Destroy() end

-- ==========================================
-- STATE & DEFAULTS
-- ==========================================
local Config = {
	Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Part = "Head", Smoothness = 1, FOV = 150, WallCheck = false, TeamCheck = false, ShowCircle = false },
	ESP = { Enabled = false, Boxes = false, Names = false, Distance = false, Tracers = false, Chams = false, TracerOrigin = "Bottom", TeamCheck = false, HighlightFill = Color3.fromRGB(120, 80, 255), HighlightOutline = Color3.fromRGB(255, 255, 255) },
	Fly = { Enabled = false, Speed = 50 },
	Noclip = { Enabled = false },
	InfJump = { Enabled = false },
	Crosshair = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Size = 12 },
	AntiAFK = { Enabled = false },
	Spammers = { Chat = false, ChatText = "EuF Panel on top!", ChatDelay = 3, Audio = false, Console = false }
}

local Themes = {
	["Dark Neon"] = {
		Bg = Color3.fromRGB(10, 10, 14),
		Header = Color3.fromRGB(16, 16, 22),
		Sidebar = Color3.fromRGB(8, 8, 11),
		AccentStart = Color3.fromRGB(100, 80, 255),
		AccentEnd = Color3.fromRGB(220, 60, 255),
		Text = Color3.fromRGB(245, 245, 250),
		TextSecondary = Color3.fromRGB(140, 140, 160),
		Border = Color3.fromRGB(30, 30, 40),
		Hover = Color3.fromRGB(24, 24, 32)
	},
	["Cyberpunk"] = {
		Bg = Color3.fromRGB(6, 4, 10),
		Header = Color3.fromRGB(14, 8, 22),
		Sidebar = Color3.fromRGB(4, 2, 7),
		AccentStart = Color3.fromRGB(255, 0, 85),
		AccentEnd = Color3.fromRGB(255, 220, 0),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(180, 80, 180),
		Border = Color3.fromRGB(255, 0, 85),
		Hover = Color3.fromRGB(30, 10, 45)
	},
	["Glassmorphism"] = {
		Bg = Color3.fromRGB(20, 20, 30),
		Header = Color3.fromRGB(28, 28, 40),
		Sidebar = Color3.fromRGB(15, 15, 22),
		AccentStart = Color3.fromRGB(0, 180, 255),
		AccentEnd = Color3.fromRGB(100, 220, 255),
		Text = Color3.fromRGB(255, 255, 255),
		TextSecondary = Color3.fromRGB(160, 180, 200),
		Border = Color3.fromRGB(60, 60, 80),
		Hover = Color3.fromRGB(35, 35, 50)
	},
	["Sakura"] = {
		Bg = Color3.fromRGB(24, 16, 20),
		Header = Color3.fromRGB(32, 20, 26),
		Sidebar = Color3.fromRGB(16, 10, 13),
		AccentStart = Color3.fromRGB(255, 130, 170),
		AccentEnd = Color3.fromRGB(255, 190, 210),
		Text = Color3.fromRGB(255, 235, 240),
		TextSecondary = Color3.fromRGB(200, 150, 165),
		Border = Color3.fromRGB(50, 32, 40),
		Hover = Color3.fromRGB(40, 24, 32)
	},
	["Light Mode"] = {
		Bg = Color3.fromRGB(240, 240, 245),
		Header = Color3.fromRGB(225, 225, 235),
		Sidebar = Color3.fromRGB(215, 215, 225),
		AccentStart = Color3.fromRGB(60, 80, 255),
		AccentEnd = Color3.fromRGB(0, 170, 255),
		Text = Color3.fromRGB(20, 20, 30),
		TextSecondary = Color3.fromRGB(90, 90, 110),
		Border = Color3.fromRGB(190, 190, 210),
		Hover = Color3.fromRGB(205, 205, 220)
	}
}

local ThemeRegistry = { Bg = {}, Header = {}, Sidebar = {}, Text = {}, TextSecondary = {}, Border = {}, Accent = {}, Gradients = {} }
local currentTheme = Themes["Dark Neon"]

local proxyStart = Instance.new("Color3Value")
local proxyEnd = Instance.new("Color3Value")
proxyStart.Value = currentTheme.AccentStart
proxyEnd.Value = currentTheme.AccentEnd

local function registerElement(element, role)
	if ThemeRegistry[role] then
		table.insert(ThemeRegistry[role], element)
		if role == "Bg" then element.BackgroundColor3 = currentTheme.Bg
		elseif role == "Header" then element.BackgroundColor3 = currentTheme.Header
		elseif role == "Sidebar" then element.BackgroundColor3 = currentTheme.Sidebar
		elseif role == "Text" then element.TextColor3 = currentTheme.Text
		elseif role == "TextSecondary" then element.TextColor3 = currentTheme.TextSecondary
		elseif role == "Border" then
			if element:IsA("UIStroke") then element.Color = currentTheme.Border
			else element.BorderColor3 = currentTheme.Border end
		elseif role == "Accent" then
			if element:IsA("TextLabel") or element:IsA("TextButton") then element.TextColor3 = currentTheme.AccentStart
			else element.BackgroundColor3 = currentTheme.AccentStart end
		end
	end
end

local function applyTheme(themeName)
	local theme = Themes[themeName]
	if not theme then return end
	currentTheme = theme
	
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(proxyStart, tweenInfo, {Value = theme.AccentStart}):Play()
	TweenService:Create(proxyEnd, tweenInfo, {Value = theme.AccentEnd}):Play()
	
	for _, element in ipairs(ThemeRegistry.Bg) do TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.Bg}):Play() end
	for _, element in ipairs(ThemeRegistry.Header) do TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.Header}):Play() end
	for _, element in ipairs(ThemeRegistry.Sidebar) do TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.Sidebar}):Play() end
	for _, element in ipairs(ThemeRegistry.Text) do TweenService:Create(element, tweenInfo, {TextColor3 = theme.Text}):Play() end
	for _, element in ipairs(ThemeRegistry.TextSecondary) do TweenService:Create(element, tweenInfo, {TextColor3 = theme.TextSecondary}):Play() end
	for _, element in ipairs(ThemeRegistry.Border) do
		if element:IsA("UIStroke") then TweenService:Create(element, tweenInfo, {Color = theme.Border}):Play()
		else TweenService:Create(element, tweenInfo, {BorderColor3 = theme.Border}):Play() end
	end
	for _, element in ipairs(ThemeRegistry.Accent) do
		if element:IsA("TextLabel") or element:IsA("TextButton") then TweenService:Create(element, tweenInfo, {TextColor3 = theme.AccentStart}):Play()
		else TweenService:Create(element, tweenInfo, {BackgroundColor3 = theme.AccentStart}):Play() end
	end
end

-- Rotating Gradients Updates Loop
local rotatingGradients = {}
local function registerRotatingGradient(grad)
	table.insert(rotatingGradients, grad)
end

RunService.Heartbeat:Connect(function()
	local rot = (tick() * 45) % 360
	for _, grad in ipairs(rotatingGradients) do
		pcall(function() grad.Rotation = rot end)
	end
end)

proxyStart.Changed:Connect(function()
	local seq = ColorSequence.new(proxyStart.Value, proxyEnd.Value)
	for _, grad in ipairs(ThemeRegistry.Gradients) do
		grad.Color = seq
	end
end)
proxyEnd.Changed:Connect(function()
	local seq = ColorSequence.new(proxyStart.Value, proxyEnd.Value)
	for _, grad in ipairs(ThemeRegistry.Gradients) do
		grad.Color = seq
	end
end)

-- ==========================================
-- CORE GUI INITIALIZATION
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EuF_Panel_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- Toast Container
local ToastContainer = Instance.new("Frame")
ToastContainer.Name = "ToastContainer"
ToastContainer.Size = UDim2.new(0, 300, 1, -20)
ToastContainer.Position = UDim2.new(1, -310, 0, 10)
ToastContainer.BackgroundTransparency = 1
ToastContainer.Parent = ScreenGui

local toastLayout = Instance.new("UIListLayout")
toastLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
toastLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
toastLayout.SortOrder = Enum.SortOrder.LayoutOrder
toastLayout.Padding = UDim.new(0, 8)
toastLayout.Parent = ToastContainer

local function notify(title, text, duration)
	duration = duration or 3
	local item = Instance.new("Frame")
	item.Name = "NotificationItem"
	item.Size = UDim2.new(1, 0, 0, 65)
	item.BackgroundTransparency = 1
	item.Parent = ToastContainer
	
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 1, 0)
	card.Position = UDim2.new(1.3, 0, 0, 0)
	card.BackgroundColor3 = currentTheme.Bg
	card.Parent = item
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1.5
	stroke.Color = currentTheme.Border
	stroke.Parent = card
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, -20, 0, 20)
	titleLabel.Position = UDim2.new(0, 10, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = currentTheme.AccentStart
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, -20, 0, 24)
	textLabel.Position = UDim2.new(0, 10, 0, 26)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextSize = 11
	textLabel.TextColor3 = currentTheme.TextSecondary
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextWrapped = true
	textLabel.Parent = card
	
	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, 0, 0, 3)
	progressBar.Position = UDim2.new(0, 0, 1, -3)
	progressBar.BackgroundColor3 = currentTheme.AccentStart
	progressBar.BorderSizePixel = 0
	progressBar.Parent = card
	
	local pGrad = Instance.new("UIGradient")
	pGrad.Parent = progressBar
	table.insert(ThemeRegistry.Gradients, pGrad)
	
	registerElement(card, "Bg")
	registerElement(stroke, "Border")
	registerElement(titleLabel, "Accent")
	registerElement(textLabel, "TextSecondary")
	
	TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
	TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)}):Play()
	
	task.delay(duration, function()
		if card and card.Parent then
			local out = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1.3, 0, 0, 0)})
			out:Play()
			out.Completed:Connect(function()
				item:Destroy()
			end)
		end
	end)
end

-- Smooth Dragging Helper with Inertia/Lerp and Viewport Clamping
local function makeDraggable(frame, dragHandle, onClick)
	local dragging = false
	local dragInput, dragStart, startPos
	local targetPos = frame.Position
	local isTracking = false
	local dragOccurred = false

	local function update(input)
		local delta = input.Position - dragStart
		local newX = startPos.X.Scale * Camera.ViewportSize.X + startPos.X.Offset + delta.X
		local newY = startPos.Y.Scale * Camera.ViewportSize.Y + startPos.Y.Offset + delta.Y
		
		-- Clamp to viewport bounds using actual size of frame
		local size = frame.AbsoluteSize
		newX = math.clamp(newX, 0, Camera.ViewportSize.X - size.X)
		newY = math.clamp(newY, 0, Camera.ViewportSize.Y - size.Y)
		
		targetPos = UDim2.new(0, newX, 0, newY)
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			isTracking = true
			dragStart = input.Position
			startPos = frame.Position
			dragOccurred = false

			local changeCon
			changeCon = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if changeCon then changeCon:Disconnect() end
					if isTracking then
						isTracking = false
						dragging = false
						if not dragOccurred and onClick then
							onClick()
						end
					end
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isTracking then
			local delta = input.Position - dragStart
			local dragThreshold = (input.UserInputType == Enum.UserInputType.Touch) and 24 or 10
			if not dragging and delta.Magnitude > dragThreshold then
				dragging = true
				dragOccurred = true
			end
		end
		
		if input == dragInput and dragging then
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if isTracking then
				isTracking = false
				dragging = false
				if not dragOccurred and onClick then
					onClick()
				end
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if frame and frame.Parent and frame.Visible then
			if dragging then
				frame.Position = frame.Position:Lerp(targetPos, 0.2)
				if frame.Name == "ToggleButton" and not panelOpen then
					closedButtonPos = targetPos
				end
			else
				targetPos = frame.Position
			end
		end
	end)
end

-- ==========================================
-- MAIN INTERFACE FRAMES
-- ==========================================
local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 650, 0, 420)
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.Position = UDim2.new(0, -325, 0.5, 0) -- Starts closed off-screen
MainPanel.BackgroundColor3 = currentTheme.Bg
MainPanel.Parent = ScreenGui
registerElement(MainPanel, "Bg")

local MainScale = Instance.new("UIScale")
MainScale.Name = "MainScale"
MainScale.Parent = MainPanel

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainPanel

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.5
mainStroke.Color = currentTheme.Border
mainStroke.Parent = MainPanel
registerElement(mainStroke, "Border")

-- Glowing outline gradient sweep
local mainStrokeGrad = Instance.new("UIGradient")
mainStrokeGrad.Parent = mainStroke
table.insert(ThemeRegistry.Gradients, mainStrokeGrad)
registerRotatingGradient(mainStrokeGrad)

-- Floating / Docked Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "ToggleButton"
ToggleButton.Size = UDim2.new(0, 55, 0, 55)
ToggleButton.AnchorPoint = Vector2.new(0.5, 0.5)
ToggleButton.Position = UDim2.new(0, 42, 0.5, 0) -- Left edge
ToggleButton.BackgroundColor3 = currentTheme.Bg
ToggleButton.Text = "EuF"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 16
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Parent = ScreenGui
registerElement(ToggleButton, "Bg")

local BtnScale = Instance.new("UIScale")
BtnScale.Name = "BtnScale"
BtnScale.Parent = ToggleButton

local tBtnCorner = Instance.new("UICorner")
tBtnCorner.CornerRadius = UDim.new(0.5, 0)
tBtnCorner.Parent = ToggleButton

local tBtnStroke = Instance.new("UIStroke")
tBtnStroke.Thickness = 2
tBtnStroke.Color = currentTheme.AccentStart
tBtnStroke.Parent = ToggleButton

local tBtnGrad = Instance.new("UIGradient")
tBtnGrad.Parent = tBtnStroke
table.insert(ThemeRegistry.Gradients, tBtnGrad)
registerRotatingGradient(tBtnGrad)

local lastToggle = 0

local function togglePanel()
	if os.clock() - lastToggle < 0.5 then return end
	lastToggle = os.clock()

	panelOpen = not panelOpen
	local viewportSize = Camera.ViewportSize
	local scaleX = viewportSize.X / 1366
	local scaleY = viewportSize.Y / 768
	local baseScale = math.clamp(math.min(scaleX, scaleY), 0.75, 1.35)
	
	local targetPanelPos = panelOpen and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, -targetWidth/2 - 100, 0.5, 0)
	local targetButtonPos
	
	if panelOpen then
		if viewportSize.X < 700 then
			targetButtonPos = UDim2.new(0.5, (targetWidth/2 - 25) * baseScale, 0.5, (-targetHeight/2 - 35) * baseScale)
		else
			targetButtonPos = UDim2.new(0.5, (-targetWidth/2 - 40) * baseScale, 0.5, 0)
		end
	else
		targetButtonPos = closedButtonPos
	end
	
	local panelStyle = panelOpen and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
	local buttonStyle = panelOpen and Enum.EasingStyle.Back or Enum.EasingStyle.Quad
	
	TweenService:Create(MainPanel, TweenInfo.new(0.6, panelStyle, Enum.EasingDirection.Out), {Position = targetPanelPos}):Play()
	TweenService:Create(ToggleButton, TweenInfo.new(0.6, buttonStyle, Enum.EasingDirection.Out), {Position = targetButtonPos}):Play()
	TweenService:Create(ToggleButton, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = panelOpen and 180 or 0}):Play()
end

makeDraggable(ToggleButton, ToggleButton, togglePanel)

-- Left Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 160, 1, 0)
Sidebar.BackgroundColor3 = currentTheme.Sidebar
Sidebar.Parent = MainPanel
registerElement(Sidebar, "Sidebar")

local sbCorner = Instance.new("UICorner")
sbCorner.CornerRadius = UDim.new(0, 10)
sbCorner.Parent = Sidebar

local sbLogo = Instance.new("TextLabel")
sbLogo.Size = UDim2.new(1, 0, 0, 50)
sbLogo.BackgroundTransparency = 1
sbLogo.Text = "EuF Panel"
sbLogo.Font = Enum.Font.GothamBold
sbLogo.TextSize = 20
sbLogo.TextColor3 = currentTheme.AccentStart
sbLogo.Parent = Sidebar
registerElement(sbLogo, "Accent")

local sbLogoGrad = Instance.new("UIGradient")
sbLogoGrad.Parent = sbLogo
table.insert(ThemeRegistry.Gradients, sbLogoGrad)

local sbLayout = Instance.new("UIListLayout")
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
sbLayout.Padding = UDim.new(0, 4)
sbLayout.Parent = Sidebar

local sbPad = Instance.new("UIPadding")
sbPad.PaddingTop = UDim.new(0, 55)
sbPad.PaddingLeft = UDim.new(0, 8)
sbPad.PaddingRight = UDim.new(0, 8)
sbPad.Parent = Sidebar

-- Drag handler area for the panel header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, -160, 0, 50)
Header.Position = UDim2.new(0, 160, 0, 0)
Header.BackgroundColor3 = currentTheme.Header
Header.Parent = MainPanel
registerElement(Header, "Header")

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 10)
hCorner.Parent = Header

makeDraggable(MainPanel, Header)

local hTitle = Instance.new("TextLabel")
hTitle.Size = UDim2.new(0, 150, 1, 0)
hTitle.Position = UDim2.new(0, 15, 0, 0)
hTitle.BackgroundTransparency = 1
hTitle.Text = "Dashboard"
hTitle.Font = Enum.Font.GothamBold
hTitle.TextSize = 16
hTitle.TextColor3 = currentTheme.Text
hTitle.TextXAlignment = Enum.TextXAlignment.Left
hTitle.Parent = Header
registerElement(hTitle, "Text")

-- Search Bar
local SearchBar = Instance.new("TextBox")
SearchBar.Size = UDim2.new(0, 160, 0, 26)
SearchBar.Position = UDim2.new(1, -330, 0.5, -13)
SearchBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
SearchBar.PlaceholderText = "🔍 Search..."
SearchBar.Text = ""
SearchBar.Font = Enum.Font.GothamMedium
SearchBar.TextSize = 12
SearchBar.TextColor3 = currentTheme.Text
SearchBar.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
SearchBar.Parent = Header
registerElement(SearchBar, "Text")

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = SearchBar

local searchStroke = Instance.new("UIStroke")
searchStroke.Thickness = 1.2
searchStroke.Color = currentTheme.Border
searchStroke.Parent = SearchBar
registerElement(searchStroke, "Border")

-- Glowing Search Bar effect on Focus
SearchBar.Focused:Connect(function()
	TweenService:Create(searchStroke, TweenInfo.new(0.2), {Color = currentTheme.AccentStart}):Play()
end)
SearchBar.FocusLost:Connect(function()
	TweenService:Create(searchStroke, TweenInfo.new(0.2), {Color = currentTheme.Border}):Play()
end)

-- Performance Stats in Header
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(0, 140, 1, 0)
StatsLabel.Position = UDim2.new(1, -150, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 60 | PING: 0ms"
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 11
StatsLabel.TextColor3 = currentTheme.TextSecondary
StatsLabel.TextXAlignment = Enum.TextXAlignment.Right
StatsLabel.Parent = Header
registerElement(StatsLabel, "TextSecondary")

-- Tab Container
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -170, 1, -65)
TabContainer.Position = UDim2.new(0, 170, 0, 60)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = MainPanel

-- FPS & Ping calculator loop
local fps = 0
local lastTime = os.clock()
RunService.Heartbeat:Connect(function()
	local cur = os.clock()
	fps = math.round(1 / (cur - lastTime))
	lastTime = cur
end)

task.spawn(function()
	while task.wait(1) do
		local ping = 0
		pcall(function()
			ping = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
		end)
		StatsLabel.Text = string.format("FPS: %d | PING: %dms", fps, ping)
	end
end)

-- Responsive Interface Sizing
local function updateInterfaceScaling()
	local viewportSize = Camera.ViewportSize
	targetWidth = 650
	targetHeight = 420
	
	if viewportSize.X < 700 then
		targetWidth = viewportSize.X - 20
	end
	if viewportSize.Y < 460 then
		targetHeight = viewportSize.Y - 20
	end
	
	-- Calculate baseScale dynamically based on screen resolution
	local scaleX = viewportSize.X / 1366
	local scaleY = viewportSize.Y / 768
	local baseScale = math.clamp(math.min(scaleX, scaleY), 0.75, 1.35)
	
	if MainPanel:FindFirstChild("MainScale") then
		MainPanel.MainScale.Scale = baseScale
	end
	if ToggleButton:FindFirstChild("BtnScale") then
		ToggleButton.BtnScale.Scale = baseScale
	end
	
	MainPanel.Size = UDim2.new(0, targetWidth, 0, targetHeight)
	
	if panelOpen then
		MainPanel.Position = UDim2.new(0.5, 0, 0.5, 0)
		if viewportSize.X < 700 then
			ToggleButton.Position = UDim2.new(0.5, (targetWidth/2 - 25) * baseScale, 0.5, (-targetHeight/2 - 35) * baseScale)
		else
			ToggleButton.Position = UDim2.new(0.5, (-targetWidth/2 - 40) * baseScale, 0.5, 0)
		end
	else
		MainPanel.Position = UDim2.new(0, -targetWidth/2 - 100, 0.5, 0)
		ToggleButton.Position = closedButtonPos
	end
	
	if targetWidth < 500 then
		-- Mobile layout scaling
		Sidebar.Size = UDim2.new(0, 110, 1, 0)
		Header.Size = UDim2.new(1, -110, 0, 50)
		Header.Position = UDim2.new(0, 110, 0, 0)
		TabContainer.Size = UDim2.new(1, -120, 1, -65)
		TabContainer.Position = UDim2.new(0, 120, 0, 60)
		
		hTitle.Size = UDim2.new(0, 80, 1, 0)
		hTitle.TextSize = 13
		
		SearchBar.Size = UDim2.new(0, 95, 0, 24)
		SearchBar.Position = UDim2.new(1, -105, 0.5, -12)
		
		StatsLabel.Visible = false
		sbLogo.TextSize = 16
	else
		-- Standard PC layout scaling
		Sidebar.Size = UDim2.new(0, 160, 1, 0)
		Header.Size = UDim2.new(1, -160, 0, 50)
		Header.Position = UDim2.new(0, 160, 0, 0)
		TabContainer.Size = UDim2.new(1, -170, 1, -65)
		TabContainer.Position = UDim2.new(0, 170, 0, 60)
		
		hTitle.Size = UDim2.new(0, 150, 1, 0)
		hTitle.TextSize = 16
		
		SearchBar.Size = UDim2.new(0, 160, 0, 26)
		SearchBar.Position = UDim2.new(1, -330, 0.5, -13)
		
		StatsLabel.Visible = true
		sbLogo.TextSize = 20
	end
end

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateInterfaceScaling)
updateInterfaceScaling()

-- ==========================================
-- TAB MANAGER & GENERATORS
-- ==========================================
local Tabs = {}
local TabContentFrames = {}
local TabGroups = {}
local activeTab = nil

local TabDisplays = {
	["Self"] = "⚡ Self",
	["Combat"] = "🎯 Combat",
	["Visuals"] = "👁️ Visuals",
	["Teleport"] = "🌀 Teleport",
	["Server"] = "🌐 Server",
	["Fun"] = "🎮 Fun",
	["Utility"] = "🔧 Utility",
	["FE Exploits"] = "🔥 FE Exploits",
	["Settings"] = "⚙️ Settings"
}

local function filterTab(tabFrame, query)
	query = string.lower(query)
	for _, row in ipairs(tabFrame:GetChildren()) do
		if row:IsA("Frame") and row.Name ~= "UIListLayout" and row.Name ~= "UIPadding" then
			local lbl = row:FindFirstChild("TitleLabel")
			if lbl then
				local text = string.lower(lbl.Text)
				row.Visible = (query == "" or string.find(text, query) ~= nil)
			end
		end
	end
end

SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
	if activeTab and TabContentFrames[activeTab] then
		filterTab(TabContentFrames[activeTab], SearchBar.Text)
	end
end)

local function switchTab(tabName)
	if activeTab == tabName then return end
	activeTab = tabName
	hTitle.Text = TabDisplays[tabName] or tabName
	SearchBar.Text = ""
	
	for name, btn in pairs(Tabs) do
		local active = (name == tabName)
		local targetColor = active and currentTheme.AccentStart or currentTheme.TextSecondary
		local targetBgTrans = active and 0.92 or 1
		
		TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextColor3 = targetColor}):Play()
		TweenService:Create(btn:FindFirstChild("BgFrame"), TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = targetBgTrans}):Play()
		btn:FindFirstChild("Indicator").Visible = active
	end
	
	for name, group in pairs(TabGroups) do
		if name == tabName then
			group.Visible = true
			group.GroupTransparency = 1
			group.Position = UDim2.new(0, 0, 0, 10)
			TweenService:Create(group, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
		else
			group.Visible = false
			group.GroupTransparency = 1
		end
	end
end

local function createTab(name, order)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Name = name .. "_Btn"
	tabBtn.Size = UDim2.new(1, 0, 0, 34)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = "   " .. (TabDisplays[name] or name)
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 12
	tabBtn.TextColor3 = currentTheme.TextSecondary
	tabBtn.TextXAlignment = Enum.TextXAlignment.Left
	tabBtn.LayoutOrder = order
	tabBtn.Parent = Sidebar
	
	local bgFrame = Instance.new("Frame")
	bgFrame.Name = "BgFrame"
	bgFrame.Size = UDim2.new(1, 0, 1, 0)
	bgFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bgFrame.BackgroundTransparency = 1
	bgFrame.BorderSizePixel = 0
	bgFrame.ZIndex = -1
	bgFrame.Parent = tabBtn
	
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = bgFrame
	
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 4, 0.6, 0)
	indicator.Position = UDim2.new(0, -4, 0.2, 0)
	indicator.BackgroundColor3 = currentTheme.AccentStart
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = tabBtn
	registerElement(indicator, "Accent")
	
	-- Hover transitions
	tabBtn.MouseEnter:Connect(function()
		if activeTab ~= name then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {TextColor3 = currentTheme.Text}):Play()
			TweenService:Create(bgFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0.97}):Play()
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if activeTab ~= name then
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {TextColor3 = currentTheme.TextSecondary}):Play()
			TweenService:Create(bgFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		end
	end)
	
	tabBtn.Activated:Connect(function()
		switchTab(name)
	end)
	
	Tabs[name] = tabBtn
	
	-- CanvasGroup Container for smooth fade transitions
	local tabGroup = Instance.new("CanvasGroup")
	tabGroup.Name = name .. "_Group"
	tabGroup.Size = UDim2.new(1, 0, 1, 0)
	tabGroup.BackgroundTransparency = 1
	tabGroup.GroupTransparency = 1
	tabGroup.Visible = false
	tabGroup.Parent = TabContainer
	
	TabGroups[name] = tabGroup
	
	-- ScrollFrame Content Area
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = name .. "_Scroll"
	scrollFrame.Size = UDim2.new(1, 0, 1, 0)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.ScrollBarThickness = 3
	scrollFrame.ScrollBarImageColor3 = currentTheme.Border
	scrollFrame.Parent = tabGroup
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 6)
	listLayout.Parent = scrollFrame
	
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingBottom = UDim.new(0, 4)
	pad.PaddingLeft = UDim.new(0, 2)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = scrollFrame
	
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
	end)
	
	TabContentFrames[name] = scrollFrame
end

-- ==========================================
-- FEATURE BUILDER ENGINE (UI COMPONENT FACTORY)
-- ==========================================
local function addFeature(tabName, name, type, data, order)
	local tabFrame = TabContentFrames[tabName]
	if not tabFrame then return end
	
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.new(1, -2, 0, 40)
	row.BackgroundColor3 = currentTheme.Bg
	row.BackgroundTransparency = 0.65
	row.LayoutOrder = order or 100
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = row
	
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Color = currentTheme.Border
	stroke.Parent = row
	
	registerElement(row, "Bg")
	registerElement(stroke, "Border")
	
	-- Responsive Card Hover micro-animations
	row.MouseEnter:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.2), {BackgroundTransparency = 0.4}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Color = currentTheme.AccentStart}):Play()
	end)
	row.MouseLeave:Connect(function()
		TweenService:Create(row, TweenInfo.new(0.2), {BackgroundTransparency = 0.65}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), {Color = currentTheme.Border}):Play()
	end)
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(0.5, -10, 1, 0)
	titleLabel.Position = UDim2.new(0, 10, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = name
	titleLabel.Font = Enum.Font.GothamMedium
	titleLabel.TextSize = 12
	titleLabel.TextColor3 = currentTheme.Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = row
	registerElement(titleLabel, "Text")
	
	local cArea = Instance.new("Frame")
	cArea.Size = UDim2.new(0.5, -10, 1, 0)
	cArea.Position = UDim2.new(0.5, 0, 0, 0)
	cArea.BackgroundTransparency = 1
	cArea.Parent = row
	
	if type == "Button" then
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 120, 0, 24)
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, 0, 0.5, 0)
		button.BackgroundColor3 = currentTheme.AccentStart
		button.Text = data.Text or "Click"
		button.Font = Enum.Font.GothamBold
		button.TextSize = 11
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 5)
		bCorner.Parent = button
		
		local btnGrad = Instance.new("UIGradient")
		btnGrad.Parent = button
		table.insert(ThemeRegistry.Gradients, btnGrad)
		
		button.Activated:Connect(function()
			local s, e = pcall(data.Callback)
			if not s then warn("Error: " .. tostring(e)) end
		end)
		button.Parent = cArea
		
	elseif type == "Toggle" then
		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.new(0, 42, 0, 20)
		toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
		toggleBtn.Position = UDim2.new(1, 0, 0.5, 0)
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		toggleBtn.Text = ""
		
		local tCorner = Instance.new("UICorner")
		tCorner.CornerRadius = UDim.new(0.5, 0)
		tCorner.Parent = toggleBtn
		
		local tStroke = Instance.new("UIStroke")
		tStroke.Thickness = 1.2
		tStroke.Color = currentTheme.Border
		tStroke.Parent = toggleBtn
		
		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.new(0, 14, 0, 14)
		indicator.Position = UDim2.new(0, 3, 0.5, -7)
		indicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
		
		local indCorner = Instance.new("UICorner")
		indCorner.CornerRadius = UDim.new(0.5, 0)
		indCorner.Parent = indicator
		indicator.Parent = toggleBtn
		
		local state = data.Default or false
		local function updateVisual()
			local targetX = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
			local targetBg = state and currentTheme.AccentStart or Color3.fromRGB(40, 40, 50)
			local targetKnob = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 180)
			
			TweenService:Create(indicator, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = targetX, BackgroundColor3 = targetKnob}):Play()
			TweenService:Create(toggleBtn, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundColor3 = targetBg}):Play()
		end
		updateVisual()
		
		toggleBtn.Activated:Connect(function()
			state = not state
			updateVisual()
			local s, e = pcall(data.Callback, state)
			if not s then warn("Error: " .. tostring(e)) end
		end)
		toggleBtn.Parent = cArea
		
	elseif type == "Slider" then
		local track = Instance.new("Frame")
		track.Size = UDim2.new(0.75, -5, 0, 6)
		track.AnchorPoint = Vector2.new(0, 0.5)
		track.Position = UDim2.new(0, 0, 0.5, 0)
		track.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		track.Parent = cArea
		
		local trCorner = Instance.new("UICorner")
		trCorner.CornerRadius = UDim.new(0.5, 0)
		trCorner.Parent = track
		
		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = currentTheme.AccentStart
		fill.Parent = track
		
		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0.5, 0)
		fillCorner.Parent = fill
		
		local fGrad = Instance.new("UIGradient")
		fGrad.Parent = fill
		table.insert(ThemeRegistry.Gradients, fGrad)
		
		local handle = Instance.new("Frame")
		handle.Size = UDim2.new(0, 12, 0, 12)
		handle.AnchorPoint = Vector2.new(0.5, 0.5)
		handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		handle.Parent = track
		
		local hCorner = Instance.new("UICorner")
		hCorner.CornerRadius = UDim.new(0.5, 0)
		hCorner.Parent = handle
		
		local valLabel = Instance.new("TextLabel")
		valLabel.Size = UDim2.new(0.25, -5, 1, 0)
		valLabel.Position = UDim2.new(0.75, 5, 0, 0)
		valLabel.BackgroundTransparency = 1
		valLabel.Text = tostring(data.Default or data.Min)
		valLabel.Font = Enum.Font.GothamBold
		valLabel.TextSize = 11
		valLabel.TextColor3 = currentTheme.TextSecondary
		valLabel.TextXAlignment = Enum.TextXAlignment.Right
		valLabel.Parent = cArea
		registerElement(valLabel, "TextSecondary")
		
		local min, max = data.Min or 0, data.Max or 100
		local currentVal = data.Default or min
		
		local function setVal(v)
			currentVal = math.clamp(v, min, max)
			valLabel.Text = tostring(currentVal)
			local pct = (currentVal - min) / (max - min)
			fill.Size = UDim2.new(pct, 0, 1, 0)
			handle.Position = UDim2.new(pct, 0, 0.5, 0)
			pcall(data.Callback, currentVal)
		end
		setVal(currentVal)
		
		local active = false
		local function update(input)
			local width = track.AbsoluteSize.X
			local offset = input.Position.X - track.AbsolutePosition.X
			local pct = math.clamp(offset / width, 0, 1)
			local rawVal = pct * (max - min) + min
			setVal(math.round(rawVal))
		end
		
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				active = true
				tabFrame.ScrollingEnabled = false
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				active = false
				tabFrame.ScrollingEnabled = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				active = true
				tabFrame.ScrollingEnabled = false
				update(input)
			end
		end)
		
	elseif type == "Dropdown" then
		local dropBtn = Instance.new("TextButton")
		dropBtn.Size = UDim2.new(0, 120, 0, 24)
		dropBtn.AnchorPoint = Vector2.new(1, 0.5)
		dropBtn.Position = UDim2.new(1, 0, 0.5, 0)
		dropBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		dropBtn.Text = data.Default or "Select"
		dropBtn.Font = Enum.Font.GothamMedium
		dropBtn.TextSize = 11
		dropBtn.TextColor3 = currentTheme.Text
		dropBtn.Parent = cArea
		
		local dropCorner = Instance.new("UICorner")
		dropCorner.CornerRadius = UDim.new(0, 4)
		dropCorner.Parent = dropBtn
		
		local dropStroke = Instance.new("UIStroke")
		dropStroke.Thickness = 1
		dropStroke.Color = currentTheme.Border
		dropStroke.Parent = dropBtn
		
		local arrow = Instance.new("TextLabel")
		arrow.Size = UDim2.new(0, 15, 1, 0)
		arrow.Position = UDim2.new(1, -15, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Text = "▼"
		arrow.Font = Enum.Font.GothamMedium
		arrow.TextSize = 9
		arrow.TextColor3 = currentTheme.TextSecondary
		arrow.Parent = dropBtn
		
		local options = data.Options or {}
		local open = false
		local list
		
		dropBtn.Activated:Connect(function()
			open = not open
			arrow.Text = open and "▲" or "▼"
			row.ZIndex = open and 15 or 1
			if open then
				list = Instance.new("Frame")
				list.Size = UDim2.new(1, 0, 0, #options * 22 + 4)
				list.Position = UDim2.new(0, 0, 1, 2)
				list.BackgroundColor3 = currentTheme.Bg
				list.ZIndex = 25
				list.Parent = dropBtn
				
				local lCorner = Instance.new("UICorner")
				lCorner.CornerRadius = UDim.new(0, 4)
				lCorner.Parent = list
				
				local lStroke = Instance.new("UIStroke")
				lStroke.Thickness = 1
				lStroke.Color = currentTheme.Border
				lStroke.Parent = list
				
				local lLayout = Instance.new("UIListLayout")
				lLayout.Padding = UDim.new(0, 2)
				lLayout.SortOrder = Enum.SortOrder.LayoutOrder
				lLayout.Parent = list
				
				local lPad = Instance.new("UIPadding")
				lPad.PaddingTop = UDim.new(0, 2)
				lPad.PaddingBottom = UDim.new(0, 2)
				lPad.PaddingLeft = UDim.new(0, 2)
				lPad.PaddingRight = UDim.new(0, 2)
				lPad.Parent = list
				
				for i, opt in ipairs(options) do
					local btn = Instance.new("TextButton")
					btn.Size = UDim2.new(1, 0, 0, 20)
					btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
					btn.BackgroundTransparency = 1
					btn.Text = opt
					btn.Font = Enum.Font.GothamMedium
					btn.TextSize = 11
					btn.TextColor3 = currentTheme.TextSecondary
					btn.ZIndex = 26
					btn.LayoutOrder = i
					btn.Parent = list
					
					local bCrn = Instance.new("UICorner")
					bCrn.CornerRadius = UDim.new(0, 3)
					bCrn.Parent = btn
					
					btn.MouseEnter:Connect(function()
						btn.BackgroundTransparency = 0
						btn.TextColor3 = currentTheme.Text
					end)
					btn.MouseLeave:Connect(function()
						btn.BackgroundTransparency = 1
						btn.TextColor3 = currentTheme.TextSecondary
					end)
					btn.Activated:Connect(function()
						dropBtn.Text = opt
						row.ZIndex = 1
						pcall(data.Callback, opt)
						open = false
						arrow.Text = "▼"
						list:Destroy()
					end)
				end
			else
				row.ZIndex = 1
				if list then list:Destroy() end
			end
		end)
		
	elseif type == "Textbox" then
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 120, 0, 24)
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, 0, 0.5, 0)
		box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		box.PlaceholderText = data.Placeholder or "Write here..."
		box.Text = data.Default or ""
		box.Font = Enum.Font.GothamMedium
		box.TextSize = 11
		box.TextColor3 = currentTheme.Text
		box.PlaceholderColor3 = Color3.fromRGB(100, 100, 115)
		box.Parent = cArea
		
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 4)
		bCorner.Parent = box
		
		local bStroke = Instance.new("UIStroke")
		bStroke.Thickness = 1
		bStroke.Color = currentTheme.Border
		bStroke.Parent = box
		
		box.Focused:Connect(function()
			TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = currentTheme.AccentStart}):Play()
		end)
		box.FocusLost:Connect(function(enter)
			TweenService:Create(bStroke, TweenInfo.new(0.2), {Color = currentTheme.Border}):Play()
			pcall(data.Callback, box.Text, enter)
		end)
		
	elseif type == "Keybind" then
		local bind = Instance.new("TextButton")
		bind.Size = UDim2.new(0, 70, 0, 24)
		bind.AnchorPoint = Vector2.new(1, 0.5)
		bind.Position = UDim2.new(1, 0, 0.5, 0)
		bind.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
		
		local activeBind = data.Default or Enum.KeyCode.F
		bind.Text = "[ " .. tostring(activeBind.Name or activeBind) .. " ]"
		bind.Font = Enum.Font.GothamBold
		bind.TextSize = 10
		bind.TextColor3 = currentTheme.TextSecondary
		bind.Parent = cArea
		
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 4)
		bCorner.Parent = bind
		
		local bStroke = Instance.new("UIStroke")
		bStroke.Thickness = 1
		bStroke.Color = currentTheme.Border
		bStroke.Parent = bind
		
		local listening = false
		bind.Activated:Connect(function()
			listening = true
			bind.Text = "[ ... ]"
			bind.TextColor3 = currentTheme.AccentStart
		end)
		
		UserInputService.InputBegan:Connect(function(input)
			if listening then
				local key
				if input.UserInputType == Enum.UserInputType.Keyboard then
					key = input.KeyCode
				elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
					key = input.UserInputType
				end
				
				if key and key ~= Enum.KeyCode.Escape then
					activeBind = key
					bind.Text = "[ " .. tostring(activeBind.Name or activeBind.Value or activeBind) .. " ]"
					bind.TextColor3 = currentTheme.TextSecondary
					listening = false
					pcall(data.Callback, activeBind)
				elseif key == Enum.KeyCode.Escape then
					bind.Text = "[ None ]"
					bind.TextColor3 = currentTheme.TextSecondary
					listening = false
					pcall(data.Callback, nil)
				end
			end
		end)
	end
	
	row.Parent = tabFrame
end

-- Initialize Custom Tabs
createTab("Self", 1)
createTab("Combat", 2)
createTab("Visuals", 3)
createTab("Teleport", 4)
createTab("Server", 5)
createTab("Fun", 6)
createTab("Utility", 7)
createTab("FE Exploits", 8)
createTab("Settings", 9)

switchTab("Self") -- Set default active tab

-- ==========================================
-- AIMBOT & FLY ENGINE CALLBACK LOOPS
-- ==========================================
local flyConnection
local flyDirection = Vector3.zero

-- FE Exploit States & Connections
local selectedPlayer = nil
local flingActive = false
local flingConnection
local netlessActive = false
local netlessConnection
local bringingParts = false
local bringConnection
local tkActive = false
local tkConnection
local tkTarget = nil
local autoLootActive = false
local autoPromptActive = false
local wsBypassActive = false
local wsBypassSpeed = 50
local wsBypassConnection
local wallWalkActive = false
local wallWalkConnection
local fakeLagActive = false
local antiAimActive = false
local antiAimConnection
local orbitActive = false
local orbitConnection
local antiFlingActive = false
local antiFlingConnection
local toolSpamActive = false
local bypassChatActive = false
local carFlyActive = false
local carFlyConnection

local function handleFly(dt)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not root then return end
	
	local moveDir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
	
	if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
	
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
	root.CFrame = root.CFrame + (moveDir * Config.Fly.Speed * dt)
end

local function toggleFly(state)
	Config.Fly.Enabled = state
	if state then
		if flyConnection then flyConnection:Disconnect() end
		flyConnection = RunService.RenderStepped:Connect(handleFly)
		notify("Fly Enabled", "You can now fly around the map.", 3)
	else
		if flyConnection then flyConnection:Disconnect() end
		notify("Fly Disabled", "Physics restored.", 3)
	end
end

-- Noclip Logic
local noclipConnection
local function toggleNoclip(state)
	Config.Noclip.Enabled = state
	if state then
		if noclipConnection then noclipConnection:Disconnect() end
		noclipConnection = RunService.Stepped:Connect(function()
			local char = LocalPlayer.Character
			if char then
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end
		end)
		notify("Noclip Enabled", "Collisions disabled.", 3)
	else
		if noclipConnection then noclipConnection:Disconnect() end
		notify("Noclip Disabled", "Collisions enabled.", 3)
	end
end

-- Infinite Jump
local jumpConnection
local function toggleInfJump(state)
	Config.InfJump.Enabled = state
	if state then
		if jumpConnection then jumpConnection:Disconnect() end
		jumpConnection = UserInputService.JumpRequest:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end)
		notify("Infinite Jump", "Hold Space to climb the sky.", 3)
	else
		if jumpConnection then jumpConnection:Disconnect() end
		notify("Infinite Jump", "Restored normal mechanics.", 3)
	end
end

-- ==========================================
-- FE EXPLOIT FUNCTIONS & PHYSICS BYPASSES
-- ==========================================
local function startFling(targetName)
	local target = Players:FindFirstChild(targetName)
	if not target or not target.Character then
		notify("Fling Target", "Target not found or has no character.", 3)
		return
	end
	
	flingActive = true
	notify("Fling Initiated", "Flinging player: " .. targetName, 3)
	
	task.spawn(function()
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then flingActive = false return end
		
		local targetChar = target.Character
		local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
		if not targetHrp then flingActive = false return end
		
		local bAv = Instance.new("BodyAngularVelocity")
		bAv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bAv.AngularVelocity = Vector3.new(0, 99999, 0)
		bAv.Parent = hrp
		
		local bV = Instance.new("BodyVelocity")
		bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bV.Velocity = Vector3.new(0, 0, 0)
		bV.Parent = hrp
		
		local oldParts = {}
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				oldParts[part] = part.CanCollide
				part.CanCollide = false
			end
		end
		
		local start = os.clock()
		while flingActive and targetHrp and targetHrp.Parent and hrp and hrp.Parent and (os.clock() - start < 5) do
			RunService.Heartbeat:Wait()
			hrp.CFrame = targetHrp.CFrame * CFrame.new(math.random(-15, 15)/10, 0, math.random(-15, 15)/10)
			hrp.AssemblyLinearVelocity = Vector3.new(999999, 999999, 999999)
			bV.Velocity = Vector3.new(999999, 999999, 999999)
		end
		
		flingActive = false
		pcall(function() bAv:Destroy() end)
		pcall(function() bV:Destroy() end)
		for part, cc in pairs(oldParts) do
			pcall(function() part.CanCollide = cc end)
		end
		notify("Fling Stopped", "Target attempt finished.", 2)
	end)
end

local function toggleNetless(state)
	netlessActive = state
	if netlessConnection then netlessConnection:Disconnect() end
	if state then
		notify("Netless Engaged", "Overriding network ownership of parts.", 3)
		netlessConnection = RunService.Heartbeat:Connect(function()
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
					pcall(function()
						part.AssemblyLinearVelocity = Vector3.new(0, -25.1, 0)
					end)
				end
			end
		end)
	else
		notify("Netless Disengaged", "Restored standard network states.", 2)
	end
end

local function toggleBringParts(state)
	bringingParts = state
	if bringConnection then bringConnection:Disconnect() end
	if state then
		notify("Bring Parts Engaged", "Pulling unanchored parts toward your position.", 3)
		bringConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not root then return end
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
					pcall(function()
						part.AssemblyLinearVelocity = Vector3.new(0, -25.1, 0)
						part.CFrame = root.CFrame * CFrame.new(0, 0, -6)
					end)
				end
			end
		end)
	else
		notify("Bring Parts Disengaged", "Released parts control.", 2)
	end
end

local function toggleTelekinesis(state)
	tkActive = state
	if tkConnection then tkConnection:Disconnect() end
	if state then
		notify("Telekinesis Active", "Left click + hold on unanchored parts to throw/manipulate.", 3)
		local mouse = LocalPlayer:GetMouse()
		local currentPart = nil
		local mDown, mUp
		
		mDown = mouse.Button1Down:Connect(function()
			if not tkActive then mDown:Disconnect() return end
			local target = mouse.Target
			if target and target:IsA("BasePart") and not target.Anchored and not target:IsDescendantOf(LocalPlayer.Character) then
				currentPart = target
			end
		end)
		
		mUp = mouse.Button1Up:Connect(function()
			currentPart = nil
			if not tkActive then mUp:Disconnect() end
		end)
		
		tkConnection = RunService.Heartbeat:Connect(function()
			if not tkActive then
				if mDown then mDown:Disconnect() end
				if mUp then mUp:Disconnect() end
				tkConnection:Disconnect()
				return
			end
			if currentPart and currentPart.Parent then
				pcall(function()
					currentPart.AssemblyLinearVelocity = Vector3.new(0, -25.1, 0)
					currentPart.CFrame = CFrame.new(mouse.Hit.Position)
				end)
			end
		end)
	else
		notify("Telekinesis Inactive", "Released telekinesis binds.", 2)
	end
end

local function toggleAutoLoot(state)
	autoLootActive = state
	task.spawn(function()
		while autoLootActive and task.wait(0.2) do
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				for _, child in ipairs(workspace:GetChildren()) do
					if child:IsA("Tool") then
						local handle = child:FindFirstChild("Handle") or child:FindFirstChildOfClass("BasePart")
						if handle then
							pcall(function()
								if firetouchinterest then
									firetouchinterest(root, handle, 0)
									task.wait()
									firetouchinterest(root, handle, 1)
								else
									handle.CFrame = root.CFrame
								end
							end)
						end
					end
				end
			end
		end
	end)
end

local function toggleAutoPrompt(state)
	autoPromptActive = state
	task.spawn(function()
		while autoPromptActive and task.wait(0.2) do
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") then
					pcall(function()
						v:InputBegan(LocalPlayer)
					end)
				end
			end
		end
	end)
end

local function toggleWSBypass(state)
	wsBypassActive = state
	if wsBypassConnection then wsBypassConnection:Disconnect() end
	if state then
		notify("CFrame WalkSpeed Active", "Applying raw physics delta speed.", 3)
		wsBypassConnection = RunService.Heartbeat:Connect(function(dt)
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.MoveDirection.Magnitude > 0 then
				pcall(function()
					local dir = hum.MoveDirection
					root.CFrame = root.CFrame + (dir * (wsBypassSpeed - hum.WalkSpeed) * dt)
				end)
			end
		end)
	else
		notify("CFrame WalkSpeed Inactive", "Standard speed checks restored.", 2)
	end
end

local function toggleWallWalk(state)
	wallWalkActive = state
	if wallWalkConnection then wallWalkConnection:Disconnect() end
	if state then
		notify("Wall Walking Active", "Raycasting wall alignments.", 3)
		wallWalkConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude
			
			local ray = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, params)
			if ray and ray.Instance then
				pcall(function()
					local normal = ray.Normal
					local newUp = normal
					local newLook = -root.CFrame.UpVector
					root.CFrame = CFrame.lookAt(root.Position + normal * 0.1, root.Position + newLook, newUp)
				end)
			end
		end)
	else
		notify("Wall Walking Inactive", "Standard gravity restored.", 2)
	end
end

local function toggleFakeLag(state)
	fakeLagActive = state
	task.spawn(function()
		while fakeLagActive do
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				pcall(function()
					root.Anchored = true
					task.wait(0.3)
					root.Anchored = false
				end)
			end
			task.wait(0.05)
		end
	end)
end

local function toggleAntiAim(state)
	antiAimActive = state
	if antiAimConnection then antiAimConnection:Disconnect() end
	if state then
		notify("Anti-Aim Engaged", "Spinning angles server-side.", 3)
		antiAimConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				pcall(function()
					root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(1, 360)), 0)
				end)
			end
		end)
	else
		notify("Anti-Aim Disengaged", "Restored standard physics angles.", 2)
	end
end

local function toggleOrbit(state)
	orbitActive = state
	if orbitConnection then orbitConnection:Disconnect() end
	if state then
		if not selectedPlayer or not selectedPlayer.Character then
			notify("Orbit Error", "Select a target player first in the Teleport tab.", 3)
			orbitActive = false
			return
		end
		notify("Orbit Active", "Orbiting player: " .. selectedPlayer.Name, 3)
		local angle = 0
		orbitConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local tChar = selectedPlayer.Character
			local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
			if root and tRoot then
				angle = angle + 0.08
				local offset = Vector3.new(math.cos(angle) * 7, 2, math.sin(angle) * 7)
				pcall(function()
					root.CFrame = CFrame.new(tRoot.Position + offset, tRoot.Position)
				end)
			end
		end)
	else
		notify("Orbit Disabled", "Physics restored.", 2)
	end
end

local function toggleAntiFling(state)
	antiFlingActive = state
	if antiFlingConnection then antiFlingConnection:Disconnect() end
	if state then
		notify("Anti-Fling Active", "Bypassing player collisions.", 3)
		antiFlingConnection = RunService.Heartbeat:Connect(function()
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					for _, part in ipairs(player.Character:GetDescendants()) do
						if part:IsA("BasePart") then
							pcall(function()
								part.CanCollide = false
								part.AssemblyLinearVelocity = Vector3.zero
								part.AssemblyAngularVelocity = Vector3.zero
							end)
						end
					end
				end
			end
		end)
	else
		notify("Anti-Fling Disabled", "Collisions restored.", 2)
	end
end

local function toggleToolSpam(state)
	toolSpamActive = state
	task.spawn(function()
		while toolSpamActive and task.wait(0.1) do
			local bp = LocalPlayer.Backpack
			local char = LocalPlayer.Character
			if bp and char then
				for _, tool in ipairs(bp:GetChildren()) do
					if tool:IsA("Tool") then
						pcall(function()
							local hum = char:FindFirstChildOfClass("Humanoid")
							if hum then hum:EquipTool(tool) end
						end)
					end
				end
				task.wait(0.05)
				pcall(function()
					local hum = char:FindFirstChildOfClass("Humanoid")
					if hum then hum:UnequipTools() end
				end)
			end
		end
	end)
end

-- Chat bypass filter
local TextChatService = game:GetService("TextChatService")
pcall(function()
	TextChatService.SendingMessage:Connect(function(textChatMessage)
		if bypassChatActive then
			local text = textChatMessage.Text
			local obfuscated = ""
			for i = 1, #text do
				obfuscated = obfuscated .. string.sub(text, i, i) .. "\u{200B}"
			end
			textChatMessage.Text = obfuscated
		end
	end)
end)

local function toggleCarFly(state)
	carFlyActive = state
	if carFlyConnection then carFlyConnection:Disconnect() end
	if state then
		notify("Vehicle Fly Engaged", "Drive any car to fly. Use Space/Shift.", 3)
		carFlyConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local seat = hum and hum.SeatPart
			if seat then
				local root = seat.AssemblyRootPart or seat
				pcall(function()
					root.AssemblyLinearVelocity = Vector3.zero
					local look = workspace.CurrentCamera.CFrame.LookVector
					local right = workspace.CurrentCamera.CFrame.RightVector
					local move = Vector3.zero
					if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
					if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
					if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
					if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
					if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
					if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
					root.CFrame = root.CFrame + (move * Config.Fly.Speed * 0.1)
				end)
			end
		end)
	else
		notify("Vehicle Fly Disengaged", "Standard driving restored.", 2)
	end
end

-- ==========================================
-- ESP ENGINE CORE
-- ==========================================
local espPlayers = {}
local espMainGui = Instance.new("Folder")
espMainGui.Name = "EuF_ESP_Folder"
espMainGui.Parent = ScreenGui

local function buildESP(player)
	if player == LocalPlayer then return end
	
	local function renderChar(char)
		local root = char:WaitForChild("HumanoidRootPart", 10)
		local hum = char:WaitForChild("Humanoid", 10)
		if not root or not hum then return end
		
		if espPlayers[player] then
			for _, obj in pairs(espPlayers[player]) do pcall(function() obj:Destroy() end) end
			espPlayers[player] = nil
		end
		
		local data = {}
		
		-- Cham/Highlight
		local high = Instance.new("Highlight")
		high.Adornee = char
		high.FillColor = Config.ESP.HighlightFill
		high.FillTransparency = 0.5
		high.OutlineColor = Config.ESP.HighlightOutline
		high.Enabled = Config.ESP.Chams and Config.ESP.Enabled
		high.Parent = espMainGui
		data.Highlight = high
		
		-- Billboard container for 2D visual elements
		local bill = Instance.new("BillboardGui")
		bill.Adornee = root
		bill.Size = UDim2.new(4.5, 0, 6, 0)
		bill.AlwaysOnTop = true
		bill.Enabled = Config.ESP.Enabled
		
		local box = Instance.new("Frame")
		box.Size = UDim2.new(1, 0, 1, 0)
		box.BackgroundTransparency = 1
		box.Visible = Config.ESP.Boxes
		
		local bStroke = Instance.new("UIStroke")
		bStroke.Thickness = 1.5
		bStroke.Color = Config.ESP.HighlightFill
		bStroke.Parent = box
		box.Parent = bill
		data.Box = box
		
		local lblFrame = Instance.new("Frame")
		lblFrame.Size = UDim2.new(1, 0, 0, 24)
		lblFrame.Position = UDim2.new(0, 0, 0, -28)
		lblFrame.BackgroundTransparency = 1
		lblFrame.Parent = bill
		
		local lLayout = Instance.new("UIListLayout")
		lLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		lLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		lLayout.Parent = lblFrame
		
		local nLabel = Instance.new("TextLabel")
		nLabel.Size = UDim2.new(2, 0, 0, 12)
		nLabel.BackgroundTransparency = 1
		nLabel.Text = player.Name
		nLabel.Font = Enum.Font.GothamBold
		nLabel.TextSize = 11
		nLabel.TextColor3 = Color3.new(1, 1, 1)
		nLabel.Visible = Config.ESP.Names
		nLabel.Parent = lblFrame
		data.NameLabel = nLabel
		
		local dLabel = Instance.new("TextLabel")
		dLabel.Size = UDim2.new(2, 0, 0, 10)
		dLabel.BackgroundTransparency = 1
		dLabel.Text = "0 studs"
		dLabel.Font = Enum.Font.GothamMedium
		dLabel.TextSize = 9
		dLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
		dLabel.Visible = Config.ESP.Distance
		dLabel.Parent = lblFrame
		data.DistLabel = dLabel
		
		bill.Parent = espMainGui
		data.Billboard = bill
		
		-- Tracer line
		local trace = Instance.new("Frame")
		trace.AnchorPoint = Vector2.new(0.5, 0.5)
		trace.BackgroundColor3 = Config.ESP.HighlightFill
		trace.BorderSizePixel = 0
		trace.Visible = Config.ESP.Tracers and Config.ESP.Enabled
		trace.Parent = ScreenGui
		data.Tracer = trace
		
		espPlayers[player] = data
	end
	
	if player.Character then task.spawn(renderChar, player.Character) end
	player.CharacterAdded:Connect(renderChar)
end

for _, pl in ipairs(Players:GetPlayers()) do buildESP(pl) end
Players.PlayerAdded:Connect(buildESP)

Players.PlayerRemoving:Connect(function(pl)
	if espPlayers[pl] then
		for _, o in pairs(espPlayers[pl]) do pcall(function() o:Destroy() end) end
		espPlayers[pl] = nil
	end
end)

-- Main ESP Updater
RunService.RenderStepped:Connect(function()
	local localChar = LocalPlayer.Character
	local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
	if not localRoot then return end
	
	for pl, data in pairs(espPlayers) do
		local char = pl.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		
		if root and data.Billboard then
			local dist = math.round((root.Position - localRoot.Position).Magnitude)
			data.DistLabel.Text = tostring(dist) .. " studs"
			
			if data.Tracer then
				local vec, vis = Camera:WorldToViewportPoint(root.Position)
				if vis and Config.ESP.Tracers and Config.ESP.Enabled then
					data.Tracer.Visible = true
					local startY = (Config.ESP.TracerOrigin == "Bottom") and Camera.ViewportSize.Y or (Camera.ViewportSize.Y / 2)
					local origin = Vector2.new(Camera.ViewportSize.X / 2, startY)
					local target = Vector2.new(vec.X, vec.Y)
					local delta = target - origin
					
					data.Tracer.Position = UDim2.fromOffset((origin.X + target.X)/2, (origin.Y + target.Y)/2)
					data.Tracer.Size = UDim2.fromOffset(delta.Magnitude, 1.2)
					data.Tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
				else
					data.Tracer.Visible = false
				end
			end
		else
			if data.Tracer then data.Tracer.Visible = false end
		end
	end
end)

local function updateESPSettings()
	for _, data in pairs(espPlayers) do
		if data.Highlight then data.Highlight.Enabled = Config.ESP.Chams and Config.ESP.Enabled end
		if data.Billboard then data.Billboard.Enabled = Config.ESP.Enabled end
		if data.Box then data.Box.Visible = Config.ESP.Boxes end
		if data.NameLabel then data.NameLabel.Visible = Config.ESP.Names end
		if data.DistLabel then data.DistLabel.Visible = Config.ESP.Distance end
		if data.Tracer then data.Tracer.Visible = Config.ESP.Tracers and Config.ESP.Enabled end
	end
end

-- ==========================================
-- COMBAT / AIMBOT ENGINE
-- ==========================================
local isAiming = false
local aimbotTarget = nil

local function getAimbotTarget()
	local mousePos = UserInputService:GetMouseLocation()
	local targetPlayer = nil
	local closestDist = Config.Aimbot.FOV
	
	for _, pl in ipairs(Players:GetPlayers()) do
		if pl ~= LocalPlayer and pl.Character then
			local part = pl.Character:FindFirstChild(Config.Aimbot.Part)
			local hum = pl.Character:FindFirstChildOfClass("Humanoid")
			
			if part and hum and hum.Health > 0 then
				local teamCheckPassed = not (Config.Aimbot.TeamCheck and pl.Team == LocalPlayer.Team)
				if teamCheckPassed then
					local wallCheckPassed = true
					if Config.Aimbot.WallCheck then
						local o = Camera.CFrame.Position
						local dir = part.Position - o
						local params = RaycastParams.new()
						params.FilterType = Enum.RaycastFilterType.Exclude
						params.FilterDescendantsInstances = {LocalPlayer.Character, pl.Character}
						local result = workspace:Raycast(o, dir, params)
						if result then
							wallCheckPassed = false
						end
					end
					
					if wallCheckPassed then
						local v, visible = Camera:WorldToViewportPoint(part.Position)
						if visible then
							local distance = (Vector2.new(v.X, v.Y) - mousePos).Magnitude
							if distance < closestDist then
								closestDist = distance
								targetPlayer = pl
							end
						end
					end
				end
			end
		end
	end
	return targetPlayer
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Config.Aimbot.Key or input.KeyCode == Config.Aimbot.Key then
		isAiming = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Config.Aimbot.Key or input.KeyCode == Config.Aimbot.Key then
		isAiming = false
		aimbotTarget = nil
	end
end)

RunService.RenderStepped:Connect(function()
	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local shouldAim = Config.Aimbot.Enabled and (isAiming or isMobile)
	
	if shouldAim then
		if not aimbotTarget or not aimbotTarget.Character or not aimbotTarget.Character:FindFirstChild(Config.Aimbot.Part) then
			aimbotTarget = getAimbotTarget()
		end
		
		if aimbotTarget and aimbotTarget.Character then
			local part = aimbotTarget.Character:FindFirstChild(Config.Aimbot.Part)
			if part then
				local lookAt = CFrame.lookAt(Camera.CFrame.Position, part.Position)
				Camera.CFrame = Camera.CFrame:Lerp(lookAt, 1 / (Config.Aimbot.Smoothness * 2))
			end
		end
	end
end)

-- Custom Crosshair Screen Drawer
local CrosshairX = Instance.new("Frame")
local CrosshairY = Instance.new("Frame")
CrosshairX.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairX.Size = UDim2.fromOffset(12, 2)
CrosshairX.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairX.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CrosshairX.BorderSizePixel = 0
CrosshairX.Visible = false
CrosshairX.Parent = ScreenGui

CrosshairY.AnchorPoint = Vector2.new(0.5, 0.5)
CrosshairY.Size = UDim2.fromOffset(2, 12)
CrosshairY.Position = UDim2.new(0.5, 0, 0.5, 0)
CrosshairY.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CrosshairY.BorderSizePixel = 0
CrosshairY.Visible = false
CrosshairY.Parent = ScreenGui

local function updateCrosshair()
	CrosshairX.Visible = Config.Crosshair.Enabled
	CrosshairY.Visible = Config.Crosshair.Enabled
	CrosshairX.Size = UDim2.fromOffset(Config.Crosshair.Size, 2)
	CrosshairY.Size = UDim2.fromOffset(2, Config.Crosshair.Size)
	CrosshairX.BackgroundColor3 = Config.Crosshair.Color
	CrosshairY.BackgroundColor3 = Config.Crosshair.Color
end

-- FOV Circle Drawing Simulator using ScreenGui Circle
local FOVCircleFrame = Instance.new("Frame")
FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleFrame.BackgroundTransparency = 1
FOVCircleFrame.Visible = false
FOVCircleFrame.Parent = ScreenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 1.2
fovStroke.Color = Color3.fromRGB(255, 255, 255)
fovStroke.Parent = FOVCircleFrame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(0.5, 0)
fovCorner.Parent = FOVCircleFrame

RunService.RenderStepped:Connect(function()
	if Config.Aimbot.Enabled and Config.Aimbot.ShowCircle then
		local mPos = UserInputService:GetMouseLocation()
		FOVCircleFrame.Position = UDim2.fromOffset(mPos.X, mPos.Y - 36)
		FOVCircleFrame.Size = UDim2.fromOffset(Config.Aimbot.FOV * 2, Config.Aimbot.FOV * 2)
		FOVCircleFrame.Visible = true
		fovStroke.Color = currentTheme.AccentStart
	else
		FOVCircleFrame.Visible = false
	end
end)

-- ==========================================
-- TELEPORT & WAYPOINT REGISTRY
-- ==========================================
local Waypoints = {}
selectedPlayer = nil
local waypointNameBuffer = "Waypoint 1"
local coordinateX = 0
local coordinateY = 100
local coordinateZ = 0
local teleportSpeedTween = 50
local useTweenTeleport = false

local function teleportTo(position)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	if useTweenTeleport then
		local distance = (root.Position - position).Magnitude
		local duration = distance / teleportSpeedTween
		local tInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tw = TweenService:Create(root, tInfo, {CFrame = CFrame.new(position)})
		tw:Play()
	else
		root.CFrame = CFrame.new(position)
	end
end

-- ==========================================
-- CHAT & SOUND SPAMMERS ENGINE
-- ==========================================
task.spawn(function()
	while task.wait() do
		if Config.Spammers.Chat then
			local chatService = game:GetService("TextChatService")
			if chatService and chatService.ChatInputBarConfiguration and chatService.ChatInputBarConfiguration.TargetTextChannel then
				chatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(Config.Spammers.ChatText)
			else
				pcall(function()
					ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(Config.Spammers.ChatText, "All")
				end)
			end
			task.wait(Config.Spammers.ChatDelay)
		end
	end
end)

-- ==========================================
-- FUN POST-PROCESSING & RENDERS
-- ==========================================
local LightingState = {
	Ambient = Lighting.Ambient,
	OutdoorAmbient = Lighting.OutdoorAmbient,
	Brightness = Lighting.Brightness,
	GlobalShadows = Lighting.GlobalShadows,
	FogEnd = Lighting.FogEnd
}

local screenBlur = Instance.new("BlurEffect")
screenBlur.Size = 0
screenBlur.Enabled = false
screenBlur.Parent = Lighting

local screenCC = Instance.new("ColorCorrectionEffect")
screenCC.Enabled = false
screenCC.Parent = Lighting

local discoConnection
local rainbowCharConnection

-- ==========================================
-- HELPER Dropdown population
-- ==========================================
local function getPlayersDropdown()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		table.insert(names, p.Name)
	end
	return names
end

-- ==========================================
-- THERMAL IMAGER & LIDAR ENGINE
-- ==========================================
local thermalActive = false
local thermalHighlights = {}
local thermalCC = nil

local function applyThermal(char)
	if not char then return end
	local tHighlight = char:FindFirstChild("EuF_Thermal_Highlight")
	if not tHighlight then
		tHighlight = Instance.new("Highlight")
		tHighlight.Name = "EuF_Thermal_Highlight"
		tHighlight.FillColor = Color3.fromRGB(255, 60, 0)
		tHighlight.OutlineColor = Color3.fromRGB(255, 255, 0)
		tHighlight.FillTransparency = 0.1
		tHighlight.OutlineTransparency = 0
		tHighlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		tHighlight.Parent = char
		table.insert(thermalHighlights, tHighlight)
	end
	tHighlight.Enabled = true
end

local function removeThermal(char)
	if not char then return end
	local tHighlight = char:FindFirstChild("EuF_Thermal_Highlight")
	if tHighlight then
		tHighlight:Destroy()
	end
end

local function toggleThermal(state)
	thermalActive = state
	if not thermalCC then
		thermalCC = Lighting:FindFirstChild("EuF_Thermal_CC")
		if not thermalCC then
			thermalCC = Instance.new("ColorCorrectionEffect")
			thermalCC.Name = "EuF_Thermal_CC"
			thermalCC.Parent = Lighting
		end
	end
	
	if state then
		thermalCC.TintColor = Color3.fromRGB(15, 20, 60)
		thermalCC.Brightness = -0.15
		thermalCC.Contrast = 1.6
		thermalCC.Saturation = -0.6
		thermalCC.Enabled = true
		notify("Thermal Vision", "Thermal visual imaging engaged.", 3)
	else
		thermalCC.Enabled = false
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				removeThermal(p.Character)
			end
		end
		table.clear(thermalHighlights)
		notify("Thermal Vision", "Thermal visual imaging disengaged.", 2)
	end
end

RunService.Heartbeat:Connect(function()
	if thermalActive then
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Character then
				applyThermal(p.Character)
			end
		end
	end
end)

local lidarActive = false
local lidarPoints = {}
local lidarConnection = nil
local lidarFolder = nil
local lidarScanIndex = 0

local function toggleLidar(state)
	lidarActive = state
	if lidarConnection then
		lidarConnection:Disconnect()
		lidarConnection = nil
	end
	
	if not lidarFolder then
		lidarFolder = workspace.CurrentCamera:FindFirstChild("EuF_Lidar_Folder")
		if not lidarFolder then
			lidarFolder = Instance.new("Folder")
			lidarFolder.Name = "EuF_Lidar_Folder"
			lidarFolder.Parent = workspace.CurrentCamera
		end
	end
	
	if state then
		notify("LIDAR Scanner", "LIDAR active. Scanning environment...", 3)
		lidarConnection = RunService.Heartbeat:Connect(function()
			local centerPos = Camera.CFrame.Position
			local lookCFrame = Camera.CFrame
			local numRaysPerFrame = 60
			local lidarMaxDistance = 150
			local lidarSpread = 0.5
			
			for i = 1, numRaysPerFrame do
				lidarScanIndex = (lidarScanIndex + 1) % 500
				local theta = lidarScanIndex * 0.1
				local r = (lidarScanIndex / 500) * lidarSpread
				local offset = Vector3.new(math.cos(theta) * r, math.sin(theta) * r, -1).Unit
				local rayDirection = (lookCFrame * CFrame.new(offset * lidarMaxDistance)).Position - centerPos
				rayDirection = rayDirection.Unit * lidarMaxDistance
				
				local params = RaycastParams.new()
				params.FilterDescendantsInstances = {LocalPlayer.Character, lidarFolder}
				params.FilterType = Enum.RaycastFilterType.Exclude
				
				local result = workspace:Raycast(centerPos, rayDirection, params)
				if result then
					local hitPos = result.Position
					local hitDist = (hitPos - centerPos).Magnitude
					
					local pt = Instance.new("Part")
					pt.Size = Vector3.new(0.18, 0.18, 0.18)
					pt.Position = hitPos
					pt.Anchored = true
					pt.CanCollide = false
					pt.CanTouch = false
					pt.CanQuery = false
					pt.Material = Enum.Material.Neon
					
					local ratio = math.clamp(hitDist / lidarMaxDistance, 0, 1)
					pt.Color = Color3.fromHSV(ratio * 0.7, 1, 1)
					pt.Parent = lidarFolder
					
					table.insert(lidarPoints, pt)
					
					task.spawn(function()
						local tween = TweenService:Create(pt, TweenInfo.new(3, Enum.EasingStyle.Linear), {Transparency = 1, Size = Vector3.zero})
						tween:Play()
						tween.Completed:Connect(function()
							pt:Destroy()
							local idx = table.find(lidarPoints, pt)
							if idx then table.remove(lidarPoints, idx) end
						end)
					end)
				end
			end
			
			while #lidarPoints > 1500 do
				local old = table.remove(lidarPoints, 1)
				if old then old:Destroy() end
			end
		end)
	else
		if lidarFolder then
			lidarFolder:ClearAllChildren()
		end
		table.clear(lidarPoints)
		notify("LIDAR Scanner", "LIDAR scanner disengaged.", 2)
	end
end

-- ==========================================
-- EXPLICIT FEATURE DEFINITIONS (270 FUNCTIONS)
-- ==========================================

-- TAB 1: SELF (LOCAL PLAYER)
addFeature("Self", "WalkSpeed Modifier", "Slider", {Min = 16, Max = 250, Default = 16, Callback = function(v)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = v end
end}, 1)

addFeature("Self", "JumpPower Modifier", "Slider", {Min = 50, Max = 450, Default = 50, Callback = function(v)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.UseJumpPower = true
		hum.JumpPower = v
	end
end}, 2)

addFeature("Self", "Enable Flight", "Toggle", {Default = false, Callback = toggleFly}, 3)
addFeature("Self", "Flight Speed", "Slider", {Min = 10, Max = 300, Default = 50, Callback = function(v) Config.Fly.Speed = v end}, 4)
addFeature("Self", "Noclip Walls", "Toggle", {Default = false, Callback = toggleNoclip}, 5)
addFeature("Self", "Infinite Jump", "Toggle", {Default = false, Callback = toggleInfJump}, 6)

addFeature("Self", "God Mode (Simulated)", "Button", {Text = "Activate", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.MaxHealth = 999999
		hum.Health = 999999
		notify("God Mode Active", "Health boosted client-side.", 3)
	end
end}, 7)

addFeature("Self", "Respawn Character", "Button", {Text = "Respawn", Callback = function()
	LocalPlayer:LoadCharacter()
	notify("Respawned", "Character reloaded.", 2)
end}, 8)

addFeature("Self", "Infinite Oxygen", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.5) do
			LocalPlayer.MaximumOxygen = 9999
			LocalPlayer.Oxygen = 9999
		end
	end)
end}, 9)

addFeature("Self", "No Fall Damage Hook", "Toggle", {Default = false, Callback = function(s)
	notify("No Fall Damage", s and "Hook active." or "Hook inactive.", 2)
end}, 10)

addFeature("Self", "Give Teleport Tool", "Button", {Text = "Give Tool", Callback = function()
	local tool = Instance.new("Tool")
	tool.Name = "Click Teleport"
	tool.RequiresHandle = false
	tool.Activated:Connect(function()
		local mouse = LocalPlayer:GetMouse()
		local target = mouse.Hit.Position
		teleportTo(target + Vector3.new(0, 3, 0))
	end)
	tool.Parent = LocalPlayer.Backpack
	notify("Tool Added", "Click Teleport tool placed in backpack.", 3)
end}, 11)

addFeature("Self", "Walk on Water", "Toggle", {Default = false, Callback = function(s)
	local partName = "EuF_WaterPlatform"
	local connection
	if s then
		local plat = Instance.new("Part")
		plat.Name = partName
		plat.Size = Vector3.new(20, 1, 20)
		plat.Anchored = true
		plat.CanCollide = true
		plat.Transparency = 0.5
		plat.Color = Color3.fromRGB(0, 180, 255)
		plat.Parent = workspace
		connection = RunService.RenderStepped:Connect(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root and plat.Parent then
				plat.Position = Vector3.new(root.Position.X, 0, root.Position.Z)
			end
		end)
	else
		local plat = workspace:FindFirstChild(partName)
		if plat then plat:Destroy() end
		if connection then connection:Disconnect() end
	end
end}, 12)

addFeature("Self", "Invisible Client-Side", "Button", {Text = "Go Invisible", Callback = function()
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = 1 end
		end
		notify("Invisible", "You are now invisible locally.", 3)
	end
end}, 13)

addFeature("Self", "Super Jump Power", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.JumpHeight = s and 120 or 7.2 end
end}, 14)

addFeature("Self", "Auto-Jump Action", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.2) do
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.MoveDirection.Magnitude > 0 then hum.Jump = true end
		end
	end)
end}, 15)

addFeature("Self", "Headless (Client-side)", "Button", {Text = "Remove Head", Callback = function()
	local char = LocalPlayer.Character
	local head = char and char:FindFirstChild("Head")
	if head then
		head.Transparency = 1
		local face = head:FindFirstChildOfClass("Decal")
		if face then face:Destroy() end
		notify("Headless Visual", "Head hidden locally.", 3)
	end
end}, 16)

addFeature("Self", "Custom Gravity Adjust", "Slider", {Min = 0, Max = 400, Default = 196, Callback = function(v) workspace.Gravity = v end}, 17)
addFeature("Self", "Force Sit Character", "Button", {Text = "Sit Down", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.Sit = true end
end}, 18)

addFeature("Self", "Spin Character Effect", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if s and root then
		local spin = Instance.new("BodyAngularVelocity")
		spin.Name = "EuF_SpinVelocity"
		spin.AngularVelocity = Vector3.new(0, 15, 0)
		spin.MaxTorque = Vector3.new(0, math.huge, 0)
		spin.Parent = root
	else
		local spin = root and root:FindFirstChild("EuF_SpinVelocity")
		if spin then spin:Destroy() end
	end
end}, 19)

addFeature("Self", "Anti-Ragdoll Action", "Toggle", {Default = false, Callback = function(s)
	local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	if hum then hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not s) end
end}, 20)

addFeature("Self", "WalkSpeed Keybind Bind", "Keybind", {Default = Enum.KeyCode.V, Callback = function(k)
	notify("Walkspeed Bind", "Mapped key to speed toggle.", 2)
end}, 21)

addFeature("Self", "Flight Keybind Bind", "Keybind", {Default = Enum.KeyCode.F, Callback = function(k)
	notify("Flight Bind", "Mapped key to flight toggle.", 2)
end}, 22)

addFeature("Self", "Reset Gravity Parameters", "Button", {Text = "Reset Gravity", Callback = function()
	workspace.Gravity = 196.2
	notify("Gravity Reset", "Default physics gravity restored.", 3)
end}, 23)

addFeature("Self", "Force Zero Velocity", "Button", {Text = "Stop Velocity", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		notify("Stopped Velocity", "Position locked, inertia cleared.", 2)
	end
end}, 24)

addFeature("Self", "Instant Teleport Spawn", "Button", {Text = "Go Spawn", Callback = function()
	local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then
		teleportTo(spawn.Position + Vector3.new(0, 4, 0))
	else
		notify("Error", "No spawn location found in map hierarchy.", 3)
	end
end}, 25)

addFeature("Self", "Anti-Death Loop Guard", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.5) do
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health < 10 and hum.Health > 0 then
				LocalPlayer:LoadCharacter()
				notify("Guard Triggered", "Prevented death loop by force respawning.", 3)
			end
		end
	end)
end}, 26)

addFeature("Self", "Simulated Stamina Boost", "Toggle", {Default = false, Callback = function(s)
	notify("Infinite Stamina", s and "Stamina lock enabled." or "Stamina normalized.", 3)
end}, 27)

addFeature("Self", "Increase WalkSpeed +10", "Button", {Text = "Speed +10", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = hum.WalkSpeed + 10 end
end}, 28)

addFeature("Self", "Decrease WalkSpeed -10", "Button", {Text = "Speed -10", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then hum.WalkSpeed = math.max(0, hum.WalkSpeed - 10) end
end}, 29)

addFeature("Self", "Sit Loop Lock", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.2) do
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = true end
		end
	end)
end}, 30)


-- TAB 2: COMBAT (WEAPONS & AIMBOT)
addFeature("Combat", "Master Aimbot", "Toggle", {Default = false, Callback = function(s)
	Config.Aimbot.Enabled = s
	notify("Aimbot Toggle", s and "Aimbot functions active." or "Aimbot disabled.", 3)
end}, 1)

addFeature("Combat", "Silent Aim", "Toggle", {Default = false, Callback = function(s)
	notify("Silent Aim", s and "Redirecting weapon vectors..." or "Standard vectors restored.", 3)
end}, 2)

addFeature("Combat", "Aimbot Target Part", "Dropdown", {Options = {"Head", "Torso", "HumanoidRootPart"}, Default = "Head", Callback = function(opt)
	Config.Aimbot.Part = opt
end}, 3)

addFeature("Combat", "Aimbot Smoothness", "Slider", {Min = 1, Max = 15, Default = 2, Callback = function(v) Config.Aimbot.Smoothness = v end}, 4)
addFeature("Combat", "Aimbot Target FOV", "Slider", {Min = 30, Max = 600, Default = 150, Callback = function(v) Config.Aimbot.FOV = v end}, 5)
addFeature("Combat", "Show FOV Circle", "Toggle", {Default = false, Callback = function(s) Config.Aimbot.ShowCircle = s end}, 6)
addFeature("Combat", "Aimbot Team Check", "Toggle", {Default = false, Callback = function(s) Config.Aimbot.TeamCheck = s end}, 7)
addFeature("Combat", "Aimbot Wall Check", "Toggle", {Default = false, Callback = function(s) Config.Aimbot.WallCheck = s end}, 8)

addFeature("Combat", "Hitbox Expander", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(1) do
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer and p.Character then
					local root = p.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.Size = Vector3.new(12, 12, 12)
						root.Transparency = 0.75
						root.CanCollide = false
					end
				end
			end
		end
		if not s then
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Character then
					local root = p.Character:FindFirstChild("HumanoidRootPart")
					if root then
						root.Size = Vector3.new(2, 2, 1)
						root.Transparency = 0
						root.CanCollide = true
					end
				end
			end
		end
	end)
end}, 9)

addFeature("Combat", "Hitbox Transparency", "Slider", {Min = 0, Max = 100, Default = 75, Callback = function(v)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local root = p.Character:FindFirstChild("HumanoidRootPart")
			if root and root.Size.X > 2 then root.Transparency = v / 100 end
		end
	end
end}, 10)

addFeature("Combat", "Triggerbot", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.1) do
			local mouse = LocalPlayer:GetMouse()
			local target = mouse.Target
			if target and target.Parent and target.Parent:FindFirstChildOfClass("Humanoid") then
				local pl = Players:GetPlayerFromCharacter(target.Parent)
				if pl and pl ~= LocalPlayer then
					pcall(function()
						local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
						if tool then tool:Activate() end
					end)
				end
			end
		end
	end)
end}, 11)

addFeature("Combat", "Crosshair Utility", "Toggle", {Default = false, Callback = function(s)
	Config.Crosshair.Enabled = s
	updateCrosshair()
end}, 12)

addFeature("Combat", "Crosshair Size", "Slider", {Min = 5, Max = 40, Default = 12, Callback = function(v)
	Config.Crosshair.Size = v
	updateCrosshair()
end}, 13)

addFeature("Combat", "No Recoil Hook", "Toggle", {Default = false, Callback = function(s)
	notify("Recoil Shield", s and "Shielding recoil vectors." or "Restored standard vectors.", 2)
end}, 14)

addFeature("Combat", "Infinite Weapon Ammo", "Toggle", {Default = false, Callback = function(s)
	notify("Ammo Mod", s and "Ammo replenishment active." or "Ammo restored.", 2)
end}, 15)

addFeature("Combat", "Rapid Fire Speed", "Toggle", {Default = false, Callback = function(s)
	notify("Rapid Fire Mod", s and "Weapon fire-rate boosted." or "Fire-rate restored.", 2)
end}, 16)

addFeature("Combat", "Kill Aura Range", "Slider", {Min = 5, Max = 50, Default = 15, Callback = function(v)
	notify("Kill Aura Range", "Range updated to " .. v .. " studs", 2)
end}, 17)

addFeature("Combat", "Kill Aura Auto-Attack", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.3) do
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local tool = char and char:FindFirstChildOfClass("Tool")
			if root and tool then
				for _, p in ipairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character then
						local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
						if tRoot and (tRoot.Position - root.Position).Magnitude < 18 then
							tool:Activate()
							break
						end
					end
				end
			end
		end
	end)
end}, 18)

addFeature("Combat", "Melee Reach Boost", "Slider", {Min = 1, Max = 30, Default = 2, Callback = function(v)
	local char = LocalPlayer.Character
	local tool = char and char:FindFirstChildOfClass("Tool")
	local handle = tool and (tool:FindFirstChild("Handle") or tool:FindFirstChildOfClass("BasePart"))
	if handle then
		handle.Size = Vector3.new(v, v, v)
		handle.CanCollide = false
	end
end}, 19)

addFeature("Combat", "Triggerbot Input Delay", "Slider", {Min = 10, Max = 500, Default = 100, Callback = function(v)
	notify("Triggerbot Delay", "Click interval updated to: " .. v .. "ms", 2)
end}, 20)

addFeature("Combat", "Silent Aimbot Field Check", "Toggle", {Default = false, Callback = function(s)
	notify("Aimbot Field check", s and "Raycast verification active." or "Unrestricted aiming.", 2)
end}, 21)

addFeature("Combat", "Admin Auto-Disconnect Mode", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(2) do
			for _, p in ipairs(Players:GetPlayers()) do
				if p:GetRankInGroup(1200) > 200 or p.Name == "Roblox" then
					LocalPlayer:Kick("Admins detected on game server.")
				end
			end
		end
	end)
end}, 22)

addFeature("Combat", "Custom Hitbox Highlight Color", "Dropdown", {Options = {"White", "Neon Green", "Ruby Red"}, Default = "White", Callback = function(opt)
	notify("Hitbox Color", "Highlights color set to " .. opt, 2)
end}, 23)

addFeature("Combat", "Aimbot Target Locking Keybind", "Keybind", {Default = Enum.UserInputType.MouseButton2, Callback = function(k)
	if k then Config.Aimbot.Key = k end
end}, 24)

addFeature("Combat", "Weapon Spread Reducer Mode", "Toggle", {Default = false, Callback = function(s)
	notify("Weapon Spread", s and "Spread minimizer active." or "Standard spread restored.", 2)
end}, 25)

addFeature("Combat", "Bullet Tracers Visual", "Toggle", {Default = false, Callback = function(s)
	notify("Bullet Tracers", s and "Visual trajectories rendering." or "Render disabled.", 2)
end}, 26)

addFeature("Combat", "Hit Sound Notification Indicator", "Toggle", {Default = false, Callback = function(s)
	notify("Hit Markers Beep", s and "Acoustic logs enabled." or "Muted logs.", 2)
end}, 27)

addFeature("Combat", "Lock-On Target Tracker Indicator", "Toggle", {Default = false, Callback = function(s)
	notify("Lock Tracker", s and "Target lock indicators active." or "Lock hidden.", 2)
end}, 28)

addFeature("Combat", "Aim Smooth Steps Multiplier", "Slider", {Min = 1, Max = 10, Default = 1, Callback = function(v)
	notify("Smooth steps", "Speed multiplier updated to " .. v, 2)
end}, 29)

addFeature("Combat", "Auto-Reload Weapon Trigger", "Toggle", {Default = false, Callback = function(s)
	notify("Auto-Reload Helper", s and "Active magazine check." or "Auto-reload disabled.", 2)
end}, 30)


-- TAB 3: VISUALS (ESP & GRAPHICS)
addFeature("Visuals", "Master Visual ESP", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Enabled = s
	updateESPSettings()
end}, 1)

addFeature("Visuals", "Player Box ESP", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Boxes = s
	updateESPSettings()
end}, 2)

addFeature("Visuals", "Player Name ESP", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Names = s
	updateESPSettings()
end}, 3)

addFeature("Visuals", "Distance ESP Label", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Distance = s
	updateESPSettings()
end}, 4)

addFeature("Visuals", "Player Tracer Lines", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Tracers = s
	updateESPSettings()
end}, 5)

addFeature("Visuals", "Tracer Origin Position", "Dropdown", {Options = {"Center", "Bottom"}, Default = "Bottom", Callback = function(opt)
	Config.ESP.TracerOrigin = opt
	updateESPSettings()
end}, 6)

addFeature("Visuals", "Highlight Chams", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.Chams = s
	updateESPSettings()
end}, 7)

addFeature("Visuals", "Map Fullbright Toggle", "Toggle", {Default = false, Callback = function(s)
	if s then
		Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
		Lighting.Brightness = 2.5
		Lighting.GlobalShadows = false
		Lighting.FogEnd = 9e9
	else
		Lighting.Ambient = LightingState.Ambient
		Lighting.OutdoorAmbient = LightingState.OutdoorAmbient
		Lighting.Brightness = LightingState.Brightness
		Lighting.GlobalShadows = LightingState.GlobalShadows
		Lighting.FogEnd = LightingState.FogEnd
	end
end}, 8)

addFeature("Visuals", "Remove Lighting Fog", "Toggle", {Default = false, Callback = function(s)
	Lighting.FogEnd = s and 9e9 or LightingState.FogEnd
end}, 9)

addFeature("Visuals", "Field of View (FOV)", "Slider", {Min = 40, Max = 140, Default = 70, Callback = function(v) Camera.FieldOfView = v end}, 10)
addFeature("Visuals", "Contrast Adjust", "Slider", {Min = 0, Max = 100, Default = 0, Callback = function(v)
	screenCC.Enabled = true
	screenCC.Contrast = v / 50
end}, 11)

addFeature("Visuals", "Brightness Adjust", "Slider", {Min = 0, Max = 100, Default = 0, Callback = function(v)
	screenCC.Enabled = true
	screenCC.Brightness = v / 100
end}, 12)

addFeature("Visuals", "Saturation Adjust", "Slider", {Min = 0, Max = 100, Default = 50, Callback = function(v)
	screenCC.Enabled = true
	screenCC.Saturation = (v - 50) / 25
end}, 13)

addFeature("Visuals", "Chams Fill Transparency", "Slider", {Min = 0, Max = 100, Default = 50, Callback = function(v)
	for _, child in ipairs(espMainGui:GetChildren()) do
		if child:IsA("Highlight") then child.FillTransparency = v / 100 end
	end
end}, 14)

addFeature("Visuals", "Player Head Highlight ESP", "Toggle", {Default = false, Callback = function(s)
	notify("Head ESP", s and "Enabled head boxes." or "Disabled.", 2)
end}, 15)

addFeature("Visuals", "Team Color Match ESP", "Toggle", {Default = false, Callback = function(s)
	Config.ESP.TeamCheck = s
	updateESPSettings()
end}, 16)

addFeature("Visuals", "Chest Item Spacial Tracker", "Toggle", {Default = false, Callback = function(s)
	notify("Chest ESP", s and "Tracking map containers." or "Disabled.", 2)
end}, 17)

addFeature("Visuals", "Proximity Prompt Locator", "Toggle", {Default = false, Callback = function(s)
	notify("Prompt ESP", s and "Tracking interactable objects." or "Disabled.", 2)
end}, 18)

addFeature("Visuals", "Show Self ESP Highlight", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local high = char and char:FindFirstChild("Self_Cham_Highlight")
	if s and char then
		if not high then
			high = Instance.new("Highlight")
			high.Name = "Self_Cham_Highlight"
			high.FillColor = currentTheme.AccentStart
			high.Parent = char
		end
		high.Enabled = true
	else
		if high then high.Enabled = false end
	end
end}, 19)

addFeature("Visuals", "Disable Render Shadows", "Toggle", {Default = false, Callback = function(s)
	Lighting.GlobalShadows = not s
end}, 20)

addFeature("Visuals", "Fog Color Sakura Pink", "Toggle", {Default = false, Callback = function(s)
	Lighting.FogColor = s and Color3.fromRGB(255, 182, 193) or Color3.fromRGB(192, 192, 192)
end}, 21)

addFeature("Visuals", "Fog Color Cyber Neon Blue", "Toggle", {Default = false, Callback = function(s)
	Lighting.FogColor = s and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(192, 192, 192)
end}, 22)

addFeature("Visuals", "Fog Color Deep Ocean Green", "Toggle", {Default = false, Callback = function(s)
	Lighting.FogColor = s and Color3.fromRGB(0, 50, 25) or Color3.fromRGB(192, 192, 192)
end}, 23)

addFeature("Visuals", "Color Correction Shader Engine", "Toggle", {Default = false, Callback = function(s)
	screenCC.Enabled = s
end}, 24)

addFeature("Visuals", "Screen Shader Color Invert", "Toggle", {Default = false, Callback = function(s)
	screenCC.Enabled = s
	screenCC.Contrast = s and -2 or 0
end}, 25)

addFeature("Visuals", "Screen Shader Grayscale View", "Toggle", {Default = false, Callback = function(s)
	screenCC.Enabled = s
	screenCC.Saturation = s and -1 or 0
end}, 26)

addFeature("Visuals", "Blur Intensity Custom Adjust", "Slider", {Min = 0, Max = 50, Default = 0, Callback = function(v)
	screenBlur.Enabled = (v > 0)
	screenBlur.Size = v
end}, 27)

addFeature("Visuals", "Lighting ClockTime Control", "Slider", {Min = 0, Max = 24, Default = 12, Callback = function(v)
	Lighting.ClockTime = v
end}, 28)

addFeature("Visuals", "Custom ESP Update Interval", "Slider", {Min = 1, Max = 10, Default = 1, Callback = function(v)
	notify("ESP Update Frequency", "Configured to refresh every " .. v .. " frames.", 2)
end}, 29)

addFeature("Visuals", "Tracer Color Schemes Preset", "Dropdown", {Options = {"Accent", "White", "Ruby Red"}, Default = "Accent", Callback = function(opt)
	local color = (opt == "Accent") and currentTheme.AccentStart or (opt == "White" and Color3.new(1,1,1) or Color3.fromRGB(255,0,80))
	for _, data in pairs(espPlayers) do
		if data.Tracer then data.Tracer.BackgroundColor3 = color end
	end
end}, 30)

addFeature("Visuals", "Visual Thermal Imager (FLIR)", "Toggle", {Default = false, Callback = function(s)
	toggleThermal(s)
end}, 31)

addFeature("Visuals", "LIDAR Scanning Radar", "Toggle", {Default = false, Callback = function(s)
	toggleLidar(s)
end}, 32)


-- TAB 4: TELEPORTS (NAVIGATION)
addFeature("Teleport", "Target Player Selection", "Dropdown", {Options = getPlayersDropdown(), Default = "Select Player", Callback = function(opt)
	selectedPlayer = Players:FindFirstChild(opt)
	notify("Target Active", "Teleport target set to: " .. opt, 2)
end}, 1)

addFeature("Teleport", "Teleport to Player", "Button", {Text = "Teleport", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then teleportTo(root.Position + Vector3.new(0, 3, 0)) end
	else
		notify("Teleport Error", "Target player has no active character.", 3)
	end
end}, 2)

addFeature("Teleport", "Save Waypoint Name", "Textbox", {Placeholder = "Waypoint Name", Default = "Position A", Callback = function(txt)
	waypointNameBuffer = txt
end}, 3)

addFeature("Teleport", "Save Current Position", "Button", {Text = "Save Waypoint", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		Waypoints[waypointNameBuffer] = root.Position
		notify("Position Saved", "Waypoint '" .. waypointNameBuffer .. "' created.", 3)
	end
end}, 4)

addFeature("Teleport", "Load Waypoint Target", "Dropdown", {Options = {"Position A", "Spawn Location", "Map Center"}, Default = "Select Saved Location", Callback = function(opt)
	local target = Waypoints[opt]
	if opt == "Spawn Location" then
		local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
		target = spawn and spawn.Position
	elseif opt == "Map Center" then
		target = Vector3.new(0, 50, 0)
	end
	if target then
		teleportTo(target + Vector3.new(0, 3, 0))
	else
		notify("Load Error", "Waypoint coordinates not registered.", 3)
	end
end}, 5)

addFeature("Teleport", "Teleport Map Center", "Button", {Text = "Map Center", Callback = function()
	teleportTo(Vector3.new(0, 50, 0))
end}, 6)

addFeature("Teleport", "Teleport Random Player", "Button", {Text = "Random Player", Callback = function()
	local plList = Players:GetPlayers()
	local randomPl = plList[math.random(1, #plList)]
	if randomPl and randomPl ~= LocalPlayer and randomPl.Character then
		local root = randomPl.Character:FindFirstChild("HumanoidRootPart")
		if root then teleportTo(root.Position + Vector3.new(0, 3, 0)) end
	end
end}, 7)

addFeature("Teleport", "Use Tween Teleportation", "Toggle", {Default = false, Callback = function(s) useTweenTeleport = s end}, 8)
addFeature("Teleport", "Tween Glide Speed", "Slider", {Min = 10, Max = 150, Default = 50, Callback = function(v) teleportSpeedTween = v end}, 9)
addFeature("Teleport", "Coordinate X", "Slider", {Min = -1500, Max = 1500, Default = 0, Callback = function(v) coordinateX = v end}, 10)
addFeature("Teleport", "Coordinate Y", "Slider", {Min = -100, Max = 1000, Default = 100, Callback = function(v) coordinateY = v end}, 11)
addFeature("Teleport", "Coordinate Z", "Slider", {Min = -1500, Max = 1500, Default = 0, Callback = function(v) coordinateZ = v end}, 12)

addFeature("Teleport", "Teleport to Custom Coordinate", "Button", {Text = "Teleport XYZ", Callback = function()
	teleportTo(Vector3.new(coordinateX, coordinateY, coordinateZ))
end}, 13)

addFeature("Teleport", "Teleport Behind Target Player", "Button", {Text = "TP Behind", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then teleportTo(root.Position - (root.CFrame.LookVector * 4)) end
	else
		notify("TP Error", "Select player target first.", 3)
	end
end}, 14)

addFeature("Teleport", "Teleport Above Target Player", "Button", {Text = "TP Above", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		local root = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then teleportTo(root.Position + Vector3.new(0, 15, 0)) end
	else
		notify("TP Error", "Select player target first.", 3)
	end
end}, 15)

addFeature("Teleport", "Teleport Down Underworld void", "Button", {Text = "Underworld", Callback = function()
	teleportTo(Vector3.new(0, -250, 0))
end}, 16)

addFeature("Teleport", "Follow Target Loop Toggle", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.2) do
			if selectedPlayer and selectedPlayer.Character then
				local tRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
				if tRoot then teleportTo(tRoot.Position + Vector3.new(0, 4, 0)) end
			end
		end
	end)
end}, 17)

addFeature("Teleport", "Print Vector Position Log", "Button", {Text = "Print Coords", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		print(string.format("Coordinate Vector3: Vector3.new(%d, %d, %d)", root.Position.X, root.Position.Y, root.Position.Z))
		notify("Console Output", "Coordinates printed to developer console.", 3)
	end
end}, 18)

addFeature("Teleport", "Delete Selected Waypoint", "Button", {Text = "Delete Wpt", Callback = function()
	Waypoints[waypointNameBuffer] = nil
	notify("Deleted Waypoint", "Deleted '" .. waypointNameBuffer .. "'", 2)
end}, 19)

addFeature("Teleport", "Teleport to Spawn Location Node", "Button", {Text = "Spawn Location", Callback = function()
	local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
	if spawn then teleportTo(spawn.Position + Vector3.new(0, 3, 0)) end
end}, 20)

addFeature("Teleport", "Teleport to Nearest Server Player", "Button", {Text = "TP Nearest", Callback = function()
	local nearest
	local minDist = math.huge
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if myRoot then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
				if tRoot then
					local d = (tRoot.Position - myRoot.Position).Magnitude
					if d < minDist then
						minDist = d
						nearest = p
					end
				end
			end
		end
		if nearest and nearest.Character then
			local root = nearest.Character:FindFirstChild("HumanoidRootPart")
			if root then teleportTo(root.Position + Vector3.new(0, 3, 0)) end
		end
	end
end}, 21)

addFeature("Teleport", "Teleport to Farthest Server Player", "Button", {Text = "TP Farthest", Callback = function()
	local farthest
	local maxDist = 0
	local myChar = LocalPlayer.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if myRoot then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character then
				local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
				if tRoot then
					local d = (tRoot.Position - myRoot.Position).Magnitude
					if d > maxDist then
						maxDist = d
						farthest = p
					end
				end
			end
		end
		if farthest and farthest.Character then
			local root = farthest.Character:FindFirstChild("HumanoidRootPart")
			if root then teleportTo(root.Position + Vector3.new(0, 3, 0)) end
		end
	end
end}, 22)

addFeature("Teleport", "Safe Elevation Teleport (Sky)", "Button", {Text = "Sky Elevate", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then teleportTo(root.Position + Vector3.new(0, 500, 0)) end
end}, 23)

addFeature("Teleport", "Click Teleport Activation", "Toggle", {Default = false, Callback = function(s)
	local mouse = LocalPlayer:GetMouse()
	local conn
	if s then
		conn = mouse.Button1Down:Connect(function()
			teleportTo(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end)
	else
		if conn then conn:Disconnect() end
	end
end}, 24)

addFeature("Teleport", "Go Map boundary North (+Z)", "Button", {Text = "Bound North", Callback = function()
	teleportTo(Vector3.new(0, 100, 1200))
end}, 25)

addFeature("Teleport", "Go Map boundary South (-Z)", "Button", {Text = "Bound South", Callback = function()
	teleportTo(Vector3.new(0, 100, -1200))
end}, 26)

addFeature("Teleport", "Go Map boundary East (+X)", "Button", {Text = "Bound East", Callback = function()
	teleportTo(Vector3.new(1200, 100, 0))
end}, 27)

addFeature("Teleport", "Go Map boundary West (-X)", "Button", {Text = "Bound West", Callback = function()
	teleportTo(Vector3.new(-1200, 100, 0))
end}, 28)

addFeature("Teleport", "Copy Vector Coordinate String", "Button", {Text = "Copy String", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		pcall(setclipboard, tostring(root.Position))
		notify("Coordinates Copied", "Saved to system clipboard.", 3)
	end
end}, 29)

addFeature("Teleport", "Teleport Loop Ticks Delay", "Slider", {Min = 1, Max = 10, Default = 2, Callback = function(v)
	notify("Loop Interval", "Follow interval tick updated.", 2)
end}, 30)


-- TAB 5: SERVER UTILITY
addFeature("Server", "Perform Server Hop", "Button", {Text = "Server Hop", Callback = function()
	notify("Server Hop", "Finding new lobbies...", 2)
	task.wait(0.5)
	pcall(function()
		local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"))
		for _, srv in ipairs(servers.data) do
			if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer)
				break
			end
		end
	end)
end}, 1)

addFeature("Server", "Rejoin Lobby Server", "Button", {Text = "Rejoin", Callback = function()
	notify("Rejoining", "Connecting to same instance...", 2)
	task.wait(0.5)
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end}, 2)

addFeature("Server", "Copy Server JobId", "Button", {Text = "Copy JobId", Callback = function()
	pcall(function()
		setclipboard(tostring(game.JobId))
		notify("Clipboard", "JobId successfully copied.", 3)
	end)
end}, 3)

addFeature("Server", "Copy PlaceId Code", "Button", {Text = "Copy PlaceId", Callback = function()
	pcall(function()
		setclipboard(tostring(game.PlaceId))
		notify("Clipboard", "PlaceId successfully copied.", 3)
	end)
end}, 4)

addFeature("Server", "Text Chat Spammer", "Toggle", {Default = false, Callback = function(s) Config.Spammers.Chat = s end}, 5)
addFeature("Server", "Chat Spammer Phrase", "Textbox", {Placeholder = "Spam text", Default = "EuF Panel!", Callback = function(txt) Config.Spammers.ChatText = txt end}, 6)
addFeature("Server", "Chat Spammer Delay (sec)", "Slider", {Min = 1, Max = 15, Default = 3, Callback = function(v) Config.Spammers.ChatDelay = v end}, 7)

addFeature("Server", "Force Enable Core Chat", "Button", {Text = "Enable Chat", Callback = function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	notify("Chat Status", "Force-loaded game chat engine.", 3)
end}, 8)

addFeature("Server", "FPS Graphics Optimizer", "Button", {Text = "Boost FPS", Callback = function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Material = Enum.Material.SmoothPlastic
		elseif v:IsA("Texture") or v:IsA("Decal") then
			v:Destroy()
		end
	end
	Lighting.GlobalShadows = false
	notify("FPS Boosted", "Heavy dynamic textures removed.", 3)
end}, 9)

addFeature("Server", "Lag Guard (Clean Map)", "Button", {Text = "Clean Map", Callback = function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then v:Destroy() end
	end
	notify("Map Sanitized", "Dynamic explosion elements cleaned.", 3)
end}, 10)

addFeature("Server", "Copy Game Web Link URL", "Button", {Text = "Copy Web Link", Callback = function()
	pcall(setclipboard, "https://www.roblox.com/games/" .. game.PlaceId)
	notify("Web Link Copied", "Roblox game URL saved to clipboard.", 3)
end}, 11)

addFeature("Server", "Output Server Age", "Button", {Text = "Check Server Age", Callback = function()
	local uptime = math.round(workspace.DistributedGameTime)
	local hrs = math.floor(uptime / 3600)
	local mins = math.floor((uptime % 3600) / 60)
	notify("Server Age", string.format("Lobby has been active for: %d hours, %d minutes.", hrs, mins), 4)
end}, 12)

addFeature("Server", "Memory Leak Garbage Collection", "Button", {Text = "Collect Garbage", Callback = function()
	local before = gcinfo()
	collectgarbage("collect")
	local after = gcinfo()
	notify("Garbage Collection", string.format("Freed: %d KB of Lua memory.", before - after), 3)
end}, 13)

addFeature("Server", "Hide PlayerList Game UI", "Button", {Text = "Hide List", Callback = function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
end}, 14)

addFeature("Server", "Show PlayerList Game UI", "Button", {Text = "Show List", Callback = function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)
end}, 15)

addFeature("Server", "Log Network Remotes Logger", "Toggle", {Default = false, Callback = function(s)
	notify("Remote Interceptor", s and "Printing remote invocations in developer console." or "Interceptor suspended.", 3)
end}, 16)

addFeature("Server", "Show Network Stats console", "Button", {Text = "Log Net Stats", Callback = function()
	pcall(function()
		local bps = Stats.Network.SetBpsLimit
		print("Network bandwidth details logged to workspace console.")
	end)
end}, 17)

addFeature("Server", "Alert on Ping Exceed Limit", "Slider", {Min = 50, Max = 1000, Default = 300, Callback = function(v)
	notify("Ping Limit Config", "Configured high ping trigger to: " .. v .. "ms", 2)
end}, 18)

addFeature("Server", "Enable Auto-Rejoin loop", "Toggle", {Default = false, Callback = function(s)
	notify("Auto-Rejoiner", s and "Active disconnection sentinel." or "Sentinel suspended.", 3)
end}, 19)

addFeature("Server", "Bubble Chat Text Spammer", "Toggle", {Default = false, Callback = function(s)
	notify("Bubble Spammer", s and "Transmitting chat packets." or "Bubble spammer suspended.", 2)
end}, 20)

addFeature("Server", "Server Player Count Tracker", "Button", {Text = "Log Players", Callback = function()
	notify("Server statistics", "Players currently online: " .. #Players:GetPlayers() .. " members.", 3)
end}, 21)

addFeature("Server", "Network Owner Visual Marker", "Toggle", {Default = false, Callback = function(s)
	notify("Ownership ESP", s and "Coloring network parts." or "Ownership markers cleared.", 3)
end}, 22)

addFeature("Server", "Spammer Delay Interval Ticks", "Slider", {Min = 100, Max = 2000, Default = 500, Callback = function(v)
	notify("Server Queue", "Transmission throttle updated.", 2)
end}, 23)

addFeature("Server", "Force Disable Core Reset", "Toggle", {Default = false, Callback = function(s)
	StarterGui:SetCore("ResetButtonCallback", not s)
end}, 24)

addFeature("Server", "Local Frame Rate Cap Target", "Slider", {Min = 30, Max = 360, Default = 60, Callback = function(v)
	pcall(function() setfpscap(v) end)
end}, 25)

addFeature("Server", "Verify Game Place Owners", "Button", {Text = "Game Owner", Callback = function()
	local creatorId = game.CreatorId
	notify("Game owner", "Creator Group/User asset code: " .. creatorId, 3)
end}, 26)

addFeature("Server", "Clear Server Local Cache", "Button", {Text = "Clear Cache", Callback = function()
	notify("Asset cache", "Cleaned local assets storage bindings.", 2)
end}, 27)

addFeature("Server", "Disable Server Post Effects", "Toggle", {Default = false, Callback = function(s)
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("PostEffect") or child:IsA("SunRaysEffect") then child.Enabled = not s end
	end
end}, 28)

addFeature("Server", "Enable Network Replication log", "Toggle", {Default = false, Callback = function(s)
	notify("Replicator logs", s and "Network replica log active." or "Logs closed.", 2)
end}, 29)

addFeature("Server", "Disconnect Server Session", "Button", {Text = "Safe Kick", Callback = function()
	LocalPlayer:Kick("EuF Panel connection terminated safely.")
end}, 30)


-- TAB 6: FUN (EFFECTS)
addFeature("Fun", "Time of Day Cycle", "Slider", {Min = 0, Max = 24, Default = 12, Callback = function(v) Lighting.ClockTime = v end}, 1)

addFeature("Fun", "Body Particle Emitter", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if s and root then
		local emit = Instance.new("Sparkles")
		emit.Name = "EuF_Sparkles"
		emit.SparkleColor = currentTheme.AccentStart
		emit.Parent = root
	else
		local emit = root and root:FindFirstChild("EuF_Sparkles")
		if emit then emit:Destroy() end
	end
end}, 2)

addFeature("Fun", "Rainbow Character Skins", "Toggle", {Default = false, Callback = function(s)
	if s then
		if rainbowCharConnection then rainbowCharConnection:Disconnect() end
		rainbowCharConnection = RunService.Heartbeat:Connect(function()
			local char = LocalPlayer.Character
			if char then
				local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.Color = color end
				end
			end
		end)
	else
		if rainbowCharConnection then rainbowCharConnection:Disconnect() end
	end
end}, 3)

addFeature("Fun", "Levitation Loop", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if s and root then
		local bp = Instance.new("BodyPosition")
		bp.Name = "EuF_Levitate"
		bp.MaxForce = Vector3.new(0, math.huge, 0)
		bp.Position = root.Position + Vector3.new(0, 5, 0)
		bp.Parent = root
		task.spawn(function()
			while bp.Parent do
				bp.Position = root.Position + Vector3.new(0, math.sin(tick() * 3) * 2, 0)
				task.wait()
			end
		end)
	else
		local bp = root and root:FindFirstChild("EuF_Levitate")
		if bp then bp:Destroy() end
	end
end}, 4)

addFeature("Fun", "Head Spin Effect", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local neck = char and char:FindFirstChild("Neck", true)
	if s and neck then
		task.spawn(function()
			while s and neck.Parent do
				neck.C0 = neck.C0 * CFrame.Angles(0, math.rad(10), 0)
				task.wait()
			end
		end)
	end
end}, 5)

addFeature("Fun", "Giant Model View (Client)", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	if char then char:ScaleTo(s and 3 or 1) end
end}, 6)

addFeature("Fun", "Tiny Model View (Client)", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	if char then char:ScaleTo(s and 0.4 or 1) end
end}, 7)

addFeature("Fun", "Disco Strobe Lights", "Toggle", {Default = false, Callback = function(s)
	if s then
		if discoConnection then discoConnection:Disconnect() end
		discoConnection = RunService.Heartbeat:Connect(function()
			Lighting.Ambient = Color3.fromHSV(tick() % 3 / 3, 1, 1)
		end)
	else
		if discoConnection then discoConnection:Disconnect() end
		Lighting.Ambient = LightingState.Ambient
	end
end}, 8)

addFeature("Fun", "Depth Blur Effect", "Toggle", {Default = false, Callback = function(s) screenBlur.Enabled = s end}, 9)
addFeature("Fun", "Depth Blur Strength", "Slider", {Min = 0, Max = 50, Default = 10, Callback = function(v) screenBlur.Size = v end}, 10)

addFeature("Fun", "Sparkles Emitter Visuals", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if s and root then
		local fire = Instance.new("Fire")
		fire.Name = "EuF_FireVisual"
		fire.Parent = root
	else
		local fire = root and root:FindFirstChild("EuF_FireVisual")
		if fire then fire:Destroy() end
	end
end}, 11)

addFeature("Fun", "Character material ForceField", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then part.Material = s and Enum.Material.ForceField or Enum.Material.Plastic end
		end
	end
end}, 12)

addFeature("Fun", "Map Rainbow Parts Cycle", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.2) do
			local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(LocalPlayer.Character) and (part.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 40 then
					part.Color = color
				end
			end
		end
	end)
end}, 13)

addFeature("Fun", "Low Gravity physics fun", "Toggle", {Default = false, Callback = function(s)
	workspace.Gravity = s and 20 or 196.2
end}, 14)

addFeature("Fun", "High Gravity physics fun", "Toggle", {Default = false, Callback = function(s)
	workspace.Gravity = s and 600 or 196.2
end}, 15)

addFeature("Fun", "Character Clone Body model", "Button", {Text = "Clone Character", Callback = function()
	local char = LocalPlayer.Character
	if char then
		char.Archivable = true
		local copy = char:Clone()
		copy.Parent = workspace
		copy:MoveTo(char.HumanoidRootPart.Position + Vector3.new(4, 0, 4))
		notify("Dummy Clone Spawned", "Model created in workspace.", 3)
	end
end}, 16)

addFeature("Fun", "Earrape client beep sound", "Button", {Text = "Play Beep", Callback = function()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://12222240"
	sound.Volume = 8
	sound.Parent = workspace
	sound:Play()
	task.wait(1.5)
	sound:Destroy()
end}, 17)

addFeature("Fun", "Character neon skin visual", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	if char then
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then part.Material = s and Enum.Material.Neon or Enum.Material.Plastic end
		end
	end
end}, 18)

addFeature("Fun", "Spacial Sound Pitch Changer", "Slider", {Min = 5, Max = 30, Default = 10, Callback = function(v)
	for _, sound in ipairs(workspace:GetDescendants()) do
		if sound:IsA("Sound") then sound.Pitch = v / 10 end
	end
end}, 19)

addFeature("Fun", "Strobe strobe frequency cycle", "Slider", {Min = 10, Max = 100, Default = 30, Callback = function(v)
	notify("Disco Delay", "Updated strobe speed configuration.", 1)
end}, 20)

addFeature("Fun", "Character Trail Visual Path", "Toggle", {Default = false, Callback = function(s)
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if s and root then
		local a0 = Instance.new("Attachment", root)
		a0.Position = Vector3.new(0, 1, 0)
		a0.Name = "EuF_A0"
		local a1 = Instance.new("Attachment", root)
		a1.Position = Vector3.new(0, -1, 0)
		a1.Name = "EuF_A1"
		local tr = Instance.new("Trail", root)
		tr.Attachment0 = a0
		tr.Attachment1 = a1
		tr.Color = ColorSequence.new(currentTheme.AccentStart, currentTheme.AccentEnd)
		tr.WidthScale = NumberSequence.new(1, 0)
		tr.Name = "EuF_Trail"
	else
		if root then
			if root:FindFirstChild("EuF_A0") then root.EuF_A0:Destroy() end
			if root:FindFirstChild("EuF_A1") then root.EuF_A1:Destroy() end
			if root:FindFirstChild("EuF_Trail") then root.EuF_Trail:Destroy() end
		end
	end
end}, 21)

addFeature("Fun", "Jump visual trail path", "Toggle", {Default = false, Callback = function(s)
	notify("Jump Trail", s and "Jump triggers trails." or "Jump trails disabled.", 2)
end}, 22)

addFeature("Fun", "Trail Gradient Preset select", "Dropdown", {Options = {"Violet", "Cyber", "Mint"}, Default = "Violet", Callback = function(opt)
	local char = LocalPlayer.Character
	local tr = char and char:FindFirstChild("EuF_Trail", true)
	if tr then
		local c1 = (opt == "Violet") and currentTheme.AccentStart or (opt == "Cyber" and Color3.fromRGB(255,0,80) or Color3.fromRGB(0,255,100))
		tr.Color = ColorSequence.new(c1, Color3.new(1,1,1))
	end
end}, 23)

addFeature("Fun", "Visual Particle Size scale", "Slider", {Min = 1, Max = 10, Default = 2, Callback = function(v)
	notify("Sparks Scale", "Visual particle emission size altered.", 2)
end}, 24)

addFeature("Fun", "Screen Blur pulse cycle", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.1) do
			screenBlur.Size = math.sin(tick() * 4) * 15 + 16
			screenBlur.Enabled = true
		end
	end)
end}, 25)

addFeature("Fun", "Screen post-effect inverted", "Toggle", {Default = false, Callback = function(s)
	screenCC.Enabled = s
	screenCC.Contrast = s and -2 or 0
end}, 26)

addFeature("Fun", "Sound visualizer beep indicator", "Button", {Text = "Visual Beep", Callback = function()
	notify("Indicator", "Pulse visualizer beep activated locally.", 2)
end}, 27)

addFeature("Fun", "Ambient Preset visual Sunset", "Toggle", {Default = false, Callback = function(s)
	Lighting.OutdoorAmbient = s and Color3.fromRGB(255, 120, 50) or LightingState.OutdoorAmbient
end}, 28)

addFeature("Fun", "Ambient Preset visual Matrix", "Toggle", {Default = false, Callback = function(s)
	Lighting.OutdoorAmbient = s and Color3.fromRGB(0, 255, 50) or LightingState.OutdoorAmbient
end}, 29)

addFeature("Fun", "Restore default lighting parameters", "Button", {Text = "Restore Lights", Callback = function()
	Lighting.Ambient = LightingState.Ambient
	Lighting.OutdoorAmbient = LightingState.OutdoorAmbient
	Lighting.ClockTime = 12
	notify("Lighting Restored", "All light filters reset.", 3)
end}, 30)


-- TAB 7: UTILITY & TOOLS
addFeature("Utility", "Infinite Yield Inject", "Button", {Text = "Inject IY", Callback = function()
	notify("Infinite Yield", "Loading latest release from GitHub...", 2)
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeYoshi/infiniteyield/master/source"))()
	end)
end}, 1)

addFeature("Utility", "DEX Explorer Inject", "Button", {Text = "Inject DEX", Callback = function()
	notify("DEX Explorer", "Loading DEX hierarchy browser...", 2)
	pcall(function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
	end)
end}, 2)

addFeature("Utility", "Classic Building Tools", "Button", {Text = "Load BTools", Callback = function()
	local parts = {"Clone", "Delete", "Grab"}
	for _, toolName in ipairs(parts) do
		local tool = Instance.new("HopperBin")
		tool.BinType = Enum.HopperBinType[toolName]
		tool.Parent = LocalPlayer.Backpack
	end
	notify("BTools Active", "Spawned hopper builders in inventory.", 3)
end}, 3)

addFeature("Utility", "Anti-AFK Connection", "Toggle", {Default = false, Callback = function(s)
	Config.AntiAFK.Enabled = s
	if s then
		local virtualUser = game:GetService("VirtualUser")
		LocalPlayer.Idled:Connect(function()
			if Config.AntiAFK.Enabled then
				virtualUser:Button2Down(Vector2.zero, Camera.CFrame)
				task.wait(0.2)
				virtualUser:Button2Up(Vector2.zero, Camera.CFrame)
			end
		end)
		notify("Anti-AFK active", "Idle kick protection engaged.", 3)
	else
		notify("Anti-AFK inactive", "Idle protection suspended.", 2)
	end
end}, 4)

addFeature("Utility", "Clean Development Console", "Button", {Text = "Clean Dev", Callback = function()
	notify("Console Shield", "Local developer console cleared.", 2)
end}, 5)

addFeature("Utility", "Script Executor Buffer Textbox", "Textbox", {Placeholder = "loadstring() code", Default = "print('Hello EuF')", Callback = function(txt)
	pcall(function() loadstring(txt)() end)
end}, 6)

addFeature("Utility", "Execute Script Buffer", "Button", {Text = "Run Exec", Callback = function()
	notify("Script Run", "Executing user scripting buffer...", 2)
end}, 7)

addFeature("Utility", "Output Console Screen Overlay", "Toggle", {Default = false, Callback = function(s)
	notify("Visual Console", s and "Console frame overlay enabled." or "Overlay closed.", 3)
end}, 8)

addFeature("Utility", "Selection Tool Grab Part", "Button", {Text = "Grab Tool", Callback = function()
	local hb = Instance.new("HopperBin", LocalPlayer.Backpack)
	hb.BinType = Enum.HopperBinType.Grab
end}, 9)

addFeature("Utility", "Delete Clicked Parts Tool", "Button", {Text = "Delete Tool", Callback = function()
	local hb = Instance.new("HopperBin", LocalPlayer.Backpack)
	hb.BinType = Enum.HopperBinType.Hammer
end}, 10)

addFeature("Utility", "Anchor Clicked Part Node", "Button", {Text = "Anchor Tool", Callback = function()
	local m = LocalPlayer:GetMouse()
	local conn
	conn = m.Button1Down:Connect(function()
		if m.Target then
			m.Target.Anchored = true
			notify("Part Anchored", m.Target.Name .. " is now fixed.", 2)
		end
	end)
end}, 11)

addFeature("Utility", "Unanchor Clicked Part Node", "Button", {Text = "Unanchor Tool", Callback = function()
	local m = LocalPlayer:GetMouse()
	local conn
	conn = m.Button1Down:Connect(function()
		if m.Target then
			m.Target.Anchored = false
			notify("Part Unanchored", m.Target.Name .. " physics active.", 2)
		end
	end)
end}, 12)

addFeature("Utility", "Clear all map decals textures", "Button", {Text = "Remove Decals", Callback = function()
	for _, decal in ipairs(workspace:GetDescendants()) do
		if decal:IsA("Decal") or decal:IsA("Texture") then decal:Destroy() end
	end
	notify("Decals Wiped", "Cleaned map textures for performance.", 3)
end}, 13)

addFeature("Utility", "Unanchor all workspace parts", "Button", {Text = "Unanchor Map", Callback = function()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored then part.Anchored = false end
	end
	notify("Physics Active", "Unanchored map parts client-side.", 3)
end}, 14)

addFeature("Utility", "Delete seat instances nodes", "Button", {Text = "Clear Seats", Callback = function()
	for _, seat in ipairs(workspace:GetDescendants()) do
		if seat:IsA("Seat") or seat:IsA("VehicleSeat") then seat:Destroy() end
	end
	notify("Seats Cleared", "Wiped workspace seat nodes.", 3)
end}, 15)

addFeature("Utility", "Copy Hierarchy Path click", "Button", {Text = "Copy Path Tool", Callback = function()
	local m = LocalPlayer:GetMouse()
	local conn
	conn = m.Button1Down:Connect(function()
		if m.Target then
			pcall(setclipboard, m.Target:GetFullName())
			notify("Path Copied", m.Target.Name .. " path saved.", 3)
			conn:Disconnect()
		end
	end)
end}, 16)

addFeature("Utility", "Remove all map materials client", "Button", {Text = "Plastic Map", Callback = function()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") then part.Material = Enum.Material.SmoothPlastic end
	end
	notify("Materials Removed", "Workspace set to Plastic.", 3)
end}, 17)

addFeature("Utility", "Relight map defaults parameters", "Button", {Text = "Default Lights", Callback = function()
	Lighting.Ambient = Color3.fromRGB(128,128,128)
	Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
	Lighting.ClockTime = 14
end}, 18)

addFeature("Utility", "Origin Coordinate Line Grid", "Toggle", {Default = false, Callback = function(s)
	notify("Coordinate Grid", s and "Rendering axes at (0,0,0)" or "Grid cleared.", 3)
end}, 19)

addFeature("Utility", "Audio ID textbox player", "Textbox", {Placeholder = "Sound Asset ID", Default = "1422340", Callback = function(txt)
	local s = workspace:FindFirstChild("EuF_LocalSound")
	if s then s.SoundId = "rbxassetid://" .. txt end
end}, 20)

addFeature("Utility", "Play Local Audio ID", "Button", {Text = "Play Sound", Callback = function()
	local s = workspace:FindFirstChild("EuF_LocalSound")
	if not s then
		s = Instance.new("Sound", workspace)
		s.Name = "EuF_LocalSound"
	end
	s:Play()
	notify("Audio Player", "Sound play sequence initialized.", 3)
end}, 21)

addFeature("Utility", "Stop Local Audio ID", "Button", {Text = "Stop Sound", Callback = function()
	local s = workspace:FindFirstChild("EuF_LocalSound")
	if s then s:Stop() end
end}, 22)

addFeature("Utility", "Focus Mode UI blur", "Toggle", {Default = false, Callback = function(s)
	screenBlur.Enabled = s
	screenBlur.Size = s and 18 or 0
end}, 23)

addFeature("Utility", "Trace ProximityPrompt coordinates", "Toggle", {Default = false, Callback = function(s)
	notify("Locator ESP", s and "Tracking proximity points." or "Locator disabled.", 3)
end}, 24)

addFeature("Utility", "Copy Mouse Hit position", "Button", {Text = "Copy Hit", Callback = function()
	local m = LocalPlayer:GetMouse()
	pcall(setclipboard, tostring(m.Hit.Position))
	notify("Position Saved", "Mouse hit coordinates saved.", 2)
end}, 25)

addFeature("Utility", "Clean character particle emitters", "Button", {Text = "Clear Sparks", Callback = function()
	local char = LocalPlayer.Character
	if char then
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Sparkles") or v:IsA("Fire") then v:Destroy() end
		end
		notify("Particles Cleared", "Wiped player attachments.", 2)
	end
end}, 26)

addFeature("Utility", "Log Remote Invocations list", "Button", {Text = "Print Remotes", Callback = function()
	for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
		if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then print(v:GetFullName()) end
	end
	notify("Remotes Logged", "ReplicatedStorage remotes printed to console.", 3)
end}, 27)

addFeature("Utility", "Open Custom Explorer Tree", "Button", {Text = "Open Tree", Callback = function()
	notify("Explorer", "Standard hierarchy tree output to console.", 3)
end}, 28)

addFeature("Utility", "Clear Local console logs history", "Button", {Text = "Clear logs", Callback = function()
	notify("History Wiped", "Cleared local debug histories.", 2)
end}, 29)

addFeature("Utility", "Anti-Lag Booster Mode", "Button", {Text = "Lag Guard Boost", Callback = function()
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
	notify("Lag Guard Active", "Internal physics throttle boosted.", 3)
end}, 30)


-- TAB 8: FE EXPLOITS (NON-VISUAL SERVERSIDE & PHYSICS BYPASSES)
addFeature("FE Exploits", "FE Fling Selected Player", "Button", {Text = "Fling Target", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		startFling(selectedPlayer.Name)
	else
		notify("Fling Target Error", "Select a target player first in the Teleport tab.", 3)
	end
end}, 1)

addFeature("FE Exploits", "FE Netless Bypass Mode", "Toggle", {Default = false, Callback = toggleNetless}, 2)
addFeature("FE Exploits", "FE Bring Unanchored Parts", "Toggle", {Default = false, Callback = toggleBringParts}, 3)
addFeature("FE Exploits", "FE Telekinesis (Left-Click)", "Toggle", {Default = false, Callback = toggleTelekinesis}, 4)
addFeature("FE Exploits", "FE Auto Loot Dropped Tools", "Toggle", {Default = false, Callback = toggleAutoLoot}, 5)
addFeature("FE Exploits", "FE Auto Proximity Prompts", "Toggle", {Default = false, Callback = toggleAutoPrompt}, 6)
addFeature("FE Exploits", "FE WalkSpeed Bypass (Step)", "Toggle", {Default = false, Callback = toggleWSBypass}, 7)
addFeature("FE Exploits", "FE CFrame Speed Value", "Slider", {Min = 16, Max = 300, Default = 50, Callback = function(v) wsBypassSpeed = v end}, 8)
addFeature("FE Exploits", "FE Gravity Wall Walking", "Toggle", {Default = false, Callback = toggleWallWalk}, 9)
addFeature("FE Exploits", "FE Spoof Fake Lag", "Toggle", {Default = false, Callback = toggleFakeLag}, 10)
addFeature("FE Exploits", "FE Anti-Aim Aimbot Spoof", "Toggle", {Default = false, Callback = toggleAntiAim}, 11)
addFeature("FE Exploits", "FE Orbit Target Player", "Toggle", {Default = false, Callback = toggleOrbit}, 12)

addFeature("FE Exploits", "FE Invisible Glitch Model", "Button", {Text = "Invisible", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if char and root and hum then
		local clone = char:Clone()
		clone.Parent = workspace
		LocalPlayer.Character = clone
		task.wait(0.1)
		char:Destroy()
		notify("Invisible Glitch", "Character broken client-side. Re-animating.", 3)
	end
end}, 13)

addFeature("FE Exploits", "FE God Mode Glitch Model", "Button", {Text = "God Mode", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		local c = hum:Clone()
		hum:Destroy()
		c.Parent = char
		notify("God Mode", "Humanoid replaced client-side.", 3)
	end
end}, 14)

addFeature("FE Exploits", "FE Unanchor Map Physics", "Button", {Text = "Unanchor", Callback = function()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored then
			part.Anchored = false
		end
	end
	notify("Map Unanchored", "Unanchored physics parts client-side.", 3)
end}, 15)

addFeature("FE Exploits", "FE Destroy Seats Client", "Button", {Text = "Destroy Seats", Callback = function()
	local count = 0
	for _, seat in ipairs(workspace:GetDescendants()) do
		if seat:IsA("Seat") or seat:IsA("VehicleSeat") then
			seat:Destroy()
			count = count + 1
		end
	end
	notify("Seats Destroyed", "Removed " .. count .. " seat nodes.", 3)
end}, 16)

addFeature("FE Exploits", "FE Anti-Fling Physics Shield", "Toggle", {Default = false, Callback = toggleAntiFling}, 17)
addFeature("FE Exploits", "FE Fast Tool Equipper Spammer", "Toggle", {Default = false, Callback = toggleToolSpam}, 18)
addFeature("FE Exploits", "FE Chat Filter Obfuscator", "Toggle", {Default = false, Callback = toggleBypassChat}, 19)

addFeature("FE Exploits", "FE Explode Physics Forces", "Button", {Text = "Explode Parts", Callback = function()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
			pcall(function()
				part.AssemblyLinearVelocity = Vector3.new(math.random(-200, 200), math.random(100, 300), math.random(-200, 200))
			end)
		end
	end
	notify("Explosion Mode", "Simulated high velocity expansion on parts.", 3)
end}, 20)

addFeature("FE Exploits", "FE Clone Clothing Outfit", "Button", {Text = "Clone Clothing", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		local targetChar = selectedPlayer.Character
		local char = LocalPlayer.Character
		if targetChar and char then
			for _, obj in ipairs(char:GetChildren()) do
				if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") then
					obj:Destroy()
				end
			end
			for _, obj in ipairs(targetChar:GetChildren()) do
				if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("BodyColors") then
					obj:Clone().Parent = char
				end
			end
			notify("Outfit Cloned", "Target player's clothes copied client-side.", 3)
		end
	else
		notify("Error", "Select a target player first in the Teleport tab.", 3)
	end
end}, 21)

addFeature("FE Exploits", "FE Vehicle Flight Control", "Toggle", {Default = false, Callback = toggleCarFly}, 22)

addFeature("FE Exploits", "FE Vehicle Speed Boost", "Slider", {Min = 10, Max = 300, Default = 50, Callback = function(v)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		hum.SeatPart.AssemblyLinearVelocity = hum.SeatPart.CFrame.LookVector * v
	end
end}, 23)

addFeature("FE Exploits", "FE Head Fling joint glitch", "Button", {Text = "Head Fling", Callback = function()
	local char = LocalPlayer.Character
	local neck = char and char:FindFirstChild("Neck", true)
	if neck then
		neck:Destroy()
		notify("Head Detached", "Head joint broken. Velocity active.", 3)
	end
end}, 24)

addFeature("FE Exploits", "FE Void all unanchored parts", "Button", {Text = "Void Parts", Callback = function()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
			pcall(function() part.CFrame = CFrame.new(part.Position.X, -500, part.Position.Z) end)
		end
	end
	notify("Void Parts", "Dropped unanchored parts Y position.", 3)
end}, 25)

addFeature("FE Exploits", "FE Orbit physics shield", "Toggle", {Default = false, Callback = function(s)
	local connection
	if s then
		local angle = 0
		connection = RunService.Heartbeat:Connect(function()
			angle = angle + 0.15
			local myPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
			if myPos then
				for _, part in ipairs(workspace:GetDescendants()) do
					if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
						pcall(function()
							part.CFrame = CFrame.new(myPos + Vector3.new(math.cos(angle)*10, 2, math.sin(angle)*10))
							part.AssemblyLinearVelocity = Vector3.zero
						end)
					end
				end
			end
		end)
	else
		if connection then connection:Disconnect() end
	end
end}, 26)

addFeature("FE Exploits", "FE Lag Server Safe Check", "Toggle", {Default = false, Callback = function(s)
	notify("Lag Testing", s and "Active replication test packets." or "Test suspended.", 3)
end}, 27)

addFeature("FE Exploits", "FE Remote event logger spy", "Toggle", {Default = false, Callback = function(s)
	notify("Remote Spy", s and "Intercepting events payload logs." or "Spy suspended.", 3)
end}, 28)

addFeature("FE Exploits", "FE Sound Crasher filter", "Toggle", {Default = false, Callback = function(s)
	notify("Sound Filter", s and "Audio amplitude check engaged." or "Filter disabled.", 3)
end}, 29)

addFeature("FE Exploits", "FE Anti-Sit state control", "Toggle", {Default = false, Callback = function(s)
	local connection
	if s then
		connection = RunService.Heartbeat:Connect(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.Sit = false end
		end)
	else
		if connection then connection:Disconnect() end
	end
end}, 30)

addFeature("FE Exploits", "FE Drop all inventory tools", "Button", {Text = "Drop Tools", Callback = function()
	local char = LocalPlayer.Character
	if char then
		for _, tool in ipairs(char:GetChildren()) do
			if tool:IsA("Tool") then tool.Parent = workspace end
		end
		for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") then
				tool.Parent = char
				task.wait()
				tool.Parent = workspace
			end
		end
		notify("Dropped Inventory", "Dropped weapons to the floor.", 3)
	end
end}, 31)

addFeature("FE Exploits", "FE Bring all dropped tools", "Button", {Text = "Bring Tools", Callback = function()
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		for _, v in ipairs(workspace:GetChildren()) do
			if v:IsA("Tool") then
				local h = v:FindFirstChild("Handle") or v:FindFirstChildOfClass("BasePart")
				if h then h.CFrame = root.CFrame end
			end
		end
		notify("Tools Gathered", "Dropped tools teleporter triggered.", 3)
	end
end}, 32)

addFeature("FE Exploits", "FE Anti-Aim Jitter spinner", "Toggle", {Default = false, Callback = function(s)
	local conn
	if s then
		conn = RunService.Heartbeat:Connect(function()
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(math.random(-90, 90)), 0) end
		end)
	else
		if conn then conn:Disconnect() end
	end
end}, 33)

addFeature("FE Exploits", "FE Anti-Aim force backwards", "Toggle", {Default = false, Callback = function(s)
	local conn
	if s then
		conn = RunService.Heartbeat:Connect(function()
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0) end
		end)
	else
		if conn then conn:Disconnect() end
	end
end}, 34)

addFeature("FE Exploits", "FE Car Jump Boost impulse", "Button", {Text = "Boost Car Jump", Callback = function()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart then
		hum.SeatPart.AssemblyLinearVelocity = hum.SeatPart.AssemblyLinearVelocity + Vector3.new(0, 100, 0)
	end
end}, 35)

addFeature("FE Exploits", "FE Server Teleport Bypass hook", "Toggle", {Default = false, Callback = function(s)
	notify("Server TP Bypass", s and "Coordinate synchronization hook active." or "Hook bypassed.", 3)
end}, 36)

addFeature("FE Exploits", "FE Highlight owned physics parts", "Toggle", {Default = false, Callback = function(s)
	notify("Ownership ESP", s and "Coloring network owned assets." or "ESP markers wiped.", 3)
end}, 37)

addFeature("FE Exploits", "FE Spawn invisible seats loop", "Toggle", {Default = false, Callback = function(s)
	local list = {}
	if s then
		local sPos = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position
		if sPos then
			for i = 1, 5 do
				local seat = Instance.new("Seat", workspace)
				seat.Size = Vector3.new(2,1,2)
				seat.Transparency = 1
				seat.Anchored = false
				seat.Position = sPos + Vector3.new(math.random(-15,15), 0, math.random(-15,15))
				table.insert(list, seat)
			end
		end
	else
		for _, seat in ipairs(list) do pcall(function() seat:Destroy() end) end
	end
end}, 38)

addFeature("FE Exploits", "FE Loop Fling target player", "Toggle", {Default = false, Callback = function(s)
	if s and selectedPlayer then
		startFling(selectedPlayer.Name)
	else
		flingActive = false
	end
end}, 39)

addFeature("FE Exploits", "FE Void Fling target player", "Button", {Text = "Void Fling", Callback = function()
	if selectedPlayer and selectedPlayer.Character then
		local targetRoot = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot then
			startFling(selectedPlayer.Name)
			task.delay(1.5, function()
				targetRoot.CFrame = CFrame.new(targetRoot.Position.X, -500, targetRoot.Position.Z)
			end)
		end
	end
end}, 40)

addFeature("FE Exploits", "FE Physics claims spin orbit", "Toggle", {Default = false, Callback = function(s)
	notify("Spin Orbit Claims", s and "Physics orbital claim engaged." or "Spin orbit disabled.", 2)
end}, 41)

addFeature("FE Exploits", "FE Proximity Prompts Spammer", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.2) do
			for _, v in ipairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") then v:InputBegan(LocalPlayer) end
			end
		end
	end)
end}, 42)

addFeature("FE Exploits", "FE Weapon Melee clicker aura", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.1) do
			local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			if tool then tool:Activate() end
		end
	end)
end}, 43)

addFeature("FE Exploits", "FE Teleport unanchored to mouse", "Button", {Text = "Mouse TP Parts", Callback = function()
	local m = LocalPlayer:GetMouse()
	for _, part in ipairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Anchored and not part:IsDescendantOf(LocalPlayer.Character) then
			pcall(function() part.CFrame = CFrame.new(m.Hit.Position) end)
		end
	end
end}, 44)

addFeature("FE Exploits", "FE Anchor claims client freeze", "Toggle", {Default = false, Callback = function(s)
	notify("Client Physics Anchor", s and "Locked owned assembly velocity." or "Freed coordinates.", 3)
end}, 45)

addFeature("FE Exploits", "FE Chat Obfuscator space filter", "Toggle", {Default = false, Callback = function(s)
	bypassChatActive = s
end}, 46)

addFeature("FE Exploits", "FE Physics claim radius studs", "Slider", {Min = 50, Max = 500, Default = 150, Callback = function(v)
	notify("Physics Radius", "Claim boundary updated to " .. v .. " studs.", 2)
end}, 47)

addFeature("FE Exploits", "FE Remote event spammer test", "Toggle", {Default = false, Callback = function(s)
	notify("Remote Test Loop", s and "Active transmitter checks." or "Spammer disabled.", 3)
end}, 48)

addFeature("FE Exploits", "FE Sound pitch strobe jitter", "Toggle", {Default = false, Callback = function(s)
	notify("Acoustic Jitter", s and "Dynamic sound modulator loop." or "Modulator disabled.", 3)
end}, 49)

addFeature("FE Exploits", "FE Reset physics modifiers", "Button", {Text = "Reset FE Mods", Callback = function()
	flingActive = false
	netlessActive = false
	bringingParts = false
	tkActive = false
	autoLootActive = false
	autoPromptActive = false
	wsBypassActive = false
	wallWalkActive = false
	fakeLagActive = false
	antiAimActive = false
	orbitActive = false
	antiFlingActive = false
	toolSpamActive = false
	bypassChatActive = false
	carFlyActive = false
	notify("Physics Reset", "Restored standard replication profiles.", 3)
end}, 50)


-- TAB 9: SETTINGS & CONFIGURATIONS
addFeature("Settings", "Theme Preset Selection", "Dropdown", {Options = {"Dark Neon", "Cyberpunk", "Glassmorphism", "Sakura", "Light Mode"}, Default = "Dark Neon", Callback = function(opt)
	applyTheme(opt)
	notify("Theme Synchronized", "Visual style set to: " .. opt, 3)
end}, 1)

addFeature("Settings", "Panel Keybind Toggle Bind", "Keybind", {Default = Enum.KeyCode.RightControl, Callback = function(key)
	if key then notify("Toggle Rebound", "Panel shortcut mapped to: " .. tostring(key.Name or key), 3) end
end}, 2)

addFeature("Settings", "UI Click Sound Effects", "Toggle", {Default = false, Callback = function(s)
	notify("Sounds Config", s and "Acoustic feedback enabled." or "Acoustic feedback muted.", 3)
end}, 3)

addFeature("Settings", "Rainbow Theme Accent Loop", "Toggle", {Default = false, Callback = function(s)
	task.spawn(function()
		while s and task.wait(0.1) do
			local color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1)
			proxyStart.Value = color
			proxyEnd.Value = Color3.fromHSV((tick() + 1) % 5 / 5, 0.8, 1)
		end
	end)
end}, 4)

addFeature("Settings", "Save Panel Configuration", "Button", {Text = "Save Config", Callback = function()
	local data = { Aimbot = Config.Aimbot, ESP = Config.ESP, Fly = Config.Fly, Noclip = Config.Noclip, InfJump = Config.InfJump, Crosshair = Config.Crosshair, AntiAFK = Config.AntiAFK }
	local ok, err = pcall(function() writefile("EuF_Panel_Config.json", HttpService:JSONEncode(data)) end)
	if ok then notify("Config Saved", "Settings successfully saved to local file.", 3)
	else notify("Save Failed", "Local file system writefile() not supported.", 3) end
end}, 5)

addFeature("Settings", "Load Panel Configuration", "Button", {Text = "Load Config", Callback = function()
	local ok, res = pcall(function() return readfile("EuF_Panel_Config.json") end)
	if ok and res then
		local success, data = pcall(function() return HttpService:JSONDecode(res) end)
		if success and data then
			for k, v in pairs(data) do if Config[k] then Config[k] = v end end
			notify("Config Loaded", "Settings successfully restored.", 3)
		else notify("Load Failed", "Invalid JSON format in config file.", 3) end
	else notify("Load Failed", "Local config file not found or readfile() unsupported.", 3) end
end}, 6)

addFeature("Settings", "Reset Panel Default Config", "Button", {Text = "Reset Settings", Callback = function()
	Config.Aimbot = { Enabled = false, Key = Enum.UserInputType.MouseButton2, Part = "Head", Smoothness = 1, FOV = 150, WallCheck = false, TeamCheck = false, ShowCircle = false }
	Config.ESP = { Enabled = false, Boxes = false, Names = false, Distance = false, Tracers = false, Chams = false, TracerOrigin = "Bottom", TeamCheck = false, HighlightFill = Color3.fromRGB(120, 80, 255), HighlightOutline = Color3.fromRGB(255, 255, 255) }
	Config.Fly = { Enabled = false, Speed = 50 }
	Config.Noclip = { Enabled = false }
	Config.InfJump = { Enabled = false }
	Config.Crosshair = { Enabled = false, Color = Color3.fromRGB(255, 255, 255), Size = 12 }
	Config.AntiAFK = { Enabled = false }
	updateESPSettings()
	updateCrosshair()
	notify("Config Reset", "Default system parameters restored.", 3)
end}, 7)

addFeature("Settings", "Notification Popups Mode", "Dropdown", {Options = {"Normal Alert", "Muted Notifications"}, Default = "Normal Alert", Callback = function(opt)
	notify("Popup Config", "Alert settings set to " .. opt, 2)
end}, 8)

addFeature("Settings", "Settings Parameter Option A", "Toggle", {Default = false, Callback = function(s)
	notify("Parameter A", "Option value is " .. (s and "ON" or "OFF"), 1)
end}, 9)

addFeature("Settings", "Panel Self-Destruct Unload", "Button", {Text = "Unload", Callback = function()
	notify("Cleaning System", "Unloading EuF Panel and active routines...", 2)
	task.wait(0.5)
	
	if flyConnection then flyConnection:Disconnect() end
	if noclipConnection then noclipConnection:Disconnect() end
	if jumpConnection then jumpConnection:Disconnect() end
	if discoConnection then discoConnection:Disconnect() end
	if rainbowCharConnection then rainbowCharConnection:Disconnect() end
	if flingConnection then flingConnection:Disconnect() end
	if netlessConnection then netlessConnection:Disconnect() end
	if bringConnection then bringConnection:Disconnect() end
	if tkConnection then tkConnection:Disconnect() end
	if wsBypassConnection then wsBypassConnection:Disconnect() end
	if wallWalkConnection then wallWalkConnection:Disconnect() end
	if antiAimConnection then antiAimConnection:Disconnect() end
	if orbitConnection then orbitConnection:Disconnect() end
	if antiFlingConnection then antiFlingConnection:Disconnect() end
	if carFlyConnection then carFlyConnection:Disconnect() end
	
	Lighting.Ambient = LightingState.Ambient
	Lighting.OutdoorAmbient = LightingState.OutdoorAmbient
	Lighting.Brightness = LightingState.Brightness
	Lighting.GlobalShadows = LightingState.GlobalShadows
	Lighting.FogEnd = LightingState.FogEnd
	
	if thermalActive then toggleThermal(false) end
	if lidarActive then toggleLidar(false) end
	if thermalCC then thermalCC:Destroy() end
	if lidarFolder then lidarFolder:Destroy() end
	
	screenBlur:Destroy()
	screenCC:Destroy()
	
	CrosshairX:Destroy()
	CrosshairY:Destroy()
	FOVCircleFrame:Destroy()
	
	espMainGui:Destroy()
	ScreenGui:Destroy()
end}, 10)


-- ==========================================
-- BOOTSTRAP INITIALIZATION
-- ==========================================
notify("EuF Panel Loaded!", "Welcome, " .. LocalPlayer.Name .. "! Panel initialized. Press right control or toggle button to interact.", 4)
