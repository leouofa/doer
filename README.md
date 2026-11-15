<p align="center">
  <img src="docs/images/logo.jpg" alt="Doer Logo" width="600">
</p>

# Doer

<p align="center">
  <strong>A local-first markdown todoing tool and workspace for developers.</strong>
</p>

<p align="center">
  <a href="https://ruby-lang.org"><img src="https://img.shields.io/badge/Ruby-3.4.4-CC342D?style=flat-square&logo=ruby&logoColor=white" alt="Ruby 3.4.4"></a>
  <a href="https://rubyonrails.org"><img src="https://img.shields.io/badge/Rails-8.1.4-D30001?style=flat-square&logo=rubyonrails&logoColor=white" alt="Rails 8.1.4"></a>
  <a href="https://hotwired.dev"><img src="https://img.shields.io/badge/Hotwire-Turbo%208%20%2B%20Stimulus-F3722C?style=flat-square" alt="Hotwire"></a>
  <a href="https://tailwindcss.com"><img src="https://img.shields.io/badge/Tailwind_CSS-v4-38B2AC?style=flat-square&logo=tailwind-css&logoColor=white" alt="Tailwind CSS v4"></a>
  <a href="https://www.postgresql.org"><img src="https://img.shields.io/badge/PostgreSQL-16%2B-336791?style=flat-square&logo=postgresql&logoColor=white" alt="PostgreSQL"></a>
  <img src="https://img.shields.io/badge/Architecture-Local--First-22c55e?style=flat-square" alt="Local-First Architecture">
  <a href="https://github.com/leouofa/doer-mcp"><img src="https://img.shields.io/badge/MCP_Server-doer--mcp-6366f1?style=flat-square&logo=github&logoColor=white" alt="Doer MCP Server"></a>
</p>

---

## Overview

**Doer** is a dedicated, distraction-free desktop todoing and checklist workbench designed to run locally. It allows you to organize, author, preview, and track todo lists grouped by project or kept as standalone scratchpads—with interactive preview checkboxes, instant one-click markdown copying, live split-screen previewing, drag-and-drop context file attachments, and pinned list management.

---

## Key Features

### 📁 Project & Standalone Organization
- **Structured Hierarchy**: Organize todo lists inside dedicated projects (e.g., `Personal`, `Sprint Goals`, `Product Launch`, `Refactoring`).
- **Standalone Lists**: Keep loose scratchpad todo lists without forcing project assignment.
- **Fluid Assignment**: Reassign any list to any project or back to standalone anytime via a quick dropdown.
- **Real-Time Search**: Instant client-side todo list and project filtering from the persistent sidebar.

### 📝 Markdown Checklists with 3 View Modes
- **Preview Mode**: Clean GitHub Flavored Markdown (GFM) rendering with interactive task checkboxes (`- [ ]` / `- [x]`). Toggling checkboxes in Preview mode updates the markdown source and triggers auto-save.
- **Edit Mode**: Monospaced raw Markdown editor with debounced auto-save and visual save status indicators.
- **Split Mode**: Side-by-side split screen providing live editor feedback alongside real-time rendered markdown.
- **Save Shortcut**: `⌘S` / `Ctrl+S` instant save from anywhere in the editor.

### ⚡ Zero-Latency One-Click Copy
- **Workspace Toolbar**: Prominent `Copy Markdown` button on the list workspace header.
- **List Cards**: Quick `Copy` action directly on every card in project and index listings.
- **Immediate Feedback**: Instant visual cue transitioning to `Copied!` with highlight styling.

### 📌 Pinned Lists & Reordering
- **Sidebar Quick Access**: Pin your most critical todo lists to the top of the sidebar.
- **Drag-and-Drop Reordering**: Smooth client-side reordering persisted to the database via `pinned_position`.
- **Global Toggle**: Quick-pin or unpin lists directly from cards or detail toolbars.

### 📎 ActiveStorage Dropzone Context Attachments
- **Drag-and-Drop Uploads**: Direct ActiveStorage file uploads with drag-and-drop dropzones on list pages without full-page reloads.
- **Rich Attachment Previews**: Image thumbnail rendering, formatted human-readable file sizes, download links, and instant attachment purging via Turbo Streams.

### 🖥️ Collapsible Workspace & Mobile Ergonomics
- **Collapsible Sidebar**: Toggle with `⌘\` / `Ctrl+\` or via the top-bar button.
- **Responsive Layout**: On mobile, views smoothly switch between list navigation and full-screen editor views.

### 🤖 Model Context Protocol (MCP) & REST API
- **Official MCP Server**: Connect AI coding assistants (Claude Desktop, Cursor, Gemini, Antigravity) directly to Doer via [`doer-mcp`](https://github.com/leouofa/doer-mcp).
- **Interactive Checklists & Tasks**: AI agents can inspect, create, append task items, toggle checklist items (`- [ ]` / `- [x]`), organize projects, and reorder pinned lists.
- **RESTful API & OpenAPI 3.1**: Full programmatic endpoints for todo lists, projects, attachments, search, platform stats, and markdown rendering.

---

## Architecture & Tech Stack

```mermaid
graph TD
    Browser[Client: Hotwire Turbo 8 + Stimulus]
    MCPAgent[AI Agents / MCP Clients]
    MCPServer[doer-mcp Server]
    Tailwind[Tailwind CSS v4 + Redcarpet GFM]
    Rails[Ruby on Rails 8.1 API + Web Controllers]
    Postgres[(PostgreSQL 16+)]
    Storage[Active Storage Local/Cloud Disk]

    Browser <-->|HTTP / Turbo Streams| Rails
    Browser --- Tailwind
    MCPAgent <-->|MCP JSON-RPC| MCPServer
    MCPServer <-->|REST API| Rails
    Rails <--> Postgres
    Rails <--> Storage
```

- **Backend**: Ruby 3.4+, Rails 8.1+
- **Frontend**: Hotwire (Turbo 8 + Stimulus), Tailwind CSS v4, Redcarpet GFM
- **Database**: PostgreSQL 16+
- **Attachments**: Active Storage (Local / Disk / S3 compatible)
- **API**: Comprehensive RESTful JSON API with OpenAPI 3.1 specification at `/api/v1/openapi`
- **MCP Server**: [`doer-mcp`](https://github.com/leouofa/doer-mcp) providing 19 tools, 5 resources, and sprint/task breakdown prompts

---

## Getting Started

> [!TIP]
> **Prefer running with Docker?** You can run the entire development stack (Rails on port 3010, Solid Queue background jobs, Tailwind watcher, and PostgreSQL with pgvector) in Docker Compose:
> ```sh
> docker compose up -d --build
> ```
> See [docs/DOCKER.md](docs/DOCKER.md) for full details, Tailscale access, volume persistence, and everyday commands.

### Prerequisites
- Ruby 3.4+
- PostgreSQL 16+
- Bundler

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/leouofa/doer.git
   cd doer
   ```

2. **Install Ruby dependencies**:
   ```bash
   bundle install
   ```

3. **Database Setup**:
   ```bash
   bin/rails db:create
   bin/rails db:schema:load
   ```

4. **Start the development server**:
   ```bash
   bin/dev
   ```
   Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## REST API & MCP Integration

Doer includes a complete versioned RESTful JSON API (`/api/v1`) with full OpenAPI 3.1.0 specifications, designed for easy programmatic integration and Model Context Protocol (MCP) server integration.

### Official Model Context Protocol (MCP) Server

Connect Doer directly to your AI coding agents, IDEs, and assistant workflows (such as Claude Desktop, Cursor, Gemini, and Antigravity) using the official MCP server:

🔗 **[Doer MCP Server (`doer-mcp`)](https://github.com/leouofa/doer-mcp)**

The MCP server provides 19 tools, 5 resources (`doer://`), and built-in/dynamic prompts for AI agents to:
- Browse, search, read, create, update, and manage todo lists, checklists, and projects
- Append new task items or sections (`doer_append_to_todo_list`) and toggle checklist items by index, line, or text matching (`doer_toggle_todo_item`)
- Toggle and reorder pinned lists in the workspace sidebar
- Inspect, upload, and manage ActiveStorage file attachments
- Render Markdown via Doer's server-side Redcarpet pipeline
- Deconstruct objectives into milestone checklists (`doer_breakdown_task`), plan project sprints (`doer_plan_project_sprint`), and hydrate `{{variable}}` checklist templates (`doer_use_list_template`)

### Client Integration Example (Antigravity / Claude Desktop / Cursor)

Add to your MCP configuration (e.g. `~/.gemini/antigravity/mcp_config.json` or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "doer": {
      "command": "node",
      "args": ["/path/to/doer-mcp/dist/index.js"],
      "env": {
        "DOER_API_URL": "http://localhost:3000"
      }
    }
  }
}
```

### OpenAPI Specification
- **Live Endpoint**: `GET http://localhost:3000/api/v1/openapi.json`
- **Specification File**: [`openapi.json`](openapi.json) located in repository root

### API Endpoints Summary

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `GET` | `/api/v1/stats` | Platform statistics (total lists, standalone lists, pinned lists, projects, attachments) |
| `GET` | `/api/v1/openapi` | Complete OpenAPI 3.1.0 specification |
| `POST` | `/api/v1/markdown/render` | Render raw Markdown text to sanitized HTML |
| `GET` | `/api/v1/projects` | List projects with todo list counts and search (`?q=...`) |
| `POST` | `/api/v1/projects` | Create a new project |
| `GET` | `/api/v1/projects/:id` | Get project details and associated todo lists |
| `PATCH` | `/api/v1/projects/:id` | Update project attributes |
| `DELETE` | `/api/v1/projects/:id` | Delete a project workspace (preserves todo lists as standalone) |
| `GET` | `/api/v1/todo_lists` | List todo lists (supports `?scope=standalone`, `?project_id=ID`, `?pinned=true`, `?q=query`) |
| `POST` | `/api/v1/todo_lists` | Create a new todo list or checklist |
| `GET` | `/api/v1/todo_lists/:id` | Get todo list details (`?render_markdown=true` for HTML) |
| `PATCH` | `/api/v1/todo_lists/:id` | Update a todo list |
| `DELETE` | `/api/v1/todo_lists/:id` | Delete a todo list |
| `PATCH` | `/api/v1/todo_lists/:id/toggle_pin` | Toggle pinned state of a todo list |
| `PATCH` | `/api/v1/todo_lists/reorder_pinned` | Reorder pinned lists (`{ todo_list_ids: [...] }`) |
| `GET` | `/api/v1/todo_lists/:id/attachments` | List attachments with metadata and URLs |
| `POST` | `/api/v1/todo_lists/:id/attachments` | Upload attachments (`multipart/form-data`) |
| `DELETE` | `/api/v1/todo_lists/:id/attachments/:attachment_id` | Purge attachment |

---

## License

This project is open-source and available under the MIT License.
