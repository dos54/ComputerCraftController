local Element = require("src.Element")
local PixelDisplay = require("src.PixelDisplay")

local Canvas = setmetatable({}, { __index = Element })
Canvas.__index = Canvas

function Canvas:new(opts)
  local obj = Element.new(self, opts)
  setmetatable(obj, Canvas)

  obj.pixelDisplay = PixelDisplay:new(
    1, 1,
    math.floor(obj._width / 2),
    math.floor(obj._height / 3)
  )

  return obj
end

function Canvas:setPixel(x, y, color)
  self.pixelDisplay:setPixel(x, y, color)
  self:markDirty()
end

function Canvas:render()
  local x, y = self:getAbsolutePosition()
  self.pixelDisplay.originX = x
  self.pixelDisplay.originY = y
  self.pixelDisplay:render(self._monitor)
  self._dirty = false
end

return Canvas
