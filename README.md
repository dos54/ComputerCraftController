# Overview

This is a simple express websocket server that allows connections from ComputerCraft computers. ComputerCraft is a mod for Minecraft that allows users to create and program computers using the Lua programming language.
[CC: Tweaked Documentation](https://tweaked.cc)
[Install CC: Tweaked from Modrinth](https://modrinth.com/mod/cc-tweaked)

The main point of writing this program is that it includes a simple server that can send/receive commands to a computercraft computer. For example, the reactor-controller program (under cc-scripts/reactor-controller) connects to an extreme reactors reactor, and allows the server in increase or decrease the control rod input by simply typing "insert {amount}" into the CLI on the server.

[Software Demo Video](http://youtube.link.goes.here)

# Network Communication

This is a client/server connection using websocket and TCP. The default port nubmer is 3000. The messages are raw, unformatted strings, though JSON serialization is possible. Each message is interpreted based on its content.

# Development Environment

- Visual Studio Code
- Git / GitHub for version control
- Node.js for the runtime environment

## Languages
- Typescript (server-side logic)
- Lua (ComputerCraft client scripts)

## Libraries
- ws: Websocket library for handling connections in node.js
- readline: Node.js module for reading console input

# Useful Websites

* [CC: Tweaked Website](https://tweaked.cc)

# Future Work

* Format messages to use JSON instead of unformatted strings
* There's some bugs involving multiple connections being made