--- @class Element
--- A base class for UI components. Manages position, size, visibility, children, rendering, and clipping.
---
--- @field _x1 integer X position relative to parent
--- @field _y1 integer Y position relative to parent
--- @field _z integer Z-index (render order)
--- @field _width integer Width of the element
--- @field _height integer Height of the element
--- @field _parent Element? Optional parent element
--- @field _children Element[] List of child elements
--- @field _color integer Foreground (text) color
--- @field _textColor integer Text color (for future use)
--- @field _backgroundColor integer Background color
--- @field _visible boolean Whether the element is visible
--- @field _dirty boolean Whether the element is marked for re-rendering
--- @field _monitor Monitor Monitor object used for rendering
--- @field renderQueue Queue<Element> Shared render queue for all elements
---
--- @field new fun(self: Element, opts: ElementOptions): Element
local Element = {}
Element.__index = Element

local Queue = require("src.Queue")

-- Shared render queue
Element.renderQueue = Queue:new(
  function(a, b)
    return a:getZ() < b:getZ()
  end
)

---@class ElementOptions
---@field x number?
---@field y number?
---@field z number?
---@field width number?
---@field height number?
---@field parent Element?
---@field color number?
---@field textColor number?
---@field backgroundColor number?
---@field visible boolean?
---@field monitor any?

---@param opts ElementOptions
---@return Element
function Element:new(opts)
  opts = opts or {}

  if opts.parent then
    opts.backgroundColor = opts.backgroundColor or opts.parent:getBackgroundColor()
  end

  local obj = setmetatable({}, self)
  obj._x1 = opts.x or 0
  obj._y1 = opts.y or 0
  obj._z = opts.z or 0
  obj._width = opts.width or 0
  obj._height = opts.height or 0
  obj._parent = opts.parent
  obj._children = {}
  obj._color = opts.color or colors.white
  obj._textColor = opts.textColor or colors.black
  obj._backgroundColor = opts.backgroundColor or colors.black
  obj._visible = opts.visible ~= false
  obj._dirty = false
  obj._monitor = opts.monitor

  if obj._parent then
    obj._parent:addChild(obj)
    obj._z = obj._z or (obj._parent:getZ() + 1)
    obj._monitor = obj._monitor or (obj._parent:getMonitor())
  end

  if opts.visible ~= false then
    obj:markDirty()
  end

  return obj
end

-- Getters and Setters

function Element:getBackgroundColor() return self._backgroundColor end

function Element:setBackgroundColor(v)
  if self._backgroundColor ~= v then
    self:clear()
    self._backgroundColor = v
    self:markDirty()
  end
end

function Element:getX() return self._x1 end

function Element:setX(v)
  if self._x1 ~= v then
    self:clear()
    self._x1 = v
    self:markDirty()
  end
end

function Element:getY() return self._y1 end

function Element:setY(v)
  if self._y1 ~= v then
    self:clear()
    self._y1 = v
    self:markDirty()
  end
end

function Element:getZ() return self._z end

function Element:setZ(v)
  if self._z ~= v then
    self._z = v
    self:markDirty()
  end
end

function Element:getWidth() return self._width end

function Element:setWidth(v)
  if self._width ~= v then
    self:clear()
    self._width = v
    self:markDirty()
  end
end

function Element:getHeight() return self._height end

function Element:setHeight(v)
  if self._height ~= v then
    self:clear()
    self._height = v
    self:markDirty()
  end
end

function Element:getColor() return self._color end

function Element:setColor(v)
  if self._color ~= v then
    self._color = v
    self:markDirty()
  end
end

function Element:getTextColor() return self._textColor end

function Element:setTextColor(v)
  if self._textColor ~= v then
    self._textColor = v
    self:markDirty()
  end
end

function Element:getVisible() return self._visible end

function Element:setVisible(bool)
  if self._visible ~= bool then
    if not bool then
      self:clear()
    end
    self._visible = bool
    self:markDirty()
  end
end

function Element:getMonitor() return self._monitor end

function Element:setMonitor(v) self._monitor = v end

function Element:getAbsolutePosition()
  if not self._parent then
    return self._x1, self._y1
  end
  local px, py = self._parent:getAbsolutePosition()
  return px + self._x1, py + self._y1
end

function Element:getClipRegion()
  local x, y = self:getAbsolutePosition()                    -- Get position
  local w, h = self._width, self._height                     -- Get width/height

  if self._parent then                                       -- If I have a parent
    local px, py = self._parent:getAbsolutePosition()        -- Get parent x and y
    local pw, ph = self._parent._width, self._parent._height -- Get parent width and height

    local clipX = math.max(x, px)                            -- Get that which is larger, my x or my parent's x
    local clipY = math.max(y, py)                            -- Same for y. So, do I clip on the left or top side? If my x or y is less than my parent then yes
    local clipX2 = math.min(x + w - 1, px + pw - 1)          -- Return that which is smaller between my max X and my parent's max X
    local clipY2 = math.min(y + h - 1, py + ph - 1)          -- Same for Y

    local clippedW = math.max(0, clipX2 - clipX + 1)
    local clippedH = math.max(0, clipY2 - clipY + 1)

    return clipX, clipY, clippedW, clippedH
  end

  return x, y, w, h
end

function Element:markDirty()
  if not self._dirty then
    self._dirty = true
    Element.renderQueue:enqueueUnique(self)
  end
  for _, child in ipairs(self._children) do
    child:markDirty()
  end
end

function Element:addChild(child)
  child._parent = self
  table.insert(self._children, child)
end

function Element:getChildren() return self._children end

function Element:render()
  -- Override this in derived classes
  self._dirty = false
end

function Element:containsPoint(px, py)
  local x, y = self:getAbsolutePosition()
  return px >= x and px < x + self._width
    and py >= y and py < y + self._height
end

function Element:clear()
  if not self:getVisible() then return end

  -- First clear all children (bottom-up)
  for _, child in ipairs(self._children) do
    child:clear()
  end

  -- Then clear self (top-down)
  local x, y = self:getAbsolutePosition()
  local clipX, clipY, clipW, clipH = self:getClipRegion()
  local monitor = self._monitor
  local bg = self._parent and self._parent:getBackgroundColor() or self._backgroundColor
  monitor.setBackgroundColor(bg)

  for row = 0, self._height - 1 do
    local cy = y + row
    if cy >= clipY and cy < clipY + clipH then
      local visibleStart = math.max(x, clipX)
      local visibleEnd = math.min(x + self._width - 1, clipX + clipW - 1)
      if visibleEnd >= visibleStart then
        monitor.setCursorPos(visibleStart, cy)
        monitor.write(string.rep(" ", visibleEnd - visibleStart + 1))
      end
    end
  end
end

function Element:renderAllDirty()
  for _, element in ipairs(Element.renderQueue:drain()) do
    if element._visible then
      element:clear()  -- Clear old state first
      element:render() -- Then re-render cleanly
    else
      element:clear()
    end
    element._dirty = false
  end
end

return Element
