local WSHandler = {}
WSHandler.__index = WSHandler

function WSHandler:new(url)
  local obj = setmetatable({}, self)
  self.__index = self
  obj.url = url
  obj.ws = nil
  return obj
end

function WSHandler:connect()
  print("Connecting to websocket: " .. self.url)
  local ws, err = http.websocket(self.url)
  if not ws then error("Websocket connection failed: ".. err) end
  self.ws = ws
  return true
end

function WSHandler:send(data)
  if self.ws then
    self.ws.send(data)
  else
    error("Failed to send data: No existing websocket connection")
  end
end

function WSHandler:receive()
  if self.ws then
    return self.ws.receive()
  end
end

function WSHandler:close()
  if self.ws then
    self.ws.close()
  end
end

function WSHandler:listenLoop(onMessage)
  while true do
    local msg = self.ws.receive()
    if msg then
      onMessage(msg)
    end
  end
end

return WSHandler