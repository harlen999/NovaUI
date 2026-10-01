# NovaUI

A modern, dark-purple UI library for Roblox (Luau), built with tweened animations, a sidebar navigation layout, grouped tabs, a minimize-to-bubble system, and a full set of interactive components (checkboxes, toggles, sliders, dropdowns, buttons, and color swatches).

![Lua](https://img.shields.io/badge/language-Luau-blueviolet)
![Roblox](https://img.shields.io/badge/platform-Roblox-black)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Interactions](#interactions)
- [API Reference](#api-reference)
  - [NovaUI:CreateWindow](#novauicreatewindowconfig)
  - [Window Methods](#window-methods)
  - [Window:CreateTab](#windowcreatetabname-opts)
  - [Tab Methods](#tab-methods)
  - [Tab:CreateSection](#tabcreatesectiontitle)
  - [Section Components](#section-components)
    - [CreateCheckbox](#sectioncreatecheckboxopts)
    - [CreateToggle](#sectioncreatetoggleopts)
    - [CreateSlider](#sectioncreateslideropts)
    - [CreateDropdown](#sectioncreatedropdownopts)
    - [CreateColorDisplay](#sectioncreatecolordisplayopts)
    - [CreateButton](#sectioncreatebuttonopts)
- [Full Example](#full-example)
- [Notes & Limitations](#notes--limitations)
- [License](#license)

---

## Features

- 🪟 **Draggable window** with a minimize/close title bar
- 🫧 **Minimize-to-bubble** — collapses into a small floating, draggable icon
- ⌨️ **Alt key shortcut** to toggle minimize/restore from anywhere
- 📑 **Sidebar navigation** with tabs, optional icons, and grouped section headers
- 🎯 **Animated selection indicator** that glides to the active tab
- 🧩 **Sectioned content boxes** to organize controls inside a tab
- 🎛️ **Full component set**: checkbox, toggle, slider, dropdown, color display, button
- 🎨 **Consistent dark-purple theme** with gradients, glows, and smooth `TweenService` transitions
- 📱 Dropdowns render through a screen-level overlay, so they're never clipped by scroll frames, and auto-close if scrolled off-screen or clicked outside

---

## Installation

Host the `UI` module file (raw Luau script) somewhere accessible — e.g. a public GitHub repository — and load it with `loadstring` + `HttpGet` from a **LocalScript**:

```luau
local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/harlen999/NovaUI/refs/heads/main/Library.lua"))()
```

> Replace the URL above with the raw link to your own copy of the script.

---

## Quick Start

```luau
local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/harlen999/NovaUI/refs/heads/main/Library.lua"))()

local Window = NovaUI:CreateWindow({
    Title = "Nova",
    Version = "v1.0.0",
    Footer = { Name = "Guest", Status = "local session" },
})

local Tab = Window:CreateTab("General")
local Section = Tab:CreateSection("BEHAVIOR")

Section:CreateButton({
    Text = "Click me",
    Callback = function()
        print("Button clicked!")
    end,
})
```

---

## Interactions

| Action | Result |
|---|---|
| Drag the top bar | Moves the window |
| Click the `–` button | Minimizes the window into a floating bubble |
| Click the `×` button | Closes and destroys the UI |
| Press **Left Alt** | Toggles minimize / restore, from anywhere |
| Click the bubble (without dragging) | Restores the window |
| Drag the bubble | Repositions it on screen |

---

## API Reference

### `NovaUI:CreateWindow(config)`

Creates the `ScreenGui`, the main window frame, the title bar buttons, the sidebar, and the minimize bubble. Returns a **Window** object.

| Field | Type | Default | Description |
|---|---|---|---|
| `Title` | `string` | `"Nova"` | Brand name shown at the top of the sidebar |
| `Version` | `string` | `"v1.0.0"` | Small version string under the title |
| `Size` | `UDim2` | `UDim2.fromOffset(760, 460)` | Window size in pixels |
| `Footer` | `table \| false` | `{}` | Footer shown at the bottom of the sidebar. Pass `false` to hide it entirely. |
| `Footer.Name` | `string` | `"Convidado"` | Display name / avatar initial |
| `Footer.Status` | `string` | `"sessão local"` | Status text under the name |

```luau
local Window = NovaUI:CreateWindow({
    Title = "Nova",
    Version = "v1.4.2",
    Size = UDim2.fromOffset(760, 460),
    Footer = { Name = "Player123", Status = "connected" },
})
```

### Window Methods

| Method | Description |
|---|---|
| `Window:Minimize()` | Collapses the window into the floating bubble |
| `Window:Restore()` | Restores the window from the bubble |
| `Window:Close()` | Plays a closing animation and destroys the whole UI |

### `Window:CreateTab(name, opts)`

Adds an entry to the sidebar and a corresponding scrollable page. The **first tab created is selected automatically**. Returns a **Tab** object.

| Field | Type | Description |
|---|---|---|
| `name` | `string` | Tab name, shown in the sidebar and as the content header title |
| `opts.Group` | `string?` | Uppercase category label placed above this tab. Consecutive tabs sharing the same group are visually clustered under one header. |
| `opts.Icon` | `string?` | Asset id (e.g. `"rbxassetid://..."`) for a small icon next to the tab name |
| `opts.IconRectOffset` | `Vector2?` | Sprite-sheet offset, if `Icon` is a sprite sheet |
| `opts.IconRectSize` | `Vector2?` | Sprite-sheet crop size, if `Icon` is a sprite sheet |
| `opts.Subtitle` | `string?` | Text shown at the top-right of the content header while this tab is active |

```luau
local Combat = Window:CreateTab("Combat", {
    Group = "MAIN",
    Subtitle = "Combat-related settings",
})
```

### Tab Methods

| Method | Description |
|---|---|
| `Tab:SetSubtitle(text)` | Updates the subtitle shown in the header while this tab is active |
| `Tab:CreateSection(title)` | Creates a bordered content box on the tab's page. See below. |

### `Tab:CreateSection(title)`

Creates a rounded, bordered box on the tab's page, with `title` shown as a small caps label at the top. All components below are added inside a **Section**. Returns a **Section** object.

```luau
local Section = Tab:CreateSection("BEHAVIOR")
```

---

### Section Components

Every component lives inside a `Section` and is added in the order you call it. Most components return a table with `:Get()` and/or `:Set()` so you can read or programmatically update their value later.

#### `Section:CreateCheckbox(opts)`

A small square checkbox with an animated checkmark.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown next to the checkbox |
| `Default` | `boolean?` | Initial state (default `false`) |
| `Callback` | `(state: boolean) -> ()?` | Fired when the user toggles it |

```luau
local MyCheckbox = Section:CreateCheckbox({
    Text = "Enable main module",
    Default = true,
    Callback = function(state)
        print("Main module:", state)
    end,
})

MyCheckbox:Set(false)
print(MyCheckbox:Get())
```

#### `Section:CreateToggle(opts)`

A pill-shaped on/off switch. Same signature and return shape as `CreateCheckbox`.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown next to the switch |
| `Default` | `boolean?` | Initial state (default `false`) |
| `Callback` | `(state: boolean) -> ()?` | Fired when the user flips it |

```luau
Section:CreateToggle({
    Text = "Silent mode",
    Default = false,
    Callback = function(state)
        print("Silent mode:", state)
    end,
})
```

#### `Section:CreateSlider(opts)`

A draggable, clickable slider with a live-updating value label.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown above the slider |
| `Min` | `number` | Minimum value |
| `Max` | `number` | Maximum value |
| `Default` | `number?` | Initial value (clamped between `Min` and `Max`) |
| `Suffix` | `string?` | Text appended after the number (e.g. `"%"`, `"x"`) |
| `Decimals` | `number?` | Decimal places to display/round to (default `0`) |
| `Callback` | `(value: number) -> ()?` | Fired continuously while dragging / on click |

```luau
Section:CreateSlider({
    Text = "Speed",
    Min = 0.1,
    Max = 3,
    Default = 1,
    Decimals = 1,
    Suffix = "x",
    Callback = function(value)
        print("Speed:", value)
    end,
})
```

> ⚠️ Calling `:Set(value)` on a slider updates the visual position and label but does **not** fire `Callback`.

#### `Section:CreateDropdown(opts)`

A single-select dropdown. The option list renders in a screen-level overlay so it always appears above other UI and closes automatically if you click outside it or scroll it off-screen. Only one dropdown can be open at a time per window.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Not currently rendered as a separate label, kept for future use / clarity in your code |
| `Options` | `{string}` | List of selectable option strings |
| `Default` | `string?` | Initially selected option (defaults to the first option) |
| `Callback` | `(selected: string) -> ()?` | Fired when the user picks an option |

```luau
Section:CreateDropdown({
    Text = "Theme",
    Options = { "Dark Purple", "Midnight Violet", "Amethyst" },
    Default = "Dark Purple",
    Callback = function(selected)
        print("Theme selected:", selected)
    end,
})
```

> ⚠️ Calling `:Set(value)` on a dropdown updates the displayed label but does **not** fire `Callback`.

#### `Section:CreateColorDisplay(opts)`

A **read-only** color swatch — useful for showing the currently active accent color or theme preview. It is not an interactive color picker.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown next to the swatch |
| `Color` | `Color3?` | Initial swatch color (defaults to the theme's purple) |

```luau
local Swatch = Section:CreateColorDisplay({
    Text = "Accent color",
    Color = Color3.fromHex("A855F7"),
})

Swatch:Set(Color3.fromHex("22D3EE")) -- update it later
```

#### `Section:CreateButton(opts)`

A gradient-filled action button with a quick press animation.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Button label |
| `Callback` | `() -> ()?` | Fired on click |

```luau
Section:CreateButton({
    Text = "Reset defaults",
    Callback = function()
        print("Settings reset")
    end,
})
```

---

## Full Example

This example demonstrates every feature: window setup, grouped tabs, sections, and all components.

```luau
local NovaUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/harlen999/UITESTING/refs/heads/main/UI"))()

local Window = NovaUI:CreateWindow({
    Title = "Nova",
    Version = "v1.4.2 · purple",
    Footer = { Name = "Guest", Status = "local session" },
})

-- ===================== TAB: GENERAL (group MAIN) =====================
local General = Window:CreateTab("General", { Group = "MAIN", Subtitle = "" })

local Behavior = General:CreateSection("BEHAVIOR")

Behavior:CreateCheckbox({
    Text = "Enable main module",
    Default = true,
    Callback = function(state) print("Main module:", state) end,
})

Behavior:CreateCheckbox({
    Text = "Screen corner notifications",
    Default = false,
    Callback = function(state) print("Notifications:", state) end,
})

Behavior:CreateToggle({
    Text = "Silent mode",
    Default = false,
    Callback = function(state) print("Silent mode:", state) end,
})

Behavior:CreateToggle({
    Text = "Auto-save settings",
    Default = true,
    Callback = function(state) print("Auto-save:", state) end,
})

local FineTuning = General:CreateSection("FINE TUNING")

FineTuning:CreateSlider({
    Text = "Intensity",
    Min = 0, Max = 100, Default = 62,
    Callback = function(value) print("Intensity:", value) end,
})

FineTuning:CreateSlider({
    Text = "Speed",
    Min = 0.1, Max = 3, Default = 1, Decimals = 1, Suffix = "x",
    Callback = function(value) print("Speed:", value) end,
})

local Appearance = General:CreateSection("APPEARANCE")

Appearance:CreateColorDisplay({
    Text = "Accent color",
    Color = Color3.fromHex("A855F7"),
})

Appearance:CreateDropdown({
    Text = "Theme",
    Options = { "Dark Purple", "Midnight Violet", "Amethyst" },
    Default = "Dark Purple",
    Callback = function(selected) print("Theme selected:", selected) end,
})

-- ===================== TAB: VISUAL (group MAIN) =====================
local Visual = Window:CreateTab("Visual", { Group = "MAIN" })

local Effects = Visual:CreateSection("EFFECTS")
Effects:CreateToggle({ Text = "Smooth animations", Default = true })
Effects:CreateSlider({ Text = "Transparency", Min = 0, Max = 100, Default = 20, Suffix = "%" })

-- ===================== TAB: SETTINGS (group MAIN) =====================
local Settings = Window:CreateTab("Settings", { Group = "MAIN" })

local SettingsSection = Settings:CreateSection("GENERAL")
SettingsSection:CreateButton({
    Text = "Restore defaults",
    Callback = function() print("Settings restored") end,
})

-- ===================== TAB: PREFERENCES (group SYSTEM) =====================
local Preferences = Window:CreateTab("Preferences", { Group = "SYSTEM" })

local PrefSection = Preferences:CreateSection("ACCOUNT")
PrefSection:CreateCheckbox({ Text = "Remember session", Default = true })

print("Nova UI loaded successfully!")
```

---

## Notes & Limitations

- The color theme (dark background + purple accents) is currently hardcoded and not exposed through the public API.
- `CreateColorDisplay` is a static swatch, not an interactive color picker.
- Only one dropdown list can be open at a time; opening a second one closes the first.
- `Set()` on sliders and dropdowns updates the visual state but does **not** trigger the component's `Callback`.
- Pressing **Left Alt** toggles minimize/restore globally, so avoid overlapping it with other keybinds in your project.
## License

Add your preferred license here (e.g. MIT) or state usage terms for your script.
