local url = "ws://10.0.0.100:3000/"
print("Connecting to: " .. url)

local ws = assert(http.websocket(url))
local message = "Ready to receive"
ws.send(message)
print("Message sent!")
print(ws.receive())
ws.close()
