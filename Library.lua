local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Theme = {
	Bg0 = Color3.fromHex("0A0713"),
	Bg1 = Color3.fromHex("120C20"),
	Bg2 = Color3.fromHex("1A132D"),
	Bg3 = Color3.fromHex("241A3C"),
	Line = Color3.fromHex("2E2148"),
	Purple1 = Color3.fromHex("8B5CF6"),
	Purple2 = Color3.fromHex("A78BFA"),
	PurpleGlow = Color3.fromHex("7C3AED"),
	Text0 = Color3.fromHex("F1EDFB"),
	Text1 = Color3.fromHex("B6ACD6"),
	Text2 = Color3.fromHex("75699A"),
}

local FONT = Font.fromEnum(Enum.Font.Gotham)
local FONT_BOLD = Font.fromEnum(Enum.Font.GothamBold)
local FONT_MEDIUM = Font.fromEnum(Enum.Font.GothamMedium)

local CHECK_IMAGE = "rbxassetid://3926305904"
local CHECK_RECT_OFFSET = Vector2.new(312, 4)
local CHECK_RECT_SIZE = Vector2.new(24, 24)

local function new(class: string, props: {[string]: any}, children: {Instance}?)
	local inst = Instance.new(class)
	for prop, value in pairs(props) do
		(inst :: any)[prop] = value
	end
	if children then
		for _, child in ipairs(children) do
			child.Parent = inst
		end
	end
	return inst
end

local function corner(radius: number)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color: Color3, thickness: number?, transparency: number?)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
	})
end

local function gradient(rotation: number?)
	local g = new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("A855F7")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("6D28D9")),
		}),
		Rotation = rotation or 135,
	})
	return g
end

local function tween(inst: Instance, props: {[string]: any}, time: number?, style: Enum.EasingStyle?)
	local t = TweenService:Create(
		inst :: any,
		TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function countDecimals(n: number): number
	local s = tostring(n)
	local dot = string.find(s, ".", 1, true)
	if dot then
		return #s - dot
	end
	return 0
end

local function newBinder(window)
	local list = {}
	local function bind(conn: RBXScriptConnection)
		table.insert(list, conn)
		if window and window._track then
			window._track(conn)
		end
		return conn
	end
	local function unbindAll()
		for _, c in ipairs(list) do
			c:Disconnect()
		end
		table.clear(list)
	end
	return bind, unbindAll
end

local function buildApi(Row: GuiObject, textLabel: (TextLabel | TextButton)?, api: {[string]: any}, onDestroy: (() -> ())?, onHide: (() -> ())?)
	api.Instance = Row
	api.SetText = api.SetText or function(_, text: string)
		if textLabel then
			textLabel.Text = text
		end
	end
	api.SetVisible = function(_, visible: boolean)
		Row.Visible = visible
		if not visible and onHide then
			onHide()
		end
	end
	api.Destroy = function()
		if onDestroy then
			onDestroy()
		end
		Row:Destroy()
	end
	return api
end

local function makeDraggable(handle: GuiObject, target: GuiObject, onClick: (() -> ())?, shouldBlock: (() -> boolean)?, track: ((RBXScriptConnection) -> RBXScriptConnection)?)
	local dragging = false
	local moved = false
	local dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if shouldBlock and shouldBlock() then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			dragStart = input.Position
			startPos = target.Position
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if conn then
						conn:Disconnect()
					end
					if not moved and onClick then
						onClick()
					end
				end
			end)
		end
	end)

	local changedConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then
				moved = true
			end
			target.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	if track then
		track(changedConn)
	end
end

local NovaUI = {}
NovaUI.__index = NovaUI

function NovaUI:CreateWindow(config: {
	Title: string?,
	Version: string?,
	Size: UDim2?,
	Footer: any,
})
	config = config or {}

	local connections = {}
	local function track(conn: RBXScriptConnection)
		table.insert(connections, conn)
		return conn
	end
	local function disconnectAll()
		for _, c in ipairs(connections) do
			c:Disconnect()
		end
		table.clear(connections)
	end

	local state = {
		capturing = false,
		closeDropdown = nil,
	}

	local ScreenGui = new("ScreenGui", {
		Name = "NovaUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})

	ScreenGui.Destroying:Connect(disconnectAll)

	local WindowSize = config.Size or UDim2.fromOffset(760, 460)

	local Main = new("Frame", {
		Name = "Main",
		Size = WindowSize,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Theme.PurpleGlow,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Parent = ScreenGui,
	}, { corner(16), stroke(Theme.Line, 1) })

	local MainScale = new("UIScale", { Scale = 1, Parent = Main })

	new("UIGradient", {
		Color = ColorSequence.new(Theme.PurpleGlow, Theme.Bg1),
		Rotation = 90,
		Parent = Main,
	})

	local DragBar = new("Frame", {
		Name = "DragBar",
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	local blockDrag = false
	makeDraggable(DragBar, Main, nil, function()
		return blockDrag
	end, track)

	local TitleBarButtons = new("Frame", {
		Name = "TitleBarButtons",
		Size = UDim2.fromOffset(66, 28),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 7),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = Main,
	})
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = TitleBarButtons,
	})

	local function titleBarButton(text: string, hoverColor: Color3, layoutOrder: number, textSize: number?)
		local Btn = new("TextButton", {
			Text = text,
			FontFace = FONT_BOLD,
			TextSize = textSize or 15,
			TextColor3 = Theme.Text1,
			AutoButtonColor = false,
			BackgroundColor3 = Theme.Bg3,
			BackgroundTransparency = 0.25,
			Size = UDim2.fromOffset(30, 28),
			LayoutOrder = layoutOrder,
			ZIndex = 6,
			Parent = TitleBarButtons,
		}, { corner(8), stroke(Theme.Line, 1) })

		Btn.MouseEnter:Connect(function()
			blockDrag = true
			tween(Btn, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0.1, TextColor3 = Color3.new(1, 1, 1) }, 0.12)
		end)
		Btn.MouseLeave:Connect(function()
			blockDrag = false
			tween(Btn, { BackgroundColor3 = Theme.Bg3, BackgroundTransparency = 0.25, TextColor3 = Theme.Text1 }, 0.12)
		end)

		return Btn
	end

	local MinimizeBtn = titleBarButton("–", Theme.Purple1, 1)
	local CloseBtn = titleBarButton("×", Color3.fromHex("E1526B"), 2, 25)

	local Bubble = new("TextButton", {
		Name = "NovaBubble",
		Text = "",
		AutoButtonColor = false,
		Size = UDim2.fromOffset(54, 54),
		Position = UDim2.new(1, -78, 1, -78),
		BackgroundColor3 = Theme.Bg1,
		Visible = false,
		ZIndex = 20,
		Parent = ScreenGui,
	}, { corner(16), stroke(Theme.Line, 1) })
	new("UIGradient", {
		Color = ColorSequence.new(Theme.Bg1, Theme.Bg0),
		Rotation = 90,
		Parent = Bubble,
	})

	local BubbleMark = new("Frame", {
		Size = UDim2.fromOffset(34, 34),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundColor3 = Theme.Purple1,
		Parent = Bubble,
	}, { corner(10), gradient(135), stroke(Theme.Purple1, 4, 0.55) })

	new("TextLabel", {
		Text = "N",
		FontFace = FONT_BOLD,
		TextSize = 16,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = BubbleMark,
	})

	local minimized = false

	local function setMinimized(value: boolean)
		if value == minimized then
			return
		end
		minimized = value

		if value then
			Bubble.Visible = true
			Bubble.Size = UDim2.fromOffset(0, 0)
			tween(Bubble, { Size = UDim2.fromOffset(54, 54) }, 0.22, Enum.EasingStyle.Back)

			tween(MainScale, { Scale = 0.85 }, 0.14, Enum.EasingStyle.Quad)
			task.delay(0.14, function()
				if minimized then
					Main.Visible = false
					MainScale.Scale = 1
				end
			end)
		else
			Main.Visible = true
			MainScale.Scale = 0.85
			tween(MainScale, { Scale = 1 }, 0.18, Enum.EasingStyle.Back)

			tween(Bubble, { Size = UDim2.fromOffset(0, 0) }, 0.16)
			task.delay(0.16, function()
				if not minimized then
					Bubble.Visible = false
				end
			end)
		end
	end

	MinimizeBtn.MouseButton1Click:Connect(function()
		setMinimized(true)
	end)

	track(UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent or state.capturing then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			setMinimized(not minimized)
		end
	end))

	makeDraggable(Bubble, Bubble, function()
		setMinimized(false)
	end, nil, track)

	local closed = false
	local function closeWindow()
		if closed then
			return
		end
		closed = true

		if state.closeDropdown then
			state.closeDropdown()
		end
		disconnectAll()

		tween(MainScale, { Scale = 0.85 }, 0.16, Enum.EasingStyle.Quad)
		task.delay(0.16, function()
			ScreenGui:Destroy()
		end)
	end

	CloseBtn.MouseButton1Click:Connect(closeWindow)

	local Side = new("Frame", {
		Name = "Side",
		Size = UDim2.new(0, 220, 1, 0),
		BackgroundColor3 = Theme.Bg2,
		BorderSizePixel = 0,
		Parent = Main,
	})
	new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = Side })
	new("Frame", {
		Size = UDim2.new(0, 20, 1, 0),
		Position = UDim2.new(1, -20, 0, 0),
		BackgroundColor3 = Theme.Bg2,
		BorderSizePixel = 0,
		Parent = Side,
	})
	new("Frame", {
		Size = UDim2.new(0, 1, 1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = Theme.Line,
		BorderSizePixel = 0,
		Parent = Side,
	})

	local NavIndicator = new("Frame", {
		Name = "NavIndicator",
		Size = UDim2.new(0, 3, 0, 20),
		Position = UDim2.fromOffset(0, 7),
		BackgroundColor3 = Theme.Purple1,
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = Side,
	}, { corner(3), gradient(0), stroke(Theme.Purple2, 3, 0.6) })

	local SideContent = new("Frame", {
		Name = "SideContent",
		Size = UDim2.new(1, 0, 1, -56),
		BackgroundTransparency = 1,
		Parent = Side,
	})

	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = SideContent,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 16),
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 14),
		Parent = SideContent,
	})

	local Brand = new("Frame", {
		Size = UDim2.new(1, 0, 0, 48),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = SideContent,
	})
	local BrandMark = new("Frame", {
		Size = UDim2.fromOffset(30, 30),
		Position = UDim2.fromOffset(0, 2),
		BackgroundColor3 = Theme.Purple1,
		Parent = Brand,
	}, { corner(8), gradient(135), stroke(Theme.Purple1, 4, 0.55) })
	new("TextLabel", {
		Text = "N",
		FontFace = FONT_BOLD,
		TextSize = 15,
		TextColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = BrandMark,
	})
	new("TextLabel", {
		Text = config.Title or "Nova",
		FontFace = FONT_BOLD,
		TextSize = 14,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -40, 0, 18),
		Parent = Brand,
	})
	new("TextLabel", {
		Text = config.Version or "v1.0.0",
		FontFace = FONT,
		TextSize = 11,
		TextColor3 = Theme.Text2,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 18),
		Size = UDim2.new(1, -40, 0, 14),
		Parent = Brand,
	})
	new("Frame", {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.fromOffset(0, 47),
		BackgroundColor3 = Theme.Line,
		BorderSizePixel = 0,
		Parent = Brand,
	})

	local TabList = new("Frame", {
		Name = "TabList",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = SideContent,
	})
	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = TabList,
	})

	local Footer = config.Footer
	if Footer ~= false then
		Footer = Footer or {}
		local FooterBar = new("Frame", {
			Name = "FooterBar",
			Size = UDim2.new(1, 0, 0, 56),
			Position = UDim2.new(0, 0, 1, -56),
			BackgroundTransparency = 1,
			Parent = Side,
		})
		new("Frame", {
			Size = UDim2.new(1, -28, 0, 1),
			Position = UDim2.fromOffset(14, 0),
			BackgroundColor3 = Theme.Line,
			BorderSizePixel = 0,
			Parent = FooterBar,
		})
		local Avatar = new("Frame", {
			Size = UDim2.fromOffset(26, 26),
			Position = UDim2.fromOffset(14, 15),
			BackgroundColor3 = Theme.Purple1,
			Parent = FooterBar,
		}, { corner(13), gradient(135) })
		new("TextLabel", {
			Text = string.sub(Footer.Name or "Convidado", 1, 1),
			FontFace = FONT_BOLD,
			TextSize = 11,
			TextColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Parent = Avatar,
		})
		new("TextLabel", {
			Text = Footer.Name or "Convidado",
			FontFace = FONT_MEDIUM,
			TextSize = 13,
			TextColor3 = Theme.Text0,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(48, 12),
			Size = UDim2.new(1, -60, 0, 16),
			Parent = FooterBar,
		})
		new("TextLabel", {
			Text = Footer.Status or "sessão local",
			FontFace = FONT,
			TextSize = 11,
			TextColor3 = Theme.Text2,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(48, 27),
			Size = UDim2.new(1, -60, 0, 14),
			Parent = FooterBar,
		})
	end

	local Content = new("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -220, 1, 0),
		Position = UDim2.fromOffset(220, 0),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	local ContentHeader = new("Frame", {
		Size = UDim2.new(1, -44, 0, 40),
		Position = UDim2.fromOffset(26, 18),
		BackgroundTransparency = 1,
		Parent = Content,
	})
	local HeaderTitle = new("TextLabel", {
		Name = "HeaderTitle",
		Text = "",
		FontFace = FONT_BOLD,
		TextSize = 16,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		Size = UDim2.new(0.6, 0, 1, 0),
		Parent = ContentHeader,
	})

	local HeaderSubtitle = new("TextLabel", {
		Name = "HeaderSubtitle",
		Text = "",
		FontFace = FONT,
		TextSize = 12,
		TextColor3 = Theme.Text2,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextYAlignment = Enum.TextYAlignment.Center,
		BackgroundTransparency = 1,
		Position = UDim2.new(0.6, 0, 0, 0),
		Size = UDim2.new(0.4, 0, 1, 0),
		Parent = ContentHeader,
	})

	local Pages = new("Frame", {
		Name = "Pages",
		Size = UDim2.new(1, -44, 1, -70),
		Position = UDim2.fromOffset(22, 58),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = Content,
	})

	local Overlay = new("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 1000,
		Parent = ScreenGui,
	})

	local self = setmetatable({
		ScreenGui = ScreenGui,
		Main = Main,
		Side = Side,
		NavIndicator = NavIndicator,
		TabList = TabList,
		Pages = Pages,
		Overlay = Overlay,
		HeaderTitle = HeaderTitle,
		HeaderSubtitle = HeaderSubtitle,
		Tabs = {},
		_navOrder = 0,
		_lastGroup = nil,
		_setMinimized = setMinimized,
		_close = closeWindow,
		_track = track,
		_state = state,
	}, NovaUI)

	return self
end

function NovaUI:Minimize()
	self._setMinimized(true)
end

function NovaUI:Restore()
	self._setMinimized(false)
end

function NovaUI:Close()
	self._close()
end

local Tab = {}
Tab.__index = Tab

function NovaUI:CreateTab(name: string, opts: {
	Group: string?,
	Icon: string?,
	IconRectOffset: Vector2?,
	IconRectSize: Vector2?,
	Subtitle: string?,
}?)
	opts = opts or {}

	if opts.Group and opts.Group ~= self._lastGroup then
		self._lastGroup = opts.Group
		self._navOrder += 1
		new("TextLabel", {
			Text = string.upper(opts.Group),
			FontFace = FONT_MEDIUM,
			TextSize = 10,
			TextColor3 = Theme.Text2,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = self._navOrder,
			Parent = self.TabList,
		})
	end

	self._navOrder += 1

	local Page = new("ScrollingFrame", {
		Name = name .. "Page",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = Theme.Bg3,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Pages,
	})
	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
		Parent = Page,
	})

	local Item = new("Frame", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Bg2,
		BackgroundTransparency = 1,
		LayoutOrder = self._navOrder,
		Parent = self.TabList,
	}, { corner(8) })

	local Icon: ImageLabel? = nil
	local labelOffsetX = 12
	if opts.Icon then
		labelOffsetX = 34
		Icon = new("ImageLabel", {
			Image = opts.Icon,
			ImageColor3 = Theme.Text1,
			ImageTransparency = 0.15,
			BackgroundTransparency = 1,
			Size = UDim2.fromOffset(15, 15),
			Position = UDim2.fromOffset(12, 9),
			Parent = Item,
		})
		if opts.IconRectOffset then
			(Icon :: ImageLabel).ImageRectOffset = opts.IconRectOffset
		end
		if opts.IconRectSize then
			(Icon :: ImageLabel).ImageRectSize = opts.IconRectSize
		end
	end

	local Label = new("TextLabel", {
		Text = name,
		FontFace = FONT_MEDIUM,
		TextSize = 13,
		TextColor3 = Theme.Text1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(labelOffsetX, 0),
		Size = UDim2.new(1, -labelOffsetX, 1, 0),
		Parent = Item,
	})

	local Button = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Parent = Item,
	})

	local tab
	local function select()
		for _, t in ipairs(self.Tabs) do
			t.Page.Visible = false
			tween(t.Item, { BackgroundTransparency = 1 }, 0.15)
			tween(t.Label, { TextColor3 = Theme.Text1 }, 0.15)
			if t.Icon then
				tween(t.Icon, { ImageTransparency = 0.15 }, 0.15)
				t.Icon.ImageColor3 = Theme.Text1
			end
		end

		Page.Visible = true
		Page.Position = UDim2.fromOffset(0, 14)
		tween(Page, { Position = UDim2.fromOffset(0, 0) }, 0.22, Enum.EasingStyle.Quint)

		tween(Item, { BackgroundTransparency = 0.86 }, 0.15)
		tween(Label, { TextColor3 = Theme.Text0 }, 0.15)
		if Icon then
			tween(Icon, { ImageTransparency = 0 }, 0.15)
			Icon.ImageColor3 = Theme.Text0
		end

		task.defer(function()
			local targetY = Item.AbsolutePosition.Y - self.Side.AbsolutePosition.Y + 7
			local indicator = self.NavIndicator
			if indicator.BackgroundTransparency >= 1 then
				indicator.Position = UDim2.fromOffset(0, targetY)
				tween(indicator, { BackgroundTransparency = 0 }, 0.18)
			else
				tween(indicator, { Position = UDim2.fromOffset(0, targetY) }, 0.22, Enum.EasingStyle.Quint)
			end
		end)

		self.HeaderTitle.Text = name
		self.HeaderSubtitle.Text = tab.Subtitle or ""
	end

	Button.MouseButton1Click:Connect(select)

	tab = setmetatable({
		Name = name,
		Page = Page,
		Item = Item,
		Label = Label,
		Icon = Icon,
		Subtitle = opts.Subtitle,
		_window = self,
		_sectionOrder = 0,
	}, Tab)

	table.insert(self.Tabs, tab)
	if #self.Tabs == 1 then
		select()
	end

	return tab
end

function Tab:SetSubtitle(text: string)
	self.Subtitle = text
	if self._window and self._window.HeaderTitle.Text == self.Name then
		self._window.HeaderSubtitle.Text = text
	end
end

local Section = {}
Section.__index = Section

function Tab:CreateSection(title: string)
	self._sectionOrder += 1

	local Box = new("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromHex("1A132D"),
		BackgroundTransparency = 0.3,
		LayoutOrder = self._sectionOrder,
		Parent = self.Page,
	}, { corner(10), stroke(Theme.Line, 1) })

	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2),
		Parent = Box,
	})
	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
		Parent = Box,
	})

	new("TextLabel", {
		Text = title,
		FontFace = FONT_MEDIUM,
		TextSize = 11,
		TextColor3 = Theme.Text2,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -12, 0, 20),
		Position = UDim2.fromOffset(6, 2),
		LayoutOrder = 0,
		Parent = Box,
	})

	local section = setmetatable({
		Box = Box,
		Page = self.Page,
		_rowOrder = 0,
		_window = self._window,
	}, Section)

	return section
end

local function baseRow(section, height: number?, noHover: boolean?)
	section._rowOrder += 1
	local Row = new("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, height or 40),
		BackgroundTransparency = 1,
		LayoutOrder = section._rowOrder,
		Parent = section.Box,
	}, { corner(8) })

	if noHover then
		return Row
	end

	local hover = new("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 0,
		Parent = Row,
	})

	hover.MouseEnter:Connect(function()
		Row.BackgroundColor3 = Theme.Purple1
		tween(Row, { BackgroundTransparency = 0.94 }, 0.12)
	end)
	hover.MouseLeave:Connect(function()
		tween(Row, { BackgroundTransparency = 1 }, 0.15)
	end)

	return Row
end

function Section:CreateLabel(opts: { Text: string, Color: Color3? } | string)
	if type(opts) == "string" then
		opts = { Text = opts }
	end

	local Row = baseRow(self, 30, true)

	local Label = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = opts.Color or Theme.Text1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		Parent = Row,
	})

	return buildApi(Row, Label, {
		Set = function(_, text: string)
			Label.Text = text
		end,
		Get = function()
			return Label.Text
		end,
		SetColor = function(_, color: Color3)
			Label.TextColor3 = color
		end,
	})
end

function Section:CreateParagraph(opts: {
	Title: string?,
	Text: string,
	RichText: boolean?,
})
	local Row = baseRow(self, 0, true)
	Row.AutomaticSize = Enum.AutomaticSize.Y

	new("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		Parent = Row,
	})
	new("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		Parent = Row,
	})

	local Title = new("TextLabel", {
		Text = opts.Title or "",
		FontFace = FONT_MEDIUM,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		Visible = opts.Title ~= nil and opts.Title ~= "",
		LayoutOrder = 1,
		Parent = Row,
	})

	local Body = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 12,
		TextColor3 = Theme.Text1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		RichText = opts.RichText == true,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		LayoutOrder = 2,
		Parent = Row,
	})

	return buildApi(Row, Body, {
		Set = function(_, text: string)
			Body.Text = text
		end,
		Get = function()
			return Body.Text
		end,
		SetTitle = function(_, text: string)
			Title.Text = text
			Title.Visible = text ~= nil and text ~= ""
		end,
	})
end

function Section:CreateCheckbox(opts: {
	Text: string,
	Default: boolean?,
	Callback: ((boolean) -> ())?,
})
	local Row = baseRow(self, 40)
	local state = opts.Default or false

	local Box = new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(12, 11),
		BackgroundColor3 = Theme.Bg3,
		Parent = Row,
	}, { corner(5) })

	local BoxStroke = new("UIStroke", { Color = Theme.Line, Thickness = 1.5, Parent = Box })
	local GlowStroke = new("UIStroke", { Color = Theme.Purple1, Thickness = 4, Transparency = 1, Parent = Box })

	local Check = new("ImageLabel", {
		Image = CHECK_IMAGE,
		ImageColor3 = Color3.new(1, 1, 1),
		ImageRectOffset = CHECK_RECT_OFFSET,
		ImageRectSize = CHECK_RECT_SIZE,
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.75, 0.75),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Visible = state,
		Parent = Box,
	})

	local Label = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(40, 0),
		Size = UDim2.new(1, -50, 1, 0),
		Parent = Row,
	})

	local function apply()
		if state then
			tween(Box, { BackgroundColor3 = Theme.PurpleGlow }, 0.12)
			BoxStroke.Transparency = 1
			GlowStroke.Transparency = 0.55
			if not Box:FindFirstChildOfClass("UIGradient") then
				gradient(135).Parent = Box
			end
			Check.Visible = true
		else
			tween(Box, { BackgroundColor3 = Theme.Bg3 }, 0.12)
			BoxStroke.Transparency = 0
			GlowStroke.Transparency = 1
			local g = Box:FindFirstChildOfClass("UIGradient")
			if g then
				g:Destroy()
			end
			Check.Visible = false
		end
	end
	apply()

	local click = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = Row,
	})
	click.MouseButton1Click:Connect(function()
		state = not state
		apply()
		if opts.Callback then
			opts.Callback(state)
		end
	end)

	return buildApi(Row, Label, {
		Set = function(_, value: boolean)
			state = value
			apply()
		end,
		Get = function()
			return state
		end,
	})
end

function Section:CreateToggle(opts: {
	Text: string,
	Default: boolean?,
	Callback: ((boolean) -> ())?,
})
	local Row = baseRow(self, 40)
	local state = opts.Default or false

	local Label = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -80, 1, 0),
		Parent = Row,
	})

	local Track = new("Frame", {
		Size = UDim2.fromOffset(38, 21),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = Theme.Bg3,
		BackgroundTransparency = 0,
		Parent = Row,
	}, { corner(11) })

	local TrackStroke = new("UIStroke", { Color = Theme.Line, Thickness = 1, Parent = Track })

	local Dot = new("Frame", {
		Size = UDim2.fromOffset(15, 15),
		Position = UDim2.fromOffset(2, 2),
		BackgroundColor3 = Theme.Text1,
		Parent = Track,
	}, { corner(8) })

	local DotGlow = new("UIStroke", { Color = Theme.Purple2, Thickness = 4, Transparency = 1, Parent = Dot })

	local function apply(animate: boolean?)
		local t = animate and 0.15 or 0
		if state then
			tween(Track, { BackgroundColor3 = Theme.Purple1, BackgroundTransparency = 0.75 }, t)
			TrackStroke.Color = Theme.Purple1
			tween(Dot, { Position = UDim2.fromOffset(19, 2), BackgroundColor3 = Theme.Purple2 }, t)
			DotGlow.Transparency = 0.4
		else
			tween(Track, { BackgroundColor3 = Theme.Bg3, BackgroundTransparency = 0 }, t)
			TrackStroke.Color = Theme.Line
			tween(Dot, { Position = UDim2.fromOffset(2, 2), BackgroundColor3 = Theme.Text1 }, t)
			DotGlow.Transparency = 1
		end
	end
	apply(false)

	local click = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = Row,
	})
	click.MouseButton1Click:Connect(function()
		state = not state
		apply(true)
		if opts.Callback then
			opts.Callback(state)
		end
	end)

	return buildApi(Row, Label, {
		Set = function(_, value: boolean)
			state = value
			apply(true)
		end,
		Get = function()
			return state
		end,
	})
end

function Section:CreateSlider(opts: {
	Text: string,
	Min: number,
	Max: number,
	Default: number?,
	Step: number?,
	Suffix: string?,
	Decimals: number?,
	Callback: ((number) -> ())?,
})
	local Row = baseRow(self, 62)
	local bind, unbindAll = newBinder(self._window)

	local min, max = opts.Min, opts.Max
	local step = opts.Step
	local decimals = opts.Decimals or (step and countDecimals(step)) or 0
	local suffix = opts.Suffix or ""
	local value = min

	local TitleLabel = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 4),
		Size = UDim2.new(1, -90, 0, 18),
		Parent = Row,
	})

	local ValueBox = new("TextBox", {
		Text = "",
		FontFace = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Purple2,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -90, 0, 4),
		Size = UDim2.fromOffset(78, 18),
		Parent = Row,
	})

	local Track = new("Frame", {
		Size = UDim2.new(1, -24, 0, 6),
		Position = UDim2.fromOffset(12, 34),
		BackgroundColor3 = Theme.Bg3,
		Parent = Row,
	}, { corner(6), stroke(Theme.Line, 1) })

	local Fill = new("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.Purple1,
		Parent = Track,
	}, { corner(6), gradient(0) })

	local Thumb = new("Frame", {
		Size = UDim2.fromOffset(14, 14),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Parent = Track,
	}, { corner(7), stroke(Theme.Purple1, 3, 0.35) })

	local Hit = new("Frame", {
		Size = UDim2.new(1, -24, 0, 24),
		Position = UDim2.fromOffset(12, 25),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = Row,
	})

	local function snap(v: number)
		v = math.clamp(v, min, max)
		if step and step > 0 then
			v = min + math.round((v - min) / step) * step
			v = math.clamp(v, min, max)
		end
		local mult = 10 ^ decimals
		return math.round(v * mult) / mult
	end

	local function numberText(v: number)
		if decimals == 0 then
			return tostring(math.round(v))
		end
		return string.format("%." .. decimals .. "f", v)
	end

	local function setValue(v: number, fire: boolean?)
		local old = value
		value = snap(v)
		local alpha = (max == min) and 0 or (value - min) / (max - min)
		Fill.Size = UDim2.fromScale(alpha, 1)
		Thumb.Position = UDim2.fromScale(alpha, 0.5)
		if not ValueBox:IsFocused() then
			ValueBox.Text = numberText(value) .. suffix
		end
		if fire and value ~= old and opts.Callback then
			opts.Callback(value)
		end
	end
	setValue(opts.Default or min, false)

	ValueBox.Focused:Connect(function()
		ValueBox.Text = numberText(value)
		ValueBox.TextColor3 = Theme.Text0
	end)
	ValueBox.FocusLost:Connect(function()
		ValueBox.TextColor3 = Theme.Purple2
		local n = tonumber(ValueBox.Text)
		if n then
			setValue(n, true)
		else
			ValueBox.Text = numberText(value) .. suffix
		end
	end)

	local dragging = false
	local function inputToValue(x: number)
		local left = Track.AbsolutePosition.X
		local width = math.max(Track.AbsoluteSize.X, 1)
		local alpha = math.clamp((x - left) / width, 0, 1)
		return min + (max - min) * alpha
	end

	Hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setValue(inputToValue(input.Position.X), true)
		end
	end)
	bind(UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setValue(inputToValue(input.Position.X), true)
		end
	end))
	bind(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))

	return buildApi(Row, TitleLabel, {
		Set = function(_, v: number)
			setValue(v, false)
		end,
		Get = function()
			return value
		end,
	}, function()
		unbindAll()
	end)
end

local function buildDropdown(section, opts, multi: boolean)
	local Row = baseRow(section, 38)
	local window = section._window
	local overlay = window and window.Overlay
	local page = section.Page
	local windowState = window and window._state
	local bind, unbindAll = newBinder(window)

	local options: {string} = table.clone(opts.Options or {})
	local maxVisible = opts.MaxVisible or 6
	local prefix = ""
	if opts.Text and opts.Text ~= "" then
		prefix = opts.Text .. ": "
	end

	local selected: string? = nil
	local selectedSet: {[string]: boolean} = {}
	if multi then
		for _, v in ipairs(opts.Default or {}) do
			selectedSet[v] = true
		end
	else
		selected = opts.Default or options[1]
	end

	local optionButtons: {[string]: { Btn: TextButton, Check: ImageLabel }} = {}
	local isOpen = false
	local heartbeatConn: RBXScriptConnection? = nil
	local outsideClickConn: RBXScriptConnection? = nil

	local Box = new("Frame", {
		Size = UDim2.new(1, -24, 0, 32),
		Position = UDim2.fromOffset(12, 3),
		BackgroundColor3 = Theme.Bg3,
		Parent = Row,
	}, { corner(8), stroke(Theme.Line, 1) })

	local Label = new("TextLabel", {
		Text = "",
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Parent = Box,
	})

	local Arrow = new("TextLabel", {
		Text = "▾",
		FontFace = FONT,
		TextSize = 14,
		TextColor3 = Theme.Text2,
		BackgroundTransparency = 1,
		Rotation = 0,
		Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.fromOffset(20, 32),
		Parent = Box,
	})

	local ListStroke = stroke(Theme.Line, 1)
	local ListHolder = new("Frame", {
		Size = UDim2.fromOffset(0, 0),
		BackgroundColor3 = Theme.Bg3,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Visible = false,
		ZIndex = 5,
		Parent = overlay or Box,
	}, { corner(8), ListStroke })

	local Scroll = new("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Purple1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 5,
		Parent = ListHolder,
	})
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = Scroll })

	local function listHeight()
		return math.max(math.min(#options, maxVisible), 1) * 30
	end

	local function getSelectedList(): {string}
		local list = {}
		for _, name in ipairs(options) do
			if selectedSet[name] then
				table.insert(list, name)
			end
		end
		return list
	end

	local function displayText()
		if multi then
			local list = getSelectedList()
			return prefix .. (#list > 0 and table.concat(list, ", ") or "Nenhum")
		end
		return prefix .. (selected or "—")
	end

	local function updateOptionVisual(name: string)
		local o = optionButtons[name]
		if not o then
			return
		end
		local isSel
		if multi then
			isSel = selectedSet[name] == true
		else
			isSel = selected == name
		end
		o.Btn.TextColor3 = isSel and Theme.Text0 or Theme.Text1
		o.Check.Visible = isSel
	end

	local function syncVisuals()
		Label.Text = displayText()
		for name in pairs(optionButtons) do
			updateOptionVisual(name)
		end
	end

	local function pointInside(guiObject: GuiObject, x: number, y: number)
		local p = guiObject.AbsolutePosition
		local s = guiObject.AbsoluteSize
		return x >= p.X and x <= p.X + s.X and y >= p.Y and y <= p.Y + s.Y
	end

	local function isBoxOnScreen()
		if not page then
			return true
		end
		local boxTop = Box.AbsolutePosition.Y
		local boxBottom = boxTop + Box.AbsoluteSize.Y
		local pageTop = page.AbsolutePosition.Y
		local pageBottom = pageTop + page.AbsoluteSize.Y
		return boxBottom > pageTop and boxTop < pageBottom
	end

	local function updatePosition()
		if not overlay then
			return
		end
		local origin = overlay.AbsolutePosition
		local boxPos = Box.AbsolutePosition
		local boxSize = Box.AbsoluteSize
		ListHolder.Position = UDim2.fromOffset(boxPos.X - origin.X, boxPos.Y - origin.Y + boxSize.Y + 4)
	end

	local closeList
	local openList

	closeList = function()
		if not isOpen then
			return
		end
		isOpen = false

		tween(ListHolder, { Size = UDim2.fromOffset(Box.AbsoluteSize.X, 0), BackgroundTransparency = 1 }, 0.12, Enum.EasingStyle.Quad)
		tween(ListStroke, { Transparency = 1 }, 0.12)
		tween(Arrow, { Rotation = 0 }, 0.12)
		task.delay(0.12, function()
			if not isOpen then
				ListHolder.Visible = false
			end
		end)

		if heartbeatConn then
			heartbeatConn:Disconnect()
			heartbeatConn = nil
		end
		if outsideClickConn then
			outsideClickConn:Disconnect()
			outsideClickConn = nil
		end
		if windowState and windowState.closeDropdown == closeList then
			windowState.closeDropdown = nil
		end
	end

	openList = function()
		if windowState and windowState.closeDropdown and windowState.closeDropdown ~= closeList then
			windowState.closeDropdown()
		end
		if not isBoxOnScreen() then
			return
		end

		isOpen = true
		updatePosition()
		ListHolder.Visible = true
		ListHolder.Size = UDim2.fromOffset(Box.AbsoluteSize.X, 0)
		ListHolder.BackgroundTransparency = 1
		ListStroke.Transparency = 1

		tween(ListHolder, { Size = UDim2.fromOffset(Box.AbsoluteSize.X, listHeight()), BackgroundTransparency = 0 }, 0.18, Enum.EasingStyle.Quint)
		tween(ListStroke, { Transparency = 0 }, 0.18)
		tween(Arrow, { Rotation = 180 }, 0.15)

		if windowState then
			windowState.closeDropdown = closeList
		end

		heartbeatConn = RunService.Heartbeat:Connect(function()
			updatePosition()
			if not isBoxOnScreen() then
				closeList()
			end
		end)

		outsideClickConn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local pos = input.Position
			if pointInside(ListHolder, pos.X, pos.Y) or pointInside(Box, pos.X, pos.Y) then
				return
			end
			closeList()
		end)
	end

	if page then
		bind(page:GetPropertyChangedSignal("Visible"):Connect(function()
			if not page.Visible then
				closeList()
			end
		end))
	end
	if window then
		bind(window.Main:GetPropertyChangedSignal("Visible"):Connect(function()
			if not window.Main.Visible then
				closeList()
			end
		end))
		window.ScreenGui.Destroying:Connect(closeList)
	end

	local function buildOptions()
		for _, o in pairs(optionButtons) do
			o.Btn:Destroy()
		end
		table.clear(optionButtons)

		for i, optionText in ipairs(options) do
			local OptBtn = new("TextButton", {
				Text = "   " .. optionText,
				FontFace = FONT,
				TextSize = 13,
				TextColor3 = Theme.Text1,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Size = UDim2.new(1, 0, 0, 30),
				LayoutOrder = i,
				ZIndex = 6,
				Parent = Scroll,
			})

			local Check = new("ImageLabel", {
				Image = CHECK_IMAGE,
				ImageRectOffset = CHECK_RECT_OFFSET,
				ImageRectSize = CHECK_RECT_SIZE,
				ImageColor3 = Theme.Purple2,
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -10, 0.5, 0),
				Size = UDim2.fromOffset(14, 14),
				Visible = false,
				ZIndex = 7,
				Parent = OptBtn,
			})

			optionButtons[optionText] = { Btn = OptBtn, Check = Check }

			OptBtn.MouseEnter:Connect(function()
				OptBtn.BackgroundTransparency = 0.85
				OptBtn.BackgroundColor3 = Theme.Purple1
			end)
			OptBtn.MouseLeave:Connect(function()
				OptBtn.BackgroundTransparency = 1
			end)
			OptBtn.MouseButton1Click:Connect(function()
				if multi then
					selectedSet[optionText] = (not selectedSet[optionText]) or nil
					syncVisuals()
					if opts.Callback then
						opts.Callback(getSelectedList())
					end
				else
					selected = optionText
					syncVisuals()
					closeList()
					if opts.Callback then
						opts.Callback(selected)
					end
				end
			end)

			updateOptionVisual(optionText)
		end
	end

	buildOptions()
	Label.Text = displayText()

	local click = new("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 2,
		Parent = Box,
	})
	click.MouseButton1Click:Connect(function()
		if isOpen then
			closeList()
		else
			openList()
		end
	end)

	return buildApi(Row, nil, {
		Set = function(_, value)
			if multi then
				table.clear(selectedSet)
				for _, v in ipairs(value or {}) do
					selectedSet[v] = true
				end
			else
				selected = value
			end
			syncVisuals()
		end,
		Get = function()
			if multi then
				return getSelectedList()
			end
			return selected
		end,
			
		Refresh = function(_, newOptions: {string})
			options = table.clone(newOptions or {})
			if multi then
				for name in pairs(selectedSet) do
					if not table.find(options, name) then
						selectedSet[name] = nil
					end
				end
			elseif not selected or not table.find(options, selected) then
				selected = options[1]
			end
			buildOptions()
			Label.Text = displayText()
			if isOpen then
				ListHolder.Size = UDim2.fromOffset(Box.AbsoluteSize.X, listHeight())
			end
		end,
		SetText = function(_, text: string)
			prefix = (text and text ~= "") and (text .. ": ") or ""
			Label.Text = displayText()
		end,
	}, function()
		closeList()
		unbindAll()
		ListHolder:Destroy()
	end, closeList)
end

function Section:CreateDropdown(opts: {
	Text: string?,
	Options: {string},
	Default: string?,
	MaxVisible: number?,
	Callback: ((string) -> ())?,
})
	return buildDropdown(self, opts, false)
end

function Section:CreateMultiDropdown(opts: {
	Text: string?,
	Options: {string},
	Default: {string}?,
	MaxVisible: number?,
	Callback: (({string}) -> ())?,
})
	return buildDropdown(self, opts, true)
end

function Section:CreateTextBox(opts: {
	Text: string?,
	Default: any?,
	Placeholder: string?,
	Numeric: boolean?,
	ClearOnFocus: boolean?,
	EnterOnly: boolean?,
	MaxLength: number?,
	Callback: ((any) -> ())?,
})
	local Row = baseRow(self, 40)
	local numeric = opts.Numeric == true
	local hasLabel = opts.Text ~= nil and opts.Text ~= ""

	local value = opts.Default ~= nil and tostring(opts.Default) or ""

	local TitleLabel: TextLabel? = nil
	if hasLabel then
		TitleLabel = new("TextLabel", {
			Text = opts.Text,
			FontFace = FONT,
			TextSize = 13,
			TextColor3 = Theme.Text0,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, 0),
			Size = UDim2.new(0.5, -12, 1, 0),
			Parent = Row,
		})
	end

	local BoxStroke = stroke(Theme.Line, 1)
	local Box = new("Frame", {
		Size = hasLabel and UDim2.new(0.5, -12, 0, 28) or UDim2.new(1, -24, 0, 28),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = Theme.Bg3,
		Parent = Row,
	}, { corner(8), BoxStroke })

	local Input = new("TextBox", {
		Text = value,
		PlaceholderText = opts.Placeholder or "",
		PlaceholderColor3 = Theme.Text2,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = opts.ClearOnFocus == true,
		ClipsDescendants = true,
		MaxVisibleGraphemes = -1,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -20, 1, 0),
		ZIndex = 2,
		Parent = Box,
	})
	if opts.MaxLength then
		Input.MaxLength = opts.MaxLength
	end

	if numeric then
		Input:GetPropertyChangedSignal("Text"):Connect(function()
			local filtered = string.gsub(Input.Text, "[^%d%.%-]", "")
			if filtered ~= Input.Text then
				Input.Text = filtered
			end
		end)
	end

	Input.Focused:Connect(function()
		tween(BoxStroke, { Color = Theme.Purple1 }, 0.12)
	end)

	Input.FocusLost:Connect(function(enterPressed: boolean)
		tween(BoxStroke, { Color = Theme.Line }, 0.12)

		local text = Input.Text
		if opts.EnterOnly and not enterPressed then
			Input.Text = value
			return
		end
		if numeric and tonumber(text) == nil then
			Input.Text = value
			return
		end

		value = text
		if opts.Callback then
			opts.Callback(numeric and tonumber(text) or text)
		end
	end)

	return buildApi(Row, TitleLabel, {
		Set = function(_, v: any)
			value = tostring(v)
			Input.Text = value
		end,
		Get = function()
			if numeric then
				return tonumber(value)
			end
			return value
		end,
		SetPlaceholder = function(_, text: string)
			Input.PlaceholderText = text
		end,
	}, nil, function()
		Input:ReleaseFocus()
	end)
end

function Section:CreateKeybind(opts: {
	Text: string,
	Default: Enum.KeyCode?,
	Callback: ((Enum.KeyCode) -> ())?,
	OnChange: ((Enum.KeyCode?) -> ())?,
})
	local Row = baseRow(self, 40)
	local window = self._window
	local windowState = window and window._state
	local bind, unbindAll = newBinder(window)

	local key: Enum.KeyCode? = opts.Default
	local listening = false

	local TitleLabel = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Parent = Row,
	})

	local BoxStroke = stroke(Theme.Line, 1)
	local KeyBtn = new("TextButton", {
		Text = "",
		FontFace = FONT_MEDIUM,
		TextSize = 12,
		TextColor3 = Theme.Text1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Bg3,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(90, 26),
		ZIndex = 2,
		Parent = Row,
	}, { corner(7), BoxStroke })

	local function setCapturing(value: boolean)
		listening = value
		if windowState then
			windowState.capturing = value
		end
	end

	local function refresh()
		if listening then
			KeyBtn.Text = "..."
			KeyBtn.TextColor3 = Theme.Purple2
			tween(BoxStroke, { Color = Theme.Purple1 }, 0.12)
		else
			KeyBtn.Text = key and key.Name or "Nenhuma"
			KeyBtn.TextColor3 = Theme.Text1
			tween(BoxStroke, { Color = Theme.Line }, 0.12)
		end
	end
	refresh()

	KeyBtn.MouseButton1Click:Connect(function()
		setCapturing(not listening)
		refresh()
	end)

	bind(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if listening then
			if input.UserInputType ~= Enum.UserInputType.Keyboard then
				return
			end
			setCapturing(false)
			if input.KeyCode == Enum.KeyCode.Escape then
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then	
				key = nil
				if opts.OnChange then
					opts.OnChange(nil)
				end
			else
				key = input.KeyCode
				if opts.OnChange then
					opts.OnChange(key)
				end
			end
			refresh()
			return
		end

		if gameProcessed or not key then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
			if opts.Callback then
				opts.Callback(key)
			end
		end
	end))

	return buildApi(Row, TitleLabel, {
		Set = function(_, keyCode: Enum.KeyCode?)
			key = keyCode
			refresh()
		end,
		Get = function()
			return key
		end,
	}, function()
		if listening then
			setCapturing(false)
		end
		unbindAll()
	end, function()
		if listening then
			setCapturing(false)
			refresh()
		end
	end)
end

function Section:CreateColorDisplay(opts: {
	Text: string,
	Color: Color3?,
})
	local Row = baseRow(self, 40)

	local Label = new("TextLabel", {
		Text = opts.Text,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -60, 1, 0),
		Parent = Row,
	})

	local Swatch = new("Frame", {
		Size = UDim2.fromOffset(22, 22),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		BackgroundColor3 = opts.Color or Theme.Purple1,
		Parent = Row,
	}, { corner(6), stroke(Theme.Purple1, 2, 0.3) })

	return buildApi(Row, Label, {
		Set = function(_, color: Color3)
			Swatch.BackgroundColor3 = color
		end,
		Get = function()
			return Swatch.BackgroundColor3
		end,
	})
end

function Section:CreateButton(opts: {
	Text: string,
	Callback: (() -> ())?,
})
	local Row = baseRow(self, 40)
	
	local Shade = new("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = false,
		Parent = nil,
	}, { corner(8) })

	local Fill = new("Frame", {
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 5),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 1,
		Parent = Row,
	}, { corner(8), gradient(135) })
	Shade.Parent = Fill

	local Btn = new("TextButton", {
		Text = opts.Text,
		FontFace = FONT_MEDIUM,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 5),
		ZIndex = 2,
		Parent = Row,
	})

	local hovering = false

	Btn.MouseEnter:Connect(function()
		hovering = true
		Shade.BackgroundColor3 = Color3.new(1, 1, 1)
		tween(Shade, { BackgroundTransparency = 0.88 }, 0.12)
	end)
	Btn.MouseLeave:Connect(function()
		hovering = false
		Shade.BackgroundColor3 = Color3.new(1, 1, 1)
		tween(Shade, { BackgroundTransparency = 1 }, 0.15)
	end)
	Btn.MouseButton1Down:Connect(function()
		Shade.BackgroundColor3 = Color3.new(0, 0, 0)
		tween(Shade, { BackgroundTransparency = 0.72 }, 0.06)
	end)
	Btn.MouseButton1Up:Connect(function()
		Shade.BackgroundColor3 = Color3.new(1, 1, 1)
		tween(Shade, { BackgroundTransparency = hovering and 0.88 or 1 }, 0.12)
	end)

	local function fire()
		if opts.Callback then
			opts.Callback()
		end
	end
	Btn.MouseButton1Click:Connect(fire)

	return buildApi(Row, Btn, {
		Click = function()
			fire()
		end,
		SetCallback = function(_, fn: (() -> ())?)
			opts.Callback = fn
		end,
	})
end

return NovaUI
