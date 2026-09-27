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

local function makeDraggable(handle: GuiObject, target: GuiObject, onClick: (() -> ())?, shouldBlock: (() -> boolean)?)
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

	UserInputService.InputChanged:Connect(function(input)
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

	local ScreenGui = new("ScreenGui", {
		Name = "NovaUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})

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
	end)

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

	local function setMinimized(state: boolean)
		if state == minimized then
			return
		end
		minimized = state

		if state then
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

	local altConn = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end
		if input.KeyCode == Enum.KeyCode.LeftAlt then
			setMinimized(not minimized)
		end
	end)

	makeDraggable(Bubble, Bubble, function()
		setMinimized(false)
	end)

	local function closeWindow()
		altConn:Disconnect()
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
		_openDropdownClose = nil,
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

local function baseRow(section, height: number?)
	section._rowOrder += 1
	local Row = new("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, height or 40),
		BackgroundTransparency = 1,
		LayoutOrder = section._rowOrder,
		Parent = section.Box,
	}, { corner(8) })

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
		Image = "rbxassetid://3926305904",
		ImageColor3 = Color3.new(1, 1, 1),
		ImageRectOffset = Vector2.new(312, 4),
		ImageRectSize = Vector2.new(24, 24),
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(0.75, 0.75),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Visible = state,
		Parent = Box,
	})

	new("TextLabel", {
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

	return {
		Set = function(_, value: boolean)
			state = value
			apply()
		end,
		Get = function()
			return state
		end,
	}
end

function Section:CreateToggle(opts: {
	Text: string,
	Default: boolean?,
	Callback: ((boolean) -> ())?,
})
	local Row = baseRow(self, 40)
	local state = opts.Default or false

	new("TextLabel", {
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

	return {
		Set = function(_, value: boolean)
			state = value
			apply(true)
		end,
		Get = function()
			return state
		end,
	}
end

function Section:CreateSlider(opts: {
	Text: string,
	Min: number,
	Max: number,
	Default: number?,
	Suffix: string?,
	Decimals: number?,
	Callback: ((number) -> ())?,
})
	local Row = baseRow(self, 62)
	local min, max = opts.Min, opts.Max
	local decimals = opts.Decimals or 0
	local suffix = opts.Suffix or ""
	local value = math.clamp(opts.Default or min, min, max)

	new("TextLabel", {
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

	local ValueLabel = new("TextLabel", {
		Text = "",
		FontFace = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Theme.Purple2,
		TextXAlignment = Enum.TextXAlignment.Right,
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

	local function format(v: number)
		local mult = 10 ^ decimals
		local rounded = math.round(v * mult) / mult
		if decimals == 0 then
			return tostring(math.round(rounded)) .. suffix
		end
		return string.format("%." .. decimals .. "f", rounded) .. suffix
	end

	local function setFromAlpha(alpha: number, fire: boolean?)
		alpha = math.clamp(alpha, 0, 1)
		value = min + (max - min) * alpha
		Fill.Size = UDim2.fromScale(alpha, 1)
		Thumb.Position = UDim2.fromScale(alpha, 0.5)
		ValueLabel.Text = format(value)
		if fire and opts.Callback then
			opts.Callback(value)
		end
	end
	setFromAlpha((value - min) / (max - min), false)

	local dragging = false
	local function inputToAlpha(x: number)
		local rect = Track.AbsolutePosition.X
		local width = Track.AbsoluteSize.X
		return (x - rect) / math.max(width, 1)
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			setFromAlpha(inputToAlpha(input.Position.X), true)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setFromAlpha(inputToAlpha(input.Position.X), true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return {
		Set = function(_, v: number)
			setFromAlpha((math.clamp(v, min, max) - min) / (max - min), false)
		end,
		Get = function()
			return value
		end,
	}
end

function Section:CreateDropdown(opts: {
	Text: string,
	Options: {string},
	Default: string?,
	Callback: ((string) -> ())?,
})
	local Row = baseRow(self, 38)
	local selected = opts.Default or opts.Options[1]

	local Box = new("Frame", {
		Size = UDim2.new(1, -24, 0, 32),
		Position = UDim2.fromOffset(12, 3),
		BackgroundColor3 = Theme.Bg3,
		Parent = Row,
	}, { corner(8), stroke(Theme.Line, 1) })

	local Label = new("TextLabel", {
		Text = selected,
		FontFace = FONT,
		TextSize = 13,
		TextColor3 = Theme.Text0,
		TextXAlignment = Enum.TextXAlignment.Left,
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

	local window = self._window
	local overlay = window and window.Overlay
	local page = self.Page
	local optionsHeight = #opts.Options * 30
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
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = ListHolder })

	local isOpen = false
	local heartbeatConn: RBXScriptConnection? = nil
	local outsideClickConn: RBXScriptConnection? = nil

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
		if window and window._openDropdownClose == closeList then
			window._openDropdownClose = nil
		end
	end

	openList = function()
		if window and window._openDropdownClose and window._openDropdownClose ~= closeList then
			window._openDropdownClose()
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

		tween(ListHolder, { Size = UDim2.fromOffset(Box.AbsoluteSize.X, optionsHeight), BackgroundTransparency = 0 }, 0.18, Enum.EasingStyle.Quint)
		tween(ListStroke, { Transparency = 0 }, 0.18)
		tween(Arrow, { Rotation = 180 }, 0.15)

		if window then
			window._openDropdownClose = closeList
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
		page:GetPropertyChangedSignal("Visible"):Connect(function()
			if not page.Visible then
				closeList()
			end
		end)
	end
	if window then
		window.Main:GetPropertyChangedSignal("Visible"):Connect(function()
			if not window.Main.Visible then
				closeList()
			end
		end)
		window.ScreenGui.Destroying:Connect(closeList)
	end

	for i, optionText in ipairs(opts.Options) do
		local OptBtn = new("TextButton", {
			Text = "   " .. optionText,
			FontFace = FONT,
			TextSize = 13,
			TextColor3 = Theme.Text1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 30),
			LayoutOrder = i,
			ZIndex = 6,
			Parent = ListHolder,
		})
		OptBtn.MouseEnter:Connect(function()
			OptBtn.BackgroundTransparency = 0.85
			OptBtn.BackgroundColor3 = Theme.Purple1
		end)
		OptBtn.MouseLeave:Connect(function()
			OptBtn.BackgroundTransparency = 1
		end)
		OptBtn.MouseButton1Click:Connect(function()
			selected = optionText
			Label.Text = selected
			closeList()
			if opts.Callback then
				opts.Callback(selected)
			end
		end)
	end

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

	return {
		Set = function(_, value: string)
			selected = value
			Label.Text = value
		end,
		Get = function()
			return selected
		end,
	}
end

function Section:CreateColorDisplay(opts: {
	Text: string,
	Color: Color3?,
})
	local Row = baseRow(self, 40)

	new("TextLabel", {
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

	return {
		Set = function(_, color: Color3)
			Swatch.BackgroundColor3 = color
		end,
	}
end

function Section:CreateButton(opts: {
	Text: string,
	Callback: (() -> ())?,
})
	local Row = baseRow(self, 40)

	local Btn = new("TextButton", {
		Text = opts.Text,
		FontFace = FONT_MEDIUM,
		TextSize = 13,
		TextColor3 = Color3.new(1, 1, 1),
		AutoButtonColor = false,
		BackgroundColor3 = Theme.Purple1,
		Size = UDim2.new(1, -24, 0, 30),
		Position = UDim2.fromOffset(12, 5),
		Parent = Row,
	}, { corner(8), gradient(135) })

	Btn.MouseButton1Click:Connect(function()
		tween(Btn, { BackgroundTransparency = 0.3 }, 0.08)
		task.delay(0.08, function()
			tween(Btn, { BackgroundTransparency = 0 }, 0.12)
		end)
		if opts.Callback then
			opts.Callback()
		end
	end)

	return Btn
end

return NovaUI
