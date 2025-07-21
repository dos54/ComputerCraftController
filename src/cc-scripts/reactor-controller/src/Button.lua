--- @class Button
--- A clickable button that delegates hit detection to its parent.
---
--- @field _parent Element The visual/interactive region this button is associated with
--- @field _onClick fun()? Function to call when the button is clicked
--- @field _isEnabled boolean Whether the button is enabled
---
--- @field new fun(self: Button, opts: { parent: Element, onClick?: fun(), isEnabled?: boolean }): Button
Button = {}
Button.__index = Button

--Constructor
function Button:new(opts)
    local obj = setmetatable({}, Button)
    obj._parent = opts.parent
    obj._onClick = opts.onClick
    obj._isEnabled = opts.isEnabled ~= false
    return obj
end

function Button:getEnabled() return self._isEnabled end

function Button:setEnabled(bool)
    if bool == nil then
        self._isEnabled = not self._isEnabled
    else
        self._isEnabled = bool
    end
end

function Button:clicked(x, y)
    if not self:getEnabled() then
        return
    end

    if self._parent and self._parent.containsPoint and self._parent:containsPoint(x, y) then
        if self._onClick then
            self._onClick()
        end
    end
end

return Button