local users = {}
local keyword = ""

local Stack = require ("Stack")

local event, username, message, uuid, isHidden = os.pullEvent("chat")

local stack = Stack:new()

if users[username] ~= nil then
    local messageData =
    {
        username = username,
        message = message,
        isHidden = isHidden
    }
end