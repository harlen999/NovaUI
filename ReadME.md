# NovaUI

A modern, dark-purple UI library for Roblox (Luau), built with tweened animations, a sidebar navigation layout, grouped tabs, a minimize-to-bubble system, and a full set of interactive components: checkboxes, toggles, sliders, dropdowns, multi-select dropdowns, text boxes, keybinds, labels, paragraphs, buttons, and color swatches.

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
    - [CreateMultiDropdown](#sectioncreatemultidropdownopts)
    - [CreateTextBox](#sectioncreatetextboxopts)
    - [CreateKeybind](#sectioncreatekeybindopts)
    - [CreateLabel](#sectioncreatelabelopts)
    - [CreateParagraph](#sectioncreateparagraphopts)
    - [CreateColorDisplay](#sectioncreatecolordisplayopts)
    - [CreateButton](#sectioncreatebuttonopts)
  - [Component Methods](#component-methods)
- [Full Example](#full-example)
- [Notes & Limitations](#notes--limitations)
- [Upgrading from v1](#upgrading-from-v1)
- [License](#license)

---

## Features

- 🪟 **Draggable window** with a minimize/close title bar
- 🫧 **Minimize-to-bubble**: collapses into a small floating, draggable icon
- ⌨️ **Alt key shortcut** to toggle minimize/restore from anywhere
- 📑 **Sidebar navigation** with tabs, optional icons, and grouped section headers
- 🎯 **Animated selection indicator** that glides to the active tab
- 🧩 **Sectioned content boxes** to organize controls inside a tab
- 🎛️ **Full component set**: checkbox, toggle, slider, dropdown, multi-dropdown, text box, keybind, label, paragraph, color display, button
- 🔢 **Smart sliders** with `Step` snapping and click-to-type values
- 📜 **Scrollable dropdowns** with dynamic `Refresh()` of their options
- 🧰 **Uniform component API**: every component exposes `SetText`, `SetVisible`, and `Destroy`
- 🧹 **Leak-free**: every global listener is disconnected when the window closes or a component is destroyed
- 🎨 **Consistent dark-purple theme** with gradients, glows, and smooth `TweenService` transitions
- 📱 Dropdowns render through a screen-level overlay, so they're never clipped by scroll frames, and auto-close if scrolled off-screen or clicked outside

---

## Installation

Host the library file (raw Luau script) somewhere accessible, e.g. a public GitHub repository, and load it with `loadstring` + `HttpGet` from a **LocalScript**:

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
    Version = "v2.0.0",
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
| Click the `×` button | Closes and destroys the UI, disconnecting all listeners |
| Press **Left Alt** | Toggles minimize / restore, from anywhere (ignored while a keybind is capturing) |
| Click the bubble (without dragging) | Restores the window |
| Drag the bubble | Repositions it on screen |
| Click a slider's value | Lets you type an exact value |
| Click a keybind box | Starts capturing: press a key to bind it, **Esc** cancels, **Backspace/Delete** clears |

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
    Version = "v2.0.0",
    Size = UDim2.fromOffset(760, 460),
    Footer = { Name = "Player123", Status = "connected" },
})
```

### Window Methods

| Method | Description |
|---|---|
| `Window:Minimize()` | Collapses the window into the floating bubble |
| `Window:Restore()` | Restores the window from the bubble |
| `Window:Close()` | Plays a closing animation, disconnects every global listener, and destroys the whole UI |

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

Every component lives inside a `Section` and is added in the order you call it. Every component returns a table with the [common methods](#component-methods) (`SetText`, `SetVisible`, `Destroy`, and the `Instance` field) plus its own methods such as `:Get()` and `:Set()`.

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

A draggable, clickable slider with a live-updating value label. **Click the value** on the right to type an exact number.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown above the slider |
| `Min` | `number` | Minimum value |
| `Max` | `number` | Maximum value |
| `Default` | `number?` | Initial value (clamped between `Min` and `Max`) |
| `Step` | `number?` | Increment the value snaps to (e.g. `5`, `0.1`) |
| `Suffix` | `string?` | Text appended after the number (e.g. `"%"`, `"x"`) |
| `Decimals` | `number?` | Decimal places to display/round to. Inferred from `Step` when omitted, otherwise `0`. |
| `Callback` | `(value: number) -> ()?` | Fired while dragging, on click, and when a typed value is confirmed. Only fires when the value actually changes. |

```luau
local Intensity = Section:CreateSlider({
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

Section:CreateSlider({
    Text = "Speed",
    Min = 0.1,
    Max = 3,
    Default = 1,
    Step = 0.1, -- Decimals is inferred as 1
    Suffix = "x",
})
```

> ℹ️ If `Max - Min` is not a multiple of `Step`, `Max` itself may not be reachable (e.g. `Min = 0`, `Max = 10`, `Step = 3` gives 0, 3, 6, 9).

#### `Section:CreateDropdown(opts)`

A single-select dropdown. The option list renders in a screen-level overlay so it always appears above other UI and closes automatically if you click outside it or scroll it off-screen. Only one dropdown can be open at a time per window. Lists longer than `MaxVisible` become scrollable.

| Field | Type | Description |
|---|---|---|
| `Text` | `string?` | Shown as a prefix in the box, e.g. `Theme: Dark Purple`. Omit it to show only the selected value. |
| `Options` | `{string}` | List of selectable option strings (must be unique) |
| `Default` | `string?` | Initially selected option (defaults to the first option) |
| `MaxVisible` | `number?` | Max rows shown before the list scrolls (default `6`) |
| `Callback` | `(selected: string) -> ()?` | Fired when the user picks an option |

```luau
local Theme = Section:CreateDropdown({
    Text = "Theme",
    Options = { "Dark Purple", "Midnight Violet", "Amethyst" },
    Default = "Dark Purple",
    Callback = function(selected)
        print("Theme selected:", selected)
    end,
})

-- Replace the options at runtime. The current selection is kept if it still exists,
-- otherwise the first option is selected.
Theme:Refresh({ "Dark Purple", "Sunset", "Ocean" })
```

#### `Section:CreateMultiDropdown(opts)`

Same as `CreateDropdown`, but several options can be ticked at once. The list stays open while you pick, and the box shows the selected options separated by commas (or `Nenhum` when empty).

| Field | Type | Description |
|---|---|---|
| `Text` | `string?` | Prefix shown in the box |
| `Options` | `{string}` | List of selectable option strings (must be unique) |
| `Default` | `{string}?` | Initially selected options |
| `MaxVisible` | `number?` | Max rows shown before the list scrolls (default `6`) |
| `Callback` | `(selected: {string}) -> ()?` | Fired on every tick/untick, receiving the selected options **in the order of `Options`** |

```luau
local Targets = Section:CreateMultiDropdown({
    Text = "Targets",
    Options = { "Head", "Torso", "Arms", "Legs" },
    Default = { "Head" },
    Callback = function(list)
        print("Selected:", table.concat(list, ", "))
    end,
})

Targets:Set({ "Arms", "Legs" })
print(table.concat(Targets:Get(), ", "))
Targets:Refresh({ "Head", "Neck", "Chest" }) -- selections that no longer exist are dropped
```

#### `Section:CreateTextBox(opts)`

A single-line text input with a placeholder and a focus highlight.

| Field | Type | Description |
|---|---|---|
| `Text` | `string?` | Label shown on the left. Omit it and the box fills the whole row. |
| `Default` | `any?` | Initial content (converted with `tostring`) |
| `Placeholder` | `string?` | Hint shown while the box is empty |
| `Numeric` | `boolean?` | Only digits, `.` and `-` are accepted. Invalid values revert on focus loss, and the callback receives a **number**. |
| `EnterOnly` | `boolean?` | Commit only when Enter is pressed; clicking away discards the edit |
| `ClearOnFocus` | `boolean?` | Clear the content when the box gains focus (default `false`) |
| `MaxLength` | `number?` | Maximum number of characters |
| `Callback` | `(value: string \| number) -> ()?` | Fired on Enter or when focus is lost (see `EnterOnly`) |

```luau
local NameBox = Section:CreateTextBox({
    Text = "Display name",
    Placeholder = "Type a name...",
    Callback = function(text)
        print("Name:", text)
    end,
})

local DelayBox = Section:CreateTextBox({
    Text = "Delay (s)",
    Default = 1.5,
    Numeric = true,
    EnterOnly = true,
    Callback = function(number)
        print("Delay:", number)
    end,
})

NameBox:Set("Nova")
print(DelayBox:Get()) -- number, because Numeric = true
```

#### `Section:CreateKeybind(opts)`

A button that captures a keyboard key. Click it, press a key to bind it, press **Esc** to cancel, or **Backspace/Delete** to clear the binding. While capturing, the global Left Alt shortcut is suspended.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown on the left |
| `Default` | `Enum.KeyCode?` | Initially bound key |
| `Callback` | `(key: Enum.KeyCode) -> ()?` | Fired when the bound key is pressed (not fired while typing in a text box or when a game UI consumed the input) |
| `OnChange` | `(key: Enum.KeyCode?) -> ()?` | Fired when the user rebinds or clears the key (`nil` when cleared) |

```luau
local Quick = Section:CreateKeybind({
    Text = "Quick toggle",
    Default = Enum.KeyCode.F,
    Callback = function(key)
        print(key.Name, "pressed")
    end,
    OnChange = function(key)
        print("New key:", key and key.Name or "none")
    end,
})

Quick:Set(Enum.KeyCode.G)
print(Quick:Get()) -- Enum.KeyCode.G or nil
```

> Only keyboard keys can be bound; mouse buttons are not supported.

#### `Section:CreateLabel(opts)`

A single line of informational text. `opts` can also be a plain string.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | The text to display |
| `Color` | `Color3?` | Text color (defaults to the theme's secondary text color) |

```luau
local Hint = Section:CreateLabel("Press Left Alt to minimize.") -- shorthand

local Warn = Section:CreateLabel({
    Text = "Careful with this option!",
    Color = Color3.fromHex("E1526B"),
})

Warn:Set("Updated text")
Warn:SetColor(Color3.fromHex("22D3EE"))
```

#### `Section:CreateParagraph(opts)`

A multi-line block of text that wraps automatically and grows with its content, with an optional bold title.

| Field | Type | Description |
|---|---|---|
| `Title` | `string?` | Optional heading above the text |
| `Text` | `string` | Body text |
| `RichText` | `boolean?` | Enables Roblox rich text tags such as `<b>` and `<i>` in the body (default `false`) |

```luau
local Notes = Section:CreateParagraph({
    Title = "About",
    Text = "A <b>Paragraph</b> wraps long text automatically.",
    RichText = true,
})

Notes:SetTitle("New title") -- an empty string hides the title
Notes:Set("New body text")
```

#### `Section:CreateColorDisplay(opts)`

A **read-only** color swatch, useful for showing the currently active accent color or theme preview. It is not an interactive color picker.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Label shown next to the swatch |
| `Color` | `Color3?` | Initial swatch color (defaults to the theme's purple) |

```luau
local Swatch = Section:CreateColorDisplay({
    Text = "Accent color",
    Color = Color3.fromHex("A855F7"),
})

Swatch:Set(Color3.fromHex("22D3EE"))
print(Swatch:Get())
```

#### `Section:CreateButton(opts)`

A gradient-filled action button with hover and press feedback.

| Field | Type | Description |
|---|---|---|
| `Text` | `string` | Button label |
| `Callback` | `() -> ()?` | Fired on click |

```luau
local Reset = Section:CreateButton({
    Text = "Reset defaults",
    Callback = function()
        print("Settings reset")
    end,
})

Reset:SetText("Reset everything")
Reset:Click() -- fires the callback from code
Reset:SetCallback(function() print("New callback") end)
```

---

### Component Methods

Every component returns a table with the **common** methods below, plus its own **specific** ones.

**Common to all components**

| Member | Description |
|---|---|
| `.Instance` | The row `Frame` that holds the component (for custom styling or positioning) |
| `:SetText(text)` | Changes the component's label (see the table below for what it affects) |
| `:SetVisible(visible)` | Shows or hides the component. Hiding an open dropdown closes it; hiding a text box releases focus. |
| `:Destroy()` | Removes the component and disconnects its listeners |

**Specific to each component**

| Component | Methods | Notes |
|---|---|---|
| Checkbox / Toggle | `:Set(boolean)`, `:Get() -> boolean` | |
| Slider | `:Set(number)`, `:Get() -> number` | `:SetText` changes the title above the slider |
| Dropdown | `:Set(string)`, `:Get() -> string?`, `:Refresh({string})` | `:SetText` changes the prefix shown in the box |
| MultiDropdown | `:Set({string})`, `:Get() -> {string}`, `:Refresh({string})` | `:Get` returns options in the order of `Options` |
| TextBox | `:Set(any)`, `:Get() -> string \| number?`, `:SetPlaceholder(string)` | `:Get` returns a number when `Numeric = true`; `:SetText` does nothing if the box has no label |
| Keybind | `:Set(Enum.KeyCode?)`, `:Get() -> Enum.KeyCode?` | |
| Label | `:Set(string)`, `:Get() -> string`, `:SetColor(Color3)` | `:SetText` is the same as `:Set` |
| Paragraph | `:Set(string)`, `:Get() -> string`, `:SetTitle(string)` | `:SetText` is the same as `:Set` and changes the body |
| ColorDisplay | `:Set(Color3)`, `:Get() -> Color3` | |
| Button | `:Click()`, `:SetCallback(function?)` | `:SetText` changes the button label |

> ⚠️ `:Set()` never fires the component's `Callback` or `OnChange`. It only updates the visual state and the stored value. If you need the callback logic to run, call it yourself after `:Set()`.

---

## Full Example

[`Example.lua`](Example.lua) is a complete, ready-to-run script that uses **every component and every method** of the library, organized in three tabs:

| Tab | What it shows |
|---|---|
| **General** | Checkbox, Toggle, Sliders (with `Step`, inferred and explicit `Decimals`), ColorDisplay, scrollable Dropdown, MultiDropdown |
| **Inputs** | Labeled, numeric (`EnterOnly`) and label-less TextBoxes, Keybinds, Labels (string and table forms), Paragraph with rich text |
| **Control** | `:Set`, `:Get`, `:SetText`, `:SetVisible`, `:Refresh`, `:SetColor`, `:SetTitle`, `:SetPlaceholder`, `:Click`, `:SetCallback`, `:Destroy`, plus `Window:Minimize`, `Window:Restore`, `Window:Close` and `Tab:SetSubtitle` |

Run it from a **LocalScript** (or an executor) after hosting `Library.lua`:

```luau
loadstring(game:HttpGet("https://raw.githubusercontent.com/harlen999/NovaUI/refs/heads/main/Example.lua"))()
```

---

## Notes & Limitations

- The color theme (dark background + purple accents) is currently hardcoded and not exposed through the public API.
- `CreateColorDisplay` is a static swatch, not an interactive color picker.
- Only one dropdown list can be open at a time; opening a second one closes the first.
- Dropdown and MultiDropdown option names must be unique within the same list.
- `Set()` on any component updates the visual state but does **not** trigger its `Callback` / `OnChange`.
- Keybinds only capture keyboard keys, and their `Callback` does not fire while a text box has focus.
- Pressing **Left Alt** toggles minimize/restore globally (it is suspended while a keybind is capturing), so avoid overlapping it with other keybinds in your project.
- Mobile/touch accessibility (e.g. minimum touch target sizes) has not been tested yet.

---

## Upgrading from v1

- `CreateButton` now returns the standard component table instead of the raw `TextButton`. Use `btn:SetText("...")`, `btn:Click()`, or `btn.Instance` (the row frame) instead of accessing the button directly.
- `CreateDropdown`'s `Text` option is now rendered as a prefix (`Theme: Dark Purple`). Omit `Text` to keep the old look.
- The button gradient was moved to a separate frame so it no longer tints the button text.
- Global listeners (slider drag, window dragging, Alt shortcut, keybinds) are now disconnected on `Window:Close()` and on `:Destroy()`.

---

## License

Add your preferred license here (e.g. MIT) or state usage terms for your script.
