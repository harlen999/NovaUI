local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/harlen999/NovaUI/refs/heads/main/Library.lua"))()

local Window = NovaUI:CreateWindow({
	Title = "Nova",
	Version = "v2.0.0",
	Size = UDim2.fromOffset(760, 460),
	Footer = { Name = "Guest", Status = "local session" },
})

local General = Window:CreateTab("General", { Group = "MAIN", Subtitle = "Core settings" })

local function applySilent(state: boolean)
	General:SetSubtitle(state and "Silent mode is ON" or "Core settings")
	print("Silent mode:", state)
end

local Behavior = General:CreateSection("BEHAVIOR")

local MainCheckbox = Behavior:CreateCheckbox({
	Text = "Enable main module",
	Default = true,
	Callback = function(state)
		print("Main module:", state)
	end,
})

local NotifyCheckbox = Behavior:CreateCheckbox({
	Text = "Screen corner notifications",
	Default = false,
	Callback = function(state)
		print("Notifications:", state)
	end,
})

local SilentToggle = Behavior:CreateToggle({
	Text = "Silent mode",
	Default = false,
	Callback = applySilent,
})

local AutoSaveToggle = Behavior:CreateToggle({
	Text = "Auto-save settings",
	Default = true,
	Callback = function(state)
		print("Auto-save:", state)
	end,
})

local FineTuning = General:CreateSection("FINE TUNING")

local IntensitySlider = FineTuning:CreateSlider({
	Text = "Intensity",
	Min = 0,
	Max = 100,
	Default = 60,
	Step = 5,
	Suffix = "%",
	Callback = function(value)
		print("Intensity:", value)
	end,
})

local SpeedSlider = FineTuning:CreateSlider({
	Text = "Speed",
	Min = 0.1,
	Max = 3,
	Default = 1,
	Step = 0.1,
	Suffix = "x",
	Callback = function(value)
		print("Speed:", value)
	end,
})

local SmoothingSlider = FineTuning:CreateSlider({
	Text = "Smoothing",
	Min = 0,
	Max = 1,
	Default = 0.25,
	Decimals = 2,
	Callback = function(value)
		print("Smoothing:", value)
	end,
})

local Appearance = General:CreateSection("APPEARANCE")

local AccentColor = Appearance:CreateColorDisplay({
	Text = "Accent color",
	Color = Color3.fromHex("A855F7"),
})

local ThemeDropdown = Appearance:CreateDropdown({
	Text = "Theme",
	Options = { "Dark Purple", "Midnight Violet", "Amethyst", "Neon Blue", "Crimson", "Emerald" },
	Default = "Dark Purple",
	MaxVisible = 4,
	Callback = function(selected)
		print("Theme:", selected)
	end,
})

local TargetsDropdown = Appearance:CreateMultiDropdown({
	Text = "Targets",
	Options = { "Head", "Torso", "Arms", "Legs", "Feet" },
	Default = { "Head", "Torso" },
	MaxVisible = 5,
	Callback = function(list)
		print("Targets:", #list > 0 and table.concat(list, ", ") or "none")
	end,
})

local Inputs = Window:CreateTab("Inputs", { Group = "MAIN", Subtitle = "Text, keys and info" })

local TextBoxes = Inputs:CreateSection("TEXT BOXES")

local NameBox = TextBoxes:CreateTextBox({
	Text = "Display name",
	Placeholder = "Type a name...",
	Default = "Player",
	MaxLength = 20,
	Callback = function(text)
		print("Name:", text)
	end,
})

local DelayBox = TextBoxes:CreateTextBox({
	Text = "Delay (seconds)",
	Placeholder = "0",
	Default = 1.5,
	Numeric = true,
	EnterOnly = true,
	MaxLength = 6,
	Callback = function(number)
		print("Delay:", number)
	end,
})

local SearchBox = TextBoxes:CreateTextBox({
	Placeholder = "Search...",
	ClearOnFocus = true,
	Callback = function(text)
		print("Search:", text)
	end,
})

local Keybinds = Inputs:CreateSection("KEYBINDS")

local QuickKey = Keybinds:CreateKeybind({
	Text = "Quick toggle (Silent mode)",
	Default = Enum.KeyCode.F,
	Callback = function(key)
		local newState = not SilentToggle:Get()
		SilentToggle:Set(newState)
		applySilent(newState)
	end,
	OnChange = function(key)
		print("Quick toggle key:", key and key.Name or "none")
	end,
})

local PingKey = Keybinds:CreateKeybind({
	Text = "Print a message",
	Default = Enum.KeyCode.G,
	Callback = function(key)
		print(("Key %s pressed!"):format(key.Name))
	end,
})

local Info = Inputs:CreateSection("INFO")

local InfoLabel = Info:CreateLabel("Press Left Alt to minimize or restore the window.")

local WarnLabel = Info:CreateLabel({
	Text = "Tip: click a slider's value to type it manually.",
	Color = Color3.fromHex("A78BFA"),
})

local StatusParagraph = Info:CreateParagraph({
	Title = "About this demo",
	Text = "A <b>Paragraph</b> wraps long text automatically and grows with its content. "
		.. "Set <i>RichText = true</i> to use tags like bold and italic.",
	RichText = true,
})

local Control = Window:CreateTab("Control", { Group = "SYSTEM", Subtitle = "Methods in action" })

local SetGet = Control:CreateSection("SET & GET")

SetGet:CreateButton({
	Text = "Set values from code (:Set)",
	Callback = function()
		MainCheckbox:Set(true)
		SilentToggle:Set(true)
		IntensitySlider:Set(80)
		SpeedSlider:Set(2.5)
		ThemeDropdown:Set("Amethyst")
		TargetsDropdown:Set({ "Head", "Arms" })
		AccentColor:Set(Color3.fromHex("22D3EE"))
		NameBox:Set("Nova")
		DelayBox:Set(2.5)
		QuickKey:Set(Enum.KeyCode.H)
		applySilent(true)
	end,
})

SetGet:CreateButton({
	Text = "Print current values (:Get)",
	Callback = function()
		local quickKey = QuickKey:Get()
		print("---- Current values ----")
		print("Main module:", MainCheckbox:Get())
		print("Notifications:", NotifyCheckbox:Get())
		print("Silent mode:", SilentToggle:Get())
		print("Auto-save:", AutoSaveToggle:Get())
		print("Intensity:", IntensitySlider:Get())
		print("Speed:", SpeedSlider:Get())
		print("Smoothing:", SmoothingSlider:Get())
		print("Accent:", AccentColor:Get())
		print("Theme:", ThemeDropdown:Get())
		print("Targets:", table.concat(TargetsDropdown:Get(), ", "))
		print("Name:", NameBox:Get())
		print("Delay:", DelayBox:Get())
		print("Search:", SearchBox:Get())
		print("Quick key:", quickKey and quickKey.Name or "none")
		print("Ping key:", PingKey:Get() and PingKey:Get().Name or "none")
	end,
})

SetGet:CreateButton({
	Text = "Reset to defaults",
	Callback = function()
		MainCheckbox:Set(true)
		NotifyCheckbox:Set(false)
		SilentToggle:Set(false)
		AutoSaveToggle:Set(true)
		IntensitySlider:Set(60)
		SpeedSlider:Set(1)
		SmoothingSlider:Set(0.25)
		AccentColor:Set(Color3.fromHex("A855F7"))
		ThemeDropdown:Set("Dark Purple")
		TargetsDropdown:Set({ "Head", "Torso" })
		NameBox:Set("Player")
		DelayBox:Set(1.5)
		SearchBox:Set("")
		QuickKey:Set(Enum.KeyCode.F)
		PingKey:Set(Enum.KeyCode.G)
		applySilent(false)
	end,
})

local Dynamic = Control:CreateSection("TEXT & APPEARANCE")

local renamed = false
Dynamic:CreateButton({
	Text = "Rename components (:SetText)",
	Callback = function()
		renamed = not renamed
		MainCheckbox:SetText(renamed and "Main module (renamed)" or "Enable main module")
		SilentToggle:SetText(renamed and "Stealth mode" or "Silent mode")
		IntensitySlider:SetText(renamed and "Power" or "Intensity")
		ThemeDropdown:SetText(renamed and "Skin" or "Theme")
		TargetsDropdown:SetText(renamed and "Aim at" or "Targets")
		NameBox:SetText(renamed and "Nickname" or "Display name")
		QuickKey:SetText(renamed and "Stealth key" or "Quick toggle (Silent mode)")
		AccentColor:SetText(renamed and "Highlight color" or "Accent color")
		InfoLabel:SetText(renamed and "Labels can be renamed at any time." or "Press Left Alt to minimize or restore the window.")
	end,
})

local labelAlt = false
Dynamic:CreateButton({
	Text = "Change label text & color (:Set / :SetColor)",
	Callback = function()
		labelAlt = not labelAlt
		WarnLabel:Set(labelAlt and "Labels also support :SetColor." or "Tip: click a slider's value to type it manually.")
		WarnLabel:SetColor(labelAlt and Color3.fromHex("22D3EE") or Color3.fromHex("A78BFA"))
		StatusParagraph:SetTitle(labelAlt and "Updated title" or "About this demo")
		StatusParagraph:Set(labelAlt and "The paragraph body was replaced with <b>:Set()</b>." or "A <b>Paragraph</b> wraps long text automatically and grows with its content.")
	end,
})

Dynamic:CreateButton({
	Text = "Change search placeholder (:SetPlaceholder)",
	Callback = function()
		SearchBox:SetPlaceholder("Type to filter...")
	end,
})

local optionsSwapped = false
Dynamic:CreateButton({
	Text = "Swap dropdown options (:Refresh)",
	Callback = function()
		optionsSwapped = not optionsSwapped
		if optionsSwapped then
			ThemeDropdown:Refresh({ "Dark Purple", "Sunset", "Ocean" })
			TargetsDropdown:Refresh({ "Head", "Neck", "Chest" })
		else
			ThemeDropdown:Refresh({ "Dark Purple", "Midnight Violet", "Amethyst", "Neon Blue", "Crimson", "Emerald" })
			TargetsDropdown:Refresh({ "Head", "Torso", "Arms", "Legs", "Feet" })
		end
	end,
})

local silentHidden = false
Dynamic:CreateButton({
	Text = "Hide / show 'Silent mode' (:SetVisible)",
	Callback = function()
		silentHidden = not silentHidden
		SilentToggle:SetVisible(not silentHidden)
	end,
})

local Temp = Control:CreateSection("COMPONENT LIFECYCLE")

local TempButton = Temp:CreateButton({
	Text = "I am a temporary button",
	Callback = function()
		print("Temporary button clicked")
	end,
})

Temp:CreateButton({
	Text = "Click it from code (:Click)",
	Callback = function()
		TempButton:Click()
	end,
})

Temp:CreateButton({
	Text = "Swap its callback (:SetCallback)",
	Callback = function()
		TempButton:SetCallback(function()
			print("New callback running!")
		end)
		TempButton:SetText("My callback was swapped")
	end,
})

Temp:CreateButton({
	Text = "Remove it (:Destroy)",
	Callback = function()
		TempButton:Destroy()
	end,
})

local WindowSection = Control:CreateSection("WINDOW")

WindowSection:CreateButton({
	Text = "Minimize for 2 seconds (Window:Minimize / Restore)",
	Callback = function()
		Window:Minimize()
		task.delay(2, function()
			Window:Restore()
		end)
	end,
})

WindowSection:CreateButton({
	Text = "Close UI (Window:Close)",
	Callback = function()
		Window:Close()
	end,
})

print("Nova UI example loaded!")
