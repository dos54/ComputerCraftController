local url = "ws://10.0.0.100:3000/"

local childZState = -1

local Box = require("src.Box")
local Canvas = require("src.Canvas")
local Element = require("src.Element")
local Button = require("src.Button")

local WSHandler = require("src.WSHandler")
local websocketHandler = WSHandler:new(url)
if websocketHandler:connect() then
    print("Connection successful")
end

local monitor = peripheral.find("monitor")
monitor.setTextScale(.5)
monitor.setBackgroundColor(colors.black)
monitor.clear()

local reactor = peripheral.find("BigReactors-Reactor")

local function changeControlRodDepth(v)
    local currentLevel = reactor.getControlRodLevel(0)
    local newLevel = math.max(0, math.min(100, currentLevel + v))
    reactor.setAllControlRodLevels(newLevel)
end

local function trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Monitor size
local w, h = monitor.getSize()

-- Root element
local root = Element:new {
    x = 1, y = 1,
    width = w,
    height = h,
    monitor = monitor,
    backgroundColor = colors.white
}

local container = Box:new {
    color = colors.black,
    textColor = colors.black,
    backgroundColor = colors.lightBlue,
    x = 0, y = 30,
    height = 30, width = root:getWidth(),
    hasOutline = true,
    outlineColor = colors.orange,
    parent = root,
}

local plus10 = Box:new {
    backgroundColor = colors.white,
    textColor = colors.black,
    x = 10, y = 25,
    width = 10, height = 3,
    label = "+10",
    parent = container
}

local minus10 = Box:new {
    backgroundColor = colors.white,
    textColor = colors.black,
    x = 22, y = 25,
    width = 10, height = 3,
    label = "-10",
    parent = container
}

local add10 = Button:new {
    parent = plus10,
    onClick = function()
        changeControlRodDepth(10)
    end
}

local sub10 = Button:new {
    parent = minus10,
    onClick = function()
        changeControlRodDepth(-10)
    end
}

local displayRodLevel = Box:new {
    backgroundColor = colors.yellow,
    textColor = colors.black,
    x = plus10:getX(), y = plus10:getY() - 4,
    width = 1, height = 3,
    label = "%",
    parent = container,
}

local displayEnergyLevel = Box:new {
    backgroundColor = colors.yellow,
    textColor = colors.black,
    x = displayRodLevel:getX(), y = displayRodLevel:getY() - 4,
    width = 1, height = 3,
    label = "%",
    parent = container,
}

-- Initial render
Element:renderAllDirty()

local function handleDisplayRodLevel()
    local maxWidth = 22
    local currentRodLevel = reactor.getControlRodLevel(0)
    local scaledWidth = math.max(3, math.floor(currentRodLevel / 100 * maxWidth))
    displayRodLevel:setWidth(scaledWidth)
    displayRodLevel:setLabel(currentRodLevel .. "%")
end

local function handleDisplayEnergyLevel()
    local maxWidth = 22
    local currentEnergyLevel = reactor.getEnergyStored()
    local energyCapacity = reactor.getEnergyCapacity()

    local percEnergyStored = math.floor(currentEnergyLevel / energyCapacity * 100)

    local scaledWidth = math.max(3, math.floor(percEnergyStored / 100 * maxWidth))
    displayEnergyLevel:setWidth(scaledWidth)
    displayEnergyLevel:setLabel(percEnergyStored .. "%")
end

local function animationLoop()
    while true do
        handleDisplayEnergyLevel()
        handleDisplayRodLevel()
        Element:renderAllDirty()
        sleep(0.05)
    end
end

print(w)

local function inputLoop()
    while true do
        local _, _, x, y = os.pullEvent("monitor_touch")
        add10:clicked(x, y)
        sub10:clicked(x, y)
    end
end

local function websocketLoop()
    websocketHandler:listenLoop(
        function(msg)
            print("Received: " .. msg)
            local spaceIndex = msg:find(" ", 1, true)
            local command, args
            if spaceIndex then
                command = msg:sub(1, spaceIndex - 1)
                args = msg:sub(spaceIndex + 1)
            else
                command = msg
                args = ""
            end

            if command == "insert" then
                changeControlRodDepth(tonumber(trim(args)))
            elseif command == "print" then
                print(args)
            end
        end
    )
end

-- Event loop
parallel.waitForAny(animationLoop, inputLoop, websocketLoop)
