--- @class PixelDisplay
--- A subpixel-resolution drawing system for ComputerCraft monitors using 2x3 subpixels per character cell.
local PixelDisplay = {}
PixelDisplay.__index = PixelDisplay

local bit32 = bit32

--- Create a new PixelDisplay
---@param x number Starting X position (monitor cell coordinates)
---@param y number Starting Y position (monitor cell coordinates)
---@param cols number Width in monitor characters
---@param rows number Height in monitor characters
---@return PixelDisplay
function PixelDisplay:new(x, y, cols, rows)
  local obj = setmetatable({}, self)
  obj.originX = x
  obj.originY = y
  obj.cols = cols
  obj.rows = rows
  obj.width = cols * 2
  obj.height = rows * 3
  obj.buffer = {}
  for y = 1, obj.height do
    obj.buffer[y] = {}
    for x = 1, obj.width do
      obj.buffer[y][x] = { on = false, color = colors.white }
    end
  end
  return obj
end

--- Set a pixel at high-resolution coordinates (relative to the display)
---@param x number
---@param y number
---@param color number A colors.* constant
function PixelDisplay:setPixel(x, y, color)
  if x < 1 or x > self.width or y < 1 or y > self.height then return end
  self.buffer[y][x] = { on = true, color = color }
end

--- Clear the pixel buffer
function PixelDisplay:clear()
  for y = 1, self.height do
    for x = 1, self.width do
      self.buffer[y][x] = { on = false, color = colors.white }
    end
  end
end

--- Render the current buffer to the given monitor
---@param monitor table A wrapped monitor peripheral
function PixelDisplay:render(monitor)
  for cellY = 1, self.rows do
    local text, fg, bg = "", "", ""
    for cellX = 1, self.cols do
      local bits = 0
      local colorsOn = {}

      for dy = 0, 2 do
        for dx = 0, 1 do
          local px = (cellX - 1) * 2 + dx + 1
          local py = (cellY - 1) * 3 + dy + 1
          local bitIndex = dy * 2 + dx

          local row = self.buffer[py]
          local pixel = row and row[px]
          if pixel and pixel.on then
            bits = bit32.bor(bits, bit32.lshift(1, bitIndex))
            table.insert(colorsOn, pixel.color or colors.white)
          end
        end
      end

      local char = string.char(0x80 + bits)

      local fgColor = colorsOn[1] or colors.white
      local log2 = math.log(fgColor) / math.log(2)
      local fgHex = string.format("%x", math.floor(log2 + 0.5))

      fg = fg .. fgHex
      bg = bg .. "0"
      text = text .. char
    end

    monitor.setCursorPos(self.originX, self.originY + cellY - 1)
    monitor.blit(text, fg, bg)
  end
end

return PixelDisplay
