---
name: clickup
description: Interact with ClickUp tasks via the REST API. Use when the user references a ClickUp task ID, asks about ClickUp tasks, or wants to update task status from a development session.
---

# ClickUp

Interact with ClickUp tasks using the official REST API v2 via curl.

## Authentication

Auth is handled by `~/.claude/clickup.conf` (gitignored), which contains the `-s` flag
and `Authorization` header. The `$CLICKUP_API` env var (set in `.claude/settings.local.json`)
contains the base URL `https://api.clickup.com/api/v2`.

## curl Convention

**IMPORTANT:** Always start curl commands with `curl -K ~/.claude/clickup.conf`. This loads
auth from the config file and matches the permission rule `Bash(curl -K ~/.claude/clickup.conf:*)`.

```bash
# GET
curl -K ~/.claude/clickup.conf $CLICKUP_API/...

# PUT
curl -K ~/.claude/clickup.conf -X PUT -H "Content-Type: application/json" -d '...' $CLICKUP_API/...

# POST
curl -K ~/.claude/clickup.conf -X POST -H "Content-Type: application/json" -d '...' $CLICKUP_API/...
```

### Known permission quirks

The `Bash(curl -K ~/.claude/clickup.conf:*)` permission rule is sensitive to the command text.
These will **break auto-approval** and trigger a permission prompt:

- **Parentheses in jq expressions.** The `Bash(...)` parser sees `)` inside jq like `select(...)` or
  `(.foo // "bar")` and thinks the rule content ends there. Avoid `select()`, `if/then/else/end`,
  `(...)` grouping, and `// "default"` fallback syntax in piped jq. Filter with plain field access
  and pipe to `map` outside parens instead.
- **Quoted URLs.** Don't put `"$CLICKUP_API/..."` in double quotes. Use `$CLICKUP_API/...` unquoted.
  For query params with `&`, avoid them in the URL entirely -- fetch all results and filter with jq.
- **Colons in the command text before the final `:*`.** The prefix rule splits on `:`. Don't put
  `Authorization:` or `https://` anywhere in the raw command text -- that's why auth lives in the
  config file and the URL lives in the `$CLICKUP_API` env var.

## Workspace Structure

- **Workspace:** Scripts (`90141002370`)
- **Spaces:** Team Space (`90144498868`), Engineering (`90144575021`)
- **Engineering > Kanban > Kanban Board** (`901414599616`)

## Common Operations

### Get a task by ID

```bash
curl -K ~/.claude/clickup.conf $CLICKUP_API/task/TASK_ID | jq '{id: .id, name: .name, status: .status.status, assignees: [.assignees[].username], description: .description}'
```

### List tasks in Engineering Kanban Board

```bash
curl -K ~/.claude/clickup.conf "$CLICKUP_API/list/901414599616/task?archived=false&page=0" | jq '[.tasks[] | {id: .id, name: .name, status: .status.status, assignees: [.assignees[].username]}]'
```

### Update task status

**IMPORTANT:** Status names are custom per list. Always check available statuses first:

```bash
curl -K ~/.claude/clickup.conf $CLICKUP_API/list/LIST_ID | jq '.statuses[] | .status'
```

Then set the status using the exact name:

```bash
curl -K ~/.claude/clickup.conf -X PUT -H "Content-Type: application/json" -d '{"status": "STATUS_NAME"}' $CLICKUP_API/task/TASK_ID
```

Known statuses:

**Kanban Board (901414599616):** Open, to do, in progress, review, done
**Admin (901414561815):** backlog, scoping, in design, in development, in review, testing, ready for development, shipped, cancelled

### Add a comment to a task

```bash
curl -K ~/.claude/clickup.conf -X POST -H "Content-Type: application/json" -d '{"comment_text": "Your comment here"}' $CLICKUP_API/task/TASK_ID/comment
```

### Create a task

```bash
curl -K ~/.claude/clickup.conf -X POST -H "Content-Type: application/json" -d '{"name": "Task name", "description": "Details", "status": "Open"}' $CLICKUP_API/list/LIST_ID/task
```

### Search tasks

```bash
curl -K ~/.claude/clickup.conf "$CLICKUP_API/team/90141002370/task?custom_task_ids=true&custom_fields=[]&page=0" | jq '[.tasks[] | {id: .id, name: .name, status: .status.status}]'
```

### Read chat view messages

```bash
curl -K ~/.claude/clickup.conf $CLICKUP_API/view/VIEW_ID/comment | jq '[.comments[:10] | .[] | {id: .id, user: .user.username, date: .date, text: .comment_text}]'
```

### List workspace members

```bash
curl -K ~/.claude/clickup.conf $CLICKUP_API/team/90141002370 | jq '[.team.members[] | {id: .user.id, username: .user.username, email: .user.email}]'
```

## Member IDs

| Name | ID | Email |
|------|-----|-------|
| Allan Farinas | 204134490 | allan@scripts.co |
| Justin Myers | 94226007 | justin@scripts.co |
| Peat Bakke | 94226008 | peat@scripts.co |
| Lindsey | 94226010 | lindsey@scripts.co |
| Phoebe Thomas | 198237148 | phoebe@scripts.co |
| Kimberly Baldwin | 94226006 | help@scripts.co |
| Natasha | 94226004 | natasha@scripts.co |

## When to Use

- User says "check ClickUp task 86b90mw5z" or similar
- User asks "what's in ClickUp?" or "show me the ClickUp board"
- Starting work on a task that originated in ClickUp
- Updating ClickUp status when finishing work
- Cross-referencing ClickUp tasks with GitHub issues
- User describes a request (from email, conversation, etc.) and wants it tracked
- User asks for a harmony report, cross-reference, or sync check between GitHub and ClickUp

## Harmony Report

When the user asks "how's the harmony between GitHub and ClickUp?" or similar, run a
cross-reference of both systems:

1. **Fetch all active ClickUp tasks** (non-done) from the Kanban Board
2. **Fetch all open GitHub issues**
3. **Cross-reference** by searching for:
   - ClickUp task IDs mentioned in GitHub issue bodies
   - GitHub issue URLs mentioned in ClickUp task descriptions or comments
   - Title similarity between tasks and issues
4. **Report three buckets:**
   - **Cross-linked:** tasks that exist in both systems with links between them
   - **ClickUp-only that may need GitHub issues:** code-related tasks without a corresponding GitHub issue
   - **GitHub-only:** expected for engineering work, flag only if something looks like it originated from a ClickUp request

Keep the report concise. Don't flag Lindsey's QA automation tasks or design/UX tasks as
needing GitHub issues -- those are ClickUp-only by nature. Only flag tasks that involve
code changes to this repo.

## Workflows

Work can originate from anywhere. The goal is always: both systems cross-linked, GitHub integration handles the rest.

### ClickUp task exists, needs code work

1. **Read the ClickUp task** -- pull full details (name, description, comments, assignee)
2. **Create a GitHub issue** -- translate into a GitHub issue following CLAUDE.md conventions. Include `ClickUp: https://app.clickup.com/t/TASKID` in the issue body.
3. **Update the ClickUp task** -- add a comment: `GitHub: https://github.com/Scripts-LLC/scriptsco-web/issues/NNN`
4. **Branch naming** -- include the ClickUp task ID: `CU-TASKID-description`
5. **PR title** -- include `#TASKID` so ClickUp's native GitHub integration auto-links activity

### User describes a request (email, conversation, etc.)

1. **Create a ClickUp task** -- capture the request on the Kanban Board
2. **If it needs code:** also create a GitHub issue, cross-link both directions
3. **If it doesn't need code:** ClickUp task only, no GitHub issue needed

### GitHub issue exists, needs ClickUp visibility

1. **Create a ClickUp task** -- with `GitHub: https://github.com/Scripts-LLC/scriptsco-web/issues/NNN` in the description
2. **Update the GitHub issue** -- add `ClickUp: https://app.clickup.com/t/TASKID` to the issue body

### Non-code task (ops, admin, process)

1. **Create a ClickUp task** -- no GitHub issue needed
2. **Update status** directly in ClickUp as work progresses

## When NOT to Write to ClickUp

- Don't post comments that duplicate what the GitHub integration already captures (commits, PR links, branch activity)
- Don't update ClickUp status if GitHub activity will trigger it via the native integration

## Conventions

- ClickUp calls work items "Tasks" (not "Issues")
- ClickUp task IDs are alphanumeric (e.g., `86b91066b`), not numeric like GitHub issues
- When both a ClickUp task and GitHub issue exist, the GitHub issue is the source of truth for implementation. The ClickUp task is the source of truth for the business request.

## Safety

- Read operations are always safe
- Write operations (status changes, comments) should be confirmed with the user first
- Never create or delete tasks without explicit instruction
- The API token is personal to Justin -- actions appear as his account

## API Reference

Base URL: `https://api.clickup.com/api/v2`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/task/{id}` | GET | Get task details |
| `/task/{id}` | PUT | Update task |
| `/task/{id}/comment` | GET | List comments |
| `/task/{id}/comment` | POST | Add comment |
| `/list/{id}/task` | GET | List tasks in a list |
| `/list/{id}/task` | POST | Create task |
| `/team/{id}/task` | GET | Search tasks across workspace |
| `/team/{id}/space` | GET | List spaces |
| `/space/{id}/folder` | GET | List folders |
| `/folder/{id}/list` | GET | List lists |
| `/view/{id}/comment` | GET | Read chat view messages |
| `/view/{id}/comment` | POST | Post chat view message |
| `/team/{id}/view` | GET | List workspace views |
