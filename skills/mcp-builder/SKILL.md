---
name: mcp-builder
description: Use when building an MCP (Model Context Protocol) server from scratch, adding tools, resources, or prompts to an MCP server, choosing between stdio and HTTP transport, or testing an MCP server with a client such as Claude Code, Claude Desktop, or the MCP Inspector.
---

# MCP Builder

Build a small, working MCP server: a process that exposes tools (functions
the model can call), resources (data the model can read), and prompts
(reusable instruction templates) over the Model Context Protocol. Start with
one tool, test it with the MCP Inspector, then add the rest. Do not build a
framework around the server before the first tool works end to end.

## Concepts

- Tool: a function the model calls with JSON arguments, for example
  `add_numbers` or `search_files`. Tools do things.
- Resource: a read-only piece of data addressed by a URI, for example
  `file:///notes/shopping.md` or `config://settings`. Resources are read.
- Prompt: a named template that returns messages, for example a
  `review-code` prompt that fills in a file path. Prompts guide the model.
- Transport: how the client talks to the server. `stdio` runs the server as
  a local subprocess; Streamable HTTP runs it as a web service.
- Server: the process that registers tools, resources, and prompts and
  answers JSON-RPC requests from a client.

## Choosing a Transport

| Situation | Transport |
|-----------|-----------|
| Local tool for one user, Claude Desktop or Claude Code | stdio |
| Shared service, remote access, multiple users | Streamable HTTP |
| Quick prototype or test | stdio, then switch to HTTP later |
| Needs authentication, rate limits, or logging | Streamable HTTP |

Use stdio unless remote access is a real requirement. It needs no port, no
auth, and no deployment; the client starts the server as a subprocess.

## Workflow

1. Name the server and its one first tool. The tool does one concrete thing
   with typed inputs and a text result, for example `add(a, b) -> sum`.
2. Pick a language: Python with the official `mcp` package, or TypeScript
   with `@modelcontextprotocol/sdk`.
3. Write the minimal server below. Register the tool, run it, and confirm
   it starts without errors before adding anything else.
4. Test with the MCP Inspector before wiring it into any client:
   `npx @modelcontextprotocol/inspector python server.py`
   Open the Inspector URL it prints, click Connect, then List Tools, then
   call the tool and check the result.
5. Add resources and prompts only after the first tool passes the
   Inspector test. One working tool beats five untested ones.
6. Wire the server into a client config (see the Claude Desktop example
   below) and call the tool from a real chat session.
7. Handle errors inside tools: return a clear error string, never raise an
   uncaught exception that kills the server process.

## Example 1: Minimal Python Server (stdio, Runnable)

Install first: `pip install mcp`. Save as `server.py`, run with
`python server.py`. The server reads JSON-RPC on stdin and writes it on
stdout; do not print anything else to stdout.

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("demo-server")

@mcp.tool()
def add(a: int, b: int) -> int:
    """Add two numbers."""
    return a + b

@mcp.resource("config://greeting")
def greeting() -> str:
    """A static greeting resource."""
    return "Hello from the demo MCP server!"

@mcp.prompt()
def review_code(path: str) -> str:
    """Review the code in the given file."""
    return f"Review the code in {path} for bugs and suggest fixes."

if __name__ == "__main__":
    mcp.run()
```

Test it: `npx @modelcontextprotocol/inspector python server.py`, then call
`add` with `{"a": 2, "b": 3}` and expect `5`.

## Example 2: Minimal TypeScript Server (stdio, Runnable)

Install first: `npm install @modelcontextprotocol/sdk zod`. Save as
`server.ts`, run with `npx tsx server.ts`.

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";

const server = new McpServer({ name: "demo-server", version: "1.0.0" });

server.tool("add", "Add two numbers",
  { a: z.number(), b: z.number() },
  async ({ a, b }) => ({
    content: [{ type: "text", text: String(a + b) }],
  })
);

const transport = new StdioServerTransport();
await server.connect(transport);
```

Test it the same way: `npx @modelcontextprotocol/inspector npx tsx server.ts`.

## Example 3: Claude Desktop Config (stdio)

Input: "Wire the Python server into Claude Desktop." Add this to the
Claude Desktop config file (`claude_desktop_config.json`), using the real
absolute path to `server.py`:

```json
{
  "mcpServers": {
    "demo-server": {
      "command": "python",
      "args": ["/absolute/path/to/server.py"]
    }
  }
}
```

Output: after restarting Claude Desktop, the `add` tool appears in the
tools list and the model can call it. For an HTTP server, use
`"url": "http://localhost:8000/mcp"` instead of `command` and `args`.

## Checklist

- One first tool, typed inputs, text result, tested in the Inspector.
- Server prints nothing to stdout except MCP protocol messages (stdio).
- Tool errors return a clear message; the server process stays alive.
- Resources use a stable URI scheme such as `file://` or `config://`.
- Prompts return plain message text with the user's input filled in.
- Client config uses an absolute path to the server file or script.
- Transport matches the use case: stdio for local, HTTP for shared.

## Pitfalls

- Printing logs to stdout on stdio: stdout is the protocol channel, so a
  stray `print()` corrupts every message. Log to stderr or a file.
- Untyped tool inputs: without a schema the model guesses argument names
  and types. Declare every argument with a type, as in both skeletons.
- A tool that does five things: split it. One tool, one job, one clear name.
- Returning huge results: cap lists and file reads, for example the first
  50 lines or 100 items, and say the result was truncated.
- Skipping the Inspector: wiring an untested server into a client wastes a
  round of debugging. Inspector first, client second.
- Hard-coding secrets in the server: read API keys from environment
  variables, never from source code or a checked-in config file.
- Changing the tool name or schema after clients depend on it: version the
  server and keep old tool names working until clients are updated.
