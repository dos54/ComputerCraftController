import express from 'express';
import WebSocket from 'ws';
import { db } from './config/db';
import { getFromDb, pushToDb } from './models';
import dotenv from 'dotenv';
import { json } from 'stream/consumers';
import * as utilities from './utilities/index'
import readline from 'readline'

dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

// JSONdb Example
pushToDb('/test', {key: 'value'}); // Save to JSON file


getFromDb("/").then((data) => {
  console.log("Here's the data: ", data)
})

// REST Endpoint Example
app.get('/', (req, res) => {
  res.send('Yo, Computercraft is connected with TypeScript and JSONdb! 🚀');
});

// WebSocket Example
let connectedSocket: WebSocket | null = null;

const wss = new WebSocket.Server({ noServer: true });
wss.on("connection", (ws) => {
  console.log("Connected to CC computer");
  connectedSocket = ws;

  ws.on("message", (msg) => {
    console.log(msg.toString());
  })

  ws.on("close", () => {
    console.log("Disconnected");
    if (connectedSocket === ws) connectedSocket = null;
  })

  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "Command> "
  })

  rl.prompt()

  rl.on("line", (line) => {
    if (connectedSocket && connectedSocket.readyState === connectedSocket.OPEN) {
      connectedSocket.send(line.trim());
      console.log("Message sent:", line.trim());
    } else {
      console.log("Not connected to computercraft client")
    }
    rl.prompt()
  })

});




// Start Server
const server = app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

// Attach WebSocket to Express
server.on('upgrade', (req, socket, head) => {
  wss.handleUpgrade(req, socket, head, (ws) => {
    wss.emit('connection', ws, req);
  });
});
