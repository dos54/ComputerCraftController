--- @class Box: Element
--- A UI box element with optional borders. Inherits all properties and methods from Element.
--- Used to render a bordered rectangle, respecting clipping and layering.
---
--- @field _color integer Foreground (text) color of the box
--- @field _backgroundColor integer Background color of the box
--- @field _monitor Monitor The monitor peripheral to render to
--- @field _x1 integer X position relative to parent
--- @field _y1 integer Y position relative to parent
--- @field _z integer Z-index (render order)
--- @field _width integer Width of the box in characters
--- @field _height integer Height of the box in characters
--- @field _parent Element|nil Optional parent element
--- @field _children Element[] List of child elements
--- @field _visible boolean Whether the box is visible
--- @field _dirty boolean Whether the box needs to be re-rendered
--- @field borderStyle string? Optional border style identifier
local Element = require("src.Element")
local Box = setmetatable({}, { __index = Element })
Box.__index = Box

---@class BoxOptions: ElementOptions
---@field borderStyle string?  -- Optional: if you later add border styling
---@field label string?
---@field hasOutline boolean
---@field outlineColor color

---@param opts BoxOptions
---@return Box
function Box:new(opts)
  local obj = Element.new(Box, opts)
  setmetatable(obj, Box)

  obj._label = opts.label or ""
  obj._hasOutline = opts.hasOutline == true
  obj._outlineColor = opts.outlineColor or obj._color

  return obj
end

function Box:getLabel() return self._label end

function Box:setLabel(newLabel)
  self._label = newLabel
  self:markDirty()
end

function Box:render()
  local x, y = self:getAbsolutePosition()
  local clipX, clipY, clipW, clipH = self:getClipRegion()
  if clipW <= 0 or clipH <= 0 then return end

  local monitor = self._monitor
  monitor.setTextColor(self._color)
  monitor.setBackgroundColor(self._backgroundColor)

  local function drawRow(rowY, contentX, content)
    if rowY < clipY or rowY >= clipY + clipH then return end
    local visibleStart = math.max(contentX, clipX)
    local visibleEnd = math.min(contentX + #content - 1, clipX + clipW - 1)
    if visibleEnd < visibleStart then return end

    local startIndex = visibleStart - contentX + 1
    local length = visibleEnd - visibleStart + 1
    monitor.setCursorPos(visibleStart, rowY)
    monitor.write(content:sub(startIndex, startIndex + length - 1))
  end

  local function drawColumn(colX, columnSize)
    monitor.setTextColor(self._textColor)
    if colX < clipX or colX >= clipX + clipW then return end

    local visibleStart = math.max(y, clipY)
    local visibleEnd = math.min(y + columnSize - 1, clipY + clipH - 1)
    if visibleEnd < visibleStart then return end

    for rowY = visibleStart, visibleEnd do
      monitor.setCursorPos(colX, rowY)
      monitor.write(" ")
    end
  end

  
  local width = self._width
  local height = self._height
  local label = self._label
  
  local function drawCenteredLabel()
    local startY = math.floor(height / 2) + y
    local startX = math.ceil(width / 2 - #label / 2) + x
    monitor.setBackgroundColor(self._backgroundColor)
    monitor.setTextColor(self._textColor)
    monitor.setCursorPos(startX, startY)
    monitor.write(label)
  end

  -- Top border
  drawRow(y, x, string.rep(" ", width))

  -- Side borders
  for j = 0, height do
    drawRow(y + j, x, string.rep(" ", width))
  end

  -- Bottom border
  drawRow(y + height - 1, x, string.rep(" ", width))

  if self._hasOutline then
    monitor.setBackgroundColor(self._outlineColor)
    drawRow(y, x, string.rep(" ", width))
    drawRow(y + height - 1, x, string.rep(" ", width))
    drawColumn(x, height)
    drawColumn(x + width - 1, height)
  end

  if self.label ~= "" then
    drawCenteredLabel()
  end

  self._dirty = false
end

return Box
