local ansi = {}

local ESC = "\27"

local CSI = ESC.."["

local colors = {
    black = 0,
    red = 1,
    green = 2,
    yellow = 3,
    blue = 4,
    magenta = 5,
    cyan = 6,
    white = 7,
    bright_black = 8,
    bright_red = 9,
    bright_green = 10,
    bright_yellow = 11,
    bright_blue = 12,
    bright_magenta = 13,
    bright_cyan = 14,
    bright_white = 15
}

function ansi.bell()
    return "\a"
end

------------------
-- Text effects --
------------------

---@param fg_color string|table?
---@param bg_color string|table?
function ansi.color(fg_color, bg_color)
    local seq = ""
    if fg_color then
        seq = seq..ansi.foreground_color(fg_color)
    end
    if bg_color then
        seq = seq..ansi.background_color(bg_color)
    end
    return seq
end

---@param color string|table
function ansi.foreground_color(color)
    local t = type(color)
    if t == "table" then
        return CSI.."38;2;"..table.concat(color, ";").."m"
    end
    if t == "string" then
        return CSI.."38;5;"..colors[color].."m"
    end
end

---@param color string|table
function ansi.background_color(color)
    local t = type(color)
    if t == "table" then
        return CSI.."48;2;"..table.concat(color, ";").."m"
    end
    if t == "string" then
        return CSI.."48;5;"..colors[color].."m"
    end
end

function ansi.reset()
    return CSI.."0m"
end

---@param intensity -1|0|1?
function ansi.intensity(intensity)
    local seq = 22
    if intensity == -1 then
        seq = 2
    elseif intensity == 1 then
        seq = 1
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.italic(state)
    local seq = 23
    if state then
        seq = 3
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.underline(state)
    local seq = 24
    if state then
        seq = 4
    end
    return CSI..seq.."m"
end

---@param speed 0|1|2?
function ansi.blink(speed)
    local seq = 25
    if speed == 1 then
        seq = 5
    elseif speed == 2 then
        seq = 6
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.reverse(state)
    local seq = 27
    if state then
        seq = 7
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.hide(state)
    local seq = 28
    if state then
        seq = 8
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.strike(state)
    local seq = 29
    if state then
        seq = 9
    end
    return CSI..seq.."m"
end

---@param font_index 0|1|2|3|4|5|6|7|8|9|10?
function ansi.font(font_index)
    local seq = 10
    if font_index then
        seq = math.min(math.max(font_index+10, 20), 10)
    end
    return CSI..seq.."m"
end

---@param state boolean?
function ansi.overline(state)
    local seq = 54
    if state then
        seq = 55
    end
    return CSI..seq.."m"
end

--------------------
-- Cursor control -- (Not implemented in the parser)
--------------------

function ansi.push_cursor()
    return ESC..7
end

function ansi.pop_cursor()
    return ESC..8
end

---@param state boolean?
function ansi.show_cursor(state)
    local seq = "h"
    if not state then 
        seq = "l"
    end
    return CSI.."?25"..seq
end

---@param dx integer
---@param dy integer
function ansi.move_cursor(dx, dy)
    local seq = {}
    if dx > 0 then
        table.insert(seq, dx.."A")
    elseif dx < 0 then
        table.insert(seq, -dx.."B")
    end
    if dy > 0 then
        table.insert(seq, -dy.."C")
    elseif dy < 0 then
        table.insert(seq, dy.."D")
    end
    if #seq == 0 then return "" end
    return CSI..table.concat(seq, CSI)
end

---@param dy integer
function ansi.move_cursor_line(dy)
    local seq = ""
    if dy > 0 then
        seq = -dy.."F"
    elseif dy < 0 then
        seq = -dy.."E"
    end
    if seq == 0 then return "" end
    return CSI..seq
end

---@param column integer
function ansi.set_cursor_column(column)
    return CSI..column.."G"
end

---@param x integer
---@param y integer
function ansi.set_cursor_position(x, y)
    return CSI..x..";"..y.."H"
end

---@param mode string?
function ansi.clear_screen(mode)
    local seq = 3
    if mode == "before" then
        seq = 1
    elseif mode == "after" then
        seq = 0
    elseif mode == "all" then
        seq = 2
    elseif mode == "history" then
        seq = 3
    end
    return CSI..seq.."J"
end

---@param mode string?
function ansi.clear_line(mode)
    local seq = 2
    if mode == "before" then
        seq = 1
    elseif mode == "after" then
        seq = 0
    elseif mode == "all" then
        seq = 2
    end
    return CSI..seq.."K"
end

function ansi.report_cursor_position()
    return CSI.."6n"
end

------------
-- Parser --
------------

local parse

local function parse_string(s_t, i, e_q)
    local res = ""
    while true do
        local char = s_t[i]
        if char == "[" then
            local v
            v, i = parse(s_t, i, e_q)
            res = res..v
        else
            res = res..s_t[i]
        end
        i = i + 1
        if i > #s_t then break end
    end
    return res, i
end

local function parse_table(s_t, i)
    local res = {}
    local arg = ""
    i = i + 1
    while true do
        local char = s_t[i]
        if char == "}" then
            table.insert(res, arg)
            i = i + 1
            break
        elseif char == "," then
            table.insert(res, arg)
            arg = ""
        elseif char ~= " " then
            arg = arg..char
        end
        i = i + 1
    end
    return res, i
end

local function parse_arguments(s_t, i)
    local arg
    i = i + 1
    local char = s_t[i]
    if char == "{" then
        arg, i = parse_table(s_t, i)
    else
        arg = ""
        while true do
            char = s_t[i]
            if char == ")" then
                if arg == "false" then
                    arg = false
                elseif arg == "true" then
                    arg = true
                elseif tonumber(arg) then
                    arg = tonumber(arg)
                elseif arg == "" then
                    arg = nil
                end
                break
            else
                arg = arg..char
            end
            i = i + 1
        end
    end
    i = i + 1
    return arg, i
end

local function parse_function(s_t, i, e_q)
    local res = ""
    local name = ""
    local arg
    local func
    while true do
        local char = s_t[i]
        if char == "(" then
            arg, i = parse_arguments(s_t, i)
            func = ansi[name]
            if type(func) ~= "function" then error("Attempt to call an invalid function: '"..name.."'") end
            res = func(arg)
            break
        else
            name = name..char
        end
        i = i + 1
    end
    table.insert(e_q, #e_q+1, {func, arg})
    return res, i, e_q
end

local function cancel_effect(fn, arg)
    local res = ""
    if fn == ansi.color then
        res = ansi.foreground_color("white")..(arg[2] and ansi.background_color("black") or "")
    elseif fn == ansi.foreground_color then
        res = fn("white")
    elseif fn == ansi.background_color then
        res = fn("black")
    elseif fn == ansi.color then
        res = fn("white")
    elseif type(arg) == "boolean" then
        res = fn(not arg)
    elseif type(arg) == "number" then
        res = fn(0)
    end
    return res
end

local function parse_bracket(s_t, i, e_q)
    local res = ""
    i = i + 1
    res, i, e_q = parse_function(s_t, i, e_q)
    while true do
        local char = s_t[i]
        if char == "]" then
            res = res..cancel_effect(table.unpack(e_q[#e_q]))
            table.remove(e_q, #e_q)
            break
        elseif char == "[" then
            local v
            v, i = parse(s_t, i, e_q)
            res = res..v
        else
            res = res..char
        end
        i = i + 1
    end
    return res, i, e_q
end

parse = function(s_t, i, e_q)
    local char = s_t[i]
    if char == "[" then
        return parse_bracket(s_t, i, e_q)
    end
    return parse_string(s_t, i, e_q)
end

---@param s string
function ansi.format(s)
    local s_table = {}
    local effect_queue = {}
    for char in s:gmatch(utf8.charpattern) do
        s_table[#s_table+1] = char
    end
    local res, i = parse(s_table, 1, effect_queue)
    return res..ansi.reset()
end

return ansi