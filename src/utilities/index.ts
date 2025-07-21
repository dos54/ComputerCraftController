import WebSocket from "ws"
import { pushToDb } from "../models"


export function getUpdateFromComputer(socket: WebSocket) {
    socket.send("getUpdate");

    socket.once("message", (msg) => {
        console.log("📩 Raw WebSocket Message:", msg.toString());

        try {
            const received = JSON.parse(msg.toString());

            console.log("✅ Parsed Data:", received);

            if (received && received.type === "update") {
                console.log("🎯 Received an update from:", received.computerName);
                pushToDb(`/${received.computerName}${received.computerId}`, received);
            } else {
                console.warn("⚠ Received data, but `type` is not `update`: ", received?.type);
            }
        } catch (error) {
            console.warn("⚠ Ignoring non-JSON message:", msg.toString()); // ✅ Ignore "true" messages
        }
    });
}


export async function setComputerLabel(socket: WebSocket, label: string) {
    const cmd = `setLabel ${label}`;
    sendCommand(socket, cmd);

    // const success = await confirmExecution(socket); // ✅ Wait for the confirmation message

    // if (success) {
    //     console.log("🖥️ Label set successfully.");
    // } else {
    //     console.warn("⚠ Label confirmation failed!");
    // }
}


export function confirmExecution(socket: WebSocket): Promise<boolean> {
    return new Promise((resolve) => {
        socket.once("message", (msg) => { // ✅ Only listen for the next message once
            if (msg.toString() === "true") {
                console.log("✅ Execution confirmed.");
                resolve(true);
            } else {
                console.warn("⚠ Unexpected confirmation message:", msg.toString());
                resolve(false);
            }
        });
    });
}


export function sendCommand(socket: WebSocket, input: string) {
    const [command, ...args] = input.split(" ")
    const data = {
        type: 'command',
        command,
        args,
        timestamp: Date.now()
    }
    socket.send(JSON.stringify(data))
}

