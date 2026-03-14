# Agent Workflow Template

Every new agent session MUST follow this workflow.

## Choose Your Mode

This project supports two execution modes. Pick ONE:

- **Mode A (Interactive)**: Claude implements features directly, you /clear between features. Better visibility, MCP/Playwright works, no extra permissions needed.
- **Mode B (Autopilot)**: Claude runs `python scripts/dev-agent.py run` which spawns separate processes. Fully autonomous, but needs `--dangerously-skip-permissions` and MCP may not work.

---

## Mode A: Interactive (recommended for most projects)

### Step 1: Initialize Environment

```bash
chmod +x scripts/init.sh && ./scripts/init.sh
```

**DO NOT skip this step.** Ensure the dev server / environment is running before proceeding.

### Step 2: Orient

```bash
python3 scripts/dev-agent.py status
python3 scripts/dev-agent.py next
```

If feature_list.json does not exist yet, initialize the project first:
1. Read the project spec (spec.md, app_spec.txt, README, or ask the user)
2. Generate feature_list.json with 20-200 features
3. Create scripts/init.sh for environment setup
4. Create progress/claude-progress.md
5. Then continue

### Step 3: Implement the Feature

- Read the feature description and steps from `dev-agent.py next` output.
- Implement the functionality to satisfy ALL steps.
- Follow existing code patterns and conventions.

### Step 4: Test Thoroughly

- Write unit tests if applicable.
- Use browser testing for UI features (MCP Playwright tools).
- Run linter and build:
  - Python: pytest, ruff/flake8
  - Node: npm run lint && npm run build
- **Fix any errors before proceeding.**

### Step 5: Record & Commit

```bash
python3 scripts/dev-agent.py complete <feature_id>
git add -A && git commit -m "feat: <description> [<passing>/<total> passing]"
python3 scripts/dev-agent.py log --feature-id <id> --done "- changes" --testing "- how tested" --notes "- tips for future"
```

### Step 6: Next Feature or Clear

After completing a feature:

**Team Mode check** (only once per session):
```bash
python3 scripts/dev-agent.py find-parallel --count 3
```
If output shows >= 2 parallelizable features AND remaining >= 6:
- Prompt user: **"Detected N parallelizable independent features (M remaining). Enable Team Mode?"**
  - Mode A: Use Agent tool with `isolation: "worktree"` for each feature
  - Mode B: Run `python3 scripts/dev-agent.py run --parallel N`
- If user declines, do NOT ask again this session.

**Then continue normally:**
- If context is still short: go back to Step 2 immediately.
- If you've done 2+ features or context is getting long:
  - Ensure git status is clean.
  - Say: **"Done with [N] features ([passing]/[total]). Run /clear then send 'go ahead' to continue."**
  - Wait for user.

### If Blocked

After 2-3 failed attempts:
```bash
python3 scripts/dev-agent.py skip <id> "reason"
git checkout -- . && git clean -fd
```
Then go back to Step 2.

---

## Mode B: Autopilot (fully autonomous)

### Step 1: Initialize Environment

```bash
chmod +x scripts/init.sh && ./scripts/init.sh
```

### Step 2: Check State

```bash
python3 scripts/dev-agent.py status
```

If feature_list.json does not exist, initialize the project first (same as Mode A).

### Step 3: Start Autonomous Loop

```bash
python3 scripts/dev-agent.py run
```

Options:
```bash
python3 scripts/dev-agent.py run --max-features 10    # Limit per run
python3 scripts/dev-agent.py run --timeout 3600       # 1 hour per feature
python3 scripts/dev-agent.py run --model <name>       # Override model
python3 scripts/dev-agent.py run --parallel 3         # Run 3 features in parallel (worktree isolation)
```

This spawns a separate `claude -p` process for each feature. Each gets a clean context automatically. No /clear needed.

---

## Manual Commands (both modes)

| Command | Description |
|---------|-------------|
| `python3 scripts/dev-agent.py status` | Show progress |
| `python3 scripts/dev-agent.py next` | Show next feature |
| `python3 scripts/dev-agent.py find-parallel` | Show parallelizable features |
| `python3 scripts/dev-agent.py complete <id>` | Mark feature passing |
| `python3 scripts/dev-agent.py skip <id> "reason"` | Skip a feature |
| `python3 scripts/dev-agent.py regression` | Pick features to re-verify |
| `python3 scripts/dev-agent.py log --feature-id <id> --done "..." --testing "..." --notes "..."` | Log structured progress |

## IMPORTANT

- Only mark `passes: true` after ALL steps in the feature are verified.
- Never delete or modify task descriptions in feature_list.json.
- Never remove tasks from the list.
- Run lint + build + browser tests before marking any feature as passing.
- Fix errors before proceeding — do not skip failing tests.