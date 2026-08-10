# ANSI.lua
*ANSI API for lua*

## Installation

To use ANSI.lua, download the file **ansi.lua** and put it into a folder accessible by your lua interpreter. Then simply include it: 

```lua
ansi = require("ansi")
```

### Important!
Because every fonctions only returns an **ANSI code**, they **must** be concatenated to a string to be used.

```lua
text = ansi.color("blue").."blue text"..ansi.reset()
print(text)
```

<br>

## Definitions

_Useful definitions of **arguments** to more easily understand how to use_ **ANSI.lua**_._

### "color_name"

A **string** containing one of these supported color: 

- `black`
- `red`
- `green`
- `yellow`
- `blue`
- `magenta`
- `cyan`
- `white`
- `bright-black`
- `bright-red`
- `bright-green`
- `bright-yellow`
- `bright-blue`
- `bright-magenta`
- `bright-cyan`
- `bright-white`

### "rgb_data"

A **table** containing three **integers** (0-255) that indicate the value of red, green and blue:

`{r, g, b}`

### "color"

Either a **color_name** or **rgb_data**.

### "state"

A **boolean** that indicates if the effect should be enabled or disabled.

<br>

## Text effects

*Text effects modify how the text is displayed.*

### color()
Set the foreground (text) color and the background color using `ansi.color(fg_color, bg_color)`. The types of the arguments *fg_color* and *bg_color* are both **color**. You can omit either arguments to only change one text property.

```lua 
ansi.color("blue", {20, 10, 30}) -- Sets the text color to blue and the background color to rgb(20, 10, 30)
```
```lua 
ansi.color(nil, "bright-red") -- Sets the background color to bright-red
```

### foreground_color()
Set the foreground (text) color using `ansi.foreground_color(color)`.

```lua 
ansi.foreground_color("green") -- Sets the text color to green
```
```lua 
ansi.foreground_color({255, 255, 0}) -- Sets the text color to rgb(255, 255, 0)
```

### background_color()
Set the background color using `ansi.background_color(color)`.

```lua 
ansi.background_color("bright-yellow") -- Sets the background color to bright-yellow
```
```lua 
ansi.background_color({45, 45, 45}) -- Sets the background color to rgb(45, 45, 45)
```

### reset()
Reset all text effects using `ansi.reset()`.

```lua
ansi.reset() -- Resets all text effects to default
```

### intensity()
Set the text intensity using `ansi.intensity(intensity)`. The **intensity** can be either **-1** (faint), **0** (normal) or **1** (bold).

```lua
ansi.intensity(1) -- Sets the text intensity to bold
```

### italic()
Control the italic effect using `ansi.italic(state)`.

```lua
ansi.italic(true) -- Enables the italic effect
```

### underline()
Control the underline effect using `ansi.underline(state)`.

```lua
ansi.underline(false) -- Disables the underline effect
```

### blink()
Set the blink speed using `ansi.blink(speed)`. The **speed** can be either **0** (no blinking), **1** (slow) or **2** (fast).

```lua
ansi.blink(1) -- Sets the text's blinking speed to slow
```

### reverse()
Control the reverse (invert) effect using `ansi.reverse(state)`. This effect switches the foreground (text) and background colors.

```lua
ansi.reverse(true) -- Enables the reverse (invert) effect
```

### hide()
Control the hide effect using `ansi.hide(state)`. This effect makes the text invisible but still interactable.

```lua
ansi,hide(true) -- Enables the hide effect
```

### strike()
Control the strike effect using `ansi.strike(state)`.

```lua
ansi.strike(false) -- Disables the strike effect
```

### font()
Set the displayed font using `ansi.font(font_index)`. The font_index goes from **0** (default) to **10**.

```lua
ansi.font(0) -- Sets the displayed font to default
```

### overline()
Control the overline effect using `ansi.overline(state)`.

```lua
ansi.overline(true) -- Enables the overline effect
```

<br>

## Cursor control

*Cursor control functions modify the position and attributes of the cursor.*

### push_cursor()
Save the cursor position and properties to be restored later using `ansi.push_cursor()`.

```lua
ansi.push_cursor() -- Saves the cursor's position and properties
```

### pop_cursor()
Restore the cursor's position and properties to the most recent `ansi.push_cursor()` call using `ansi.pop_cursor()`.

```lua
ansi.pop_cursor() -- Restores the cursor's position and properties
```

### show_cursor()
Control if the cursor should be showed using `ansi.show_cursor(state)`.

```lua
ansi.show_cursor(false) -- Hides the cursor
```

### move_cursor()
Move the cursor using `ansi.move_cursor(dx, dy)`. The arguments **dx** and **dy** are both **integers** and indicate how much should the cursor move on the **x-axis** and **y-axis**.

```lua
ansi.move_cursor(10, -8) -- Moves the cursor down 10 and left 8
```

### move_cursor_line()
Move the cursor to the begining of the *__current line + dy__* line using `ansi.move_cursor_line(dy)`. The argument **y** is an **integer** and represents how many lines should the cursor go down.

```lua
ansi.move_cursor_line(1) -- Moves the cursor down one line and sets its x position to one
```

### set_cursor_column()
Set the cursor's column (x position) using `ansi.set_cursor_column(column)`. The argument **column** is an **integer**.

```lua
ansi.set_cursor_column(4) -- Sets the cursor's column (x position) to 4
```

### set_cursor_position()
Set the cursor's position using `ansi.set_cursor_position(x, y)`. The arguments **x** and **y** are both **integers**.

```lua
ansi.set_cursor_position(100, 14) -- Sets the cursor position to (100, 14)
```

### clear_screen()
Clear all or part of the screen using `ansi.clear_screen(mode)`. The **mode** is a string can either be **"before"**, **"after"**, **"all"** or **"history"**.
- **"before"** clears the part of the screen before the cursor
- **"after"** clears the part of the screen after the cursor
- **"all"** clears all the screen
- **"history"** clears all the screen plus the scroll history

```lua
ansi.clear_screen("all") -- Clears all the screen
```

### clear_line()
Clear all or part of the current line using `ansi.clear_line(mode)`. The **mode** is a string can either be **"before"**, **"after"** or **"all"**.
- **"before"** clears the part of the current line before the cursor
- **"after"** clears the part of the current line after the cursor
- **"all"** clears all the current line

```lua
ansi.clear_line("after") -- Clears the current line after the cursor
```
