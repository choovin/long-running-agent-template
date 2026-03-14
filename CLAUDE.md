# Project Instructions for Claude Code

This file contains instructions for Claude Code to follow when working on this project.

## Project Overview

This is a **Long-Running Agent System** designed for AI agents that need to work across multiple context windows. The system implements a harness structure based on Anthropic's research.

## Choose Your Mode

This project supports two execution modes. Pick ONE:

- **Mode A (Interactive)**: Claude implements features directly, you /clear between features. Better visibility, MCP/Playwright works, no extra permissions needed. **Recommended for most projects.**
- **Mode B (Autopilot)**: Claude runs `python scripts/dev-agent.py run` which spawns separate processes. Fully autonomous, but needs `--dangerously-skip-permissions` and MCP may not work.

---

## Mode A: Interactive (recommended)

### Before Starting Any Session

1. **ALWAYS run these commands first:**
   ```bash
   pwd                    # Confirm working directory
   git log --oneline -20  # Check recent history
   cat progress/claude-progress.md  # Read progress
   git status             # Check current state
   ```

2. **ALWAYS verify the environment:**
   ```bash
   ./scripts/start_dev.sh  # Start dev server
   ./scripts/test_e2e.sh --smoke  # Run smoke tests
   ```

3. **ALWAYS check the feature status:**
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

### Step 1: Orient

```bash
python3 scripts/dev-agent.py status
python3 scripts/dev-agent.py next
```

### Step 2: Implement the Feature

- Read the feature description and steps from `dev-agent.py next` output.
- Implement the functionality to satisfy ALL steps.
- Follow existing code patterns and conventions.

### Step 3: Test Thoroughly

- Write unit tests if applicable.
- Use browser testing for UI features (MCP Playwright tools).
- Run linter and build:
  - Python: pytest, ruff/flake8
  - Node: npm run lint && npm run build
- **Fix any errors before proceeding.**

### Step 4: Record & Commit

```bash
python3 scripts/dev-agent.py complete F001
git add -A && git commit -m "feat: <description> [<passing>/<total> passing]"
python3 scripts/dev-agent.py log --feature-id F001 --done "- changes" --testing "- how tested" --notes "- tips for future"
```

### Step 5: Next Feature or Clear

After completing a feature:

**Team Mode check** (only once per session):
```bash
python3 scripts/dev-agent.py find-parallel --count 3
```
If output shows >= 2 parallelizable features AND remaining >= 6:
- Prompt user: **"Detected N parallelizable features (M remaining). Enable Team Mode?"**
  - Mode A: Use Agent tool with `isolation: "worktree"` for each feature
  - Mode B: Run `python3 scripts/dev-agent.py run --parallel N`
- If user declines, do NOT ask again this session.

**Then continue normally:**
- If context is still short: go back to Step 1 immediately.
- If you've done 2+ features or context is getting long:
  - Ensure git status is clean.
  - Say: **"Done with [N] features ([passing]/[total]). Run /clear then send 'go ahead' to continue."**
  - Wait for user.

### If Blocked

After 2-3 failed attempts:
```bash
python3 scripts/dev-agent.py skip F001 "reason"
git checkout -- . && git clean -fd
```
Then go back to Step 1.

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

## CLI Commands Reference

| Command | Description |
|---------|-------------|
| `python3 scripts/dev-agent.py status` | Show progress summary |
| `python3 scripts/dev-agent.py next` | Get next feature to implement |
| `python3 scripts/dev-agent.py find-parallel` | Show parallelizable features |
| `python3 scripts/dev-agent.py complete <id>` | Mark feature as passing |
| `python3 scripts/dev-agent.py skip <id> "reason"` | Skip a feature |
| `python3 scripts/dev-agent.py regression` | Pick features to re-verify |
| `python3 scripts/dev-agent.py log --feature-id <id> --done "..." --testing "..." --notes "..."` | Log structured progress |

## Critical Rules

### Before Marking a Feature as Passing

**DO NOT mark as passing until:**

- [ ] Unit tests pass
- [ ] E2E tests pass
- [ ] Manual browser verification complete
- [ ] No regressions in other features
- [ ] Code is clean and committed

### During Work

1. **Work on ONE feature at a time**
   - Choose the highest-priority feature that is NOT passing
   - Consider feature dependencies
   - Announce your choice clearly

2. **Implement incrementally**
   - Make small, focused changes
   - Run tests after each change
   - Commit working code frequently

3. **Test thoroughly**
   - Write unit tests for new code
   - Write E2E tests for user-facing features
   - Use browser automation (Playwright) for verification

### If Tests Fail

1. **DO NOT mark the feature as passing**
2. Investigate the failure
3. Fix the issue
4. Re-run tests
5. Document in progress notes

### If You Cannot Complete

1. Document what was done
2. Document what's blocking
3. Commit progress
4. Update feature notes
5. Ask for help if needed

---

## Feature Workflow

### Choosing a Feature

1. Run `python3 scripts/dev-agent.py next` to get the next feature
2. Or manually check: `cat features/feature_list.json | jq '.features[] | select(.passes == false)'`
3. Check dependencies: `jq '.features[] | select(.id == "F00X") | .dependencies'`
4. Choose highest priority with all dependencies met

### Implementing a Feature

1. Read feature details: `jq '.features[] | select(.id == "F00X")'`
2. Review acceptance criteria
3. Plan implementation steps
4. Implement step by step
5. Test after each step

### Updating Feature Status

```bash
# Use the CLI tool (recommended)
python3 scripts/dev-agent.py complete F001

# Or use jq manually
jq '(.features[] | select(.id == "F00X")) |= . + {
  "passes": true,
  "last_tested": "'$(date -Iseconds)'",
  "tested_by": "e2e_test"
}' features/feature_list.json > features/feature_list.tmp.json
mv features/feature_list.tmp.json features/feature_list.json
```

---

## Testing

### Unit Tests

```bash
npm test                    # Run all unit tests
npm test -- --watch        # Watch mode
npm test -- path/to/test   # Run specific test
```

### E2E Tests

```bash
./scripts/test_e2e.sh              # Run all E2E tests
./scripts/test_e2e.sh --smoke      # Run smoke tests only
./scripts/test_e2e.sh --feature F001  # Test specific feature
```

### Browser Automation

For E2E testing, use Playwright:

```javascript
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();

  await page.goto('http://localhost:3000');

  // Test your feature
  await page.fill('[data-testid="input"]', 'test');
  await page.click('[data-testid="submit"]');
  await page.waitForSelector('.success');

  // Take screenshot
  await page.screenshot({ path: '/tmp/test-result.png' });

  await browser.close();
})();
```

---

## Git Workflow

### Commit Message Format

```
<type>(<scope>): <description>

[optional body]

Co-Authored-By: Claude <noreply@anthropic.com>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Commit Examples

```bash
git commit -m "feat(auth): implement user registration (F004)

- Add registration form
- Add form validation
- Add password hashing
- Add unit tests

Closes #F004

Co-Authored-By: Claude <noreply@anthropic.com>"
```

---

## Team Mode (Parallel Development)

When `find-parallel` shows multiple independent features available:

1. **Mode A approach**: Use Agent tool with `isolation: "worktree"` for each feature
2. **Mode B approach**: Run `python3 scripts/dev-agent.py run --parallel N`

Each parallel session gets its own git worktree, ensuring isolated development.

---

## Session Templates

### Session Start

```
I'll start by getting my bearings and understanding the current state.

[Run pwd]
[Run git log]
[Read progress file]
[Check git status]
[Run dev-agent.py status]

Based on my analysis:
- Last session worked on: [feature]
- Current status: [status]
- Next priority: [feature]

I will work on F00X: [description].
```

### Session End

```
Session complete. Here's what was accomplished:

1. Implemented: F00X
2. Tests: All passing
3. Commits: [hashes]
4. Progress: X/Y features complete

Next session should start with F00Y.
```

---

## File Reference

| File | Purpose |
|------|---------|
| `features/feature_list.json` | All features and their status |
| `progress/claude-progress.md` | Session-by-session progress log |
| `.agent/config.yaml` | Agent configuration |
| `.agent/prompts/initializer.md` | Initializer agent prompt |
| `.agent/prompts/coding.md` | Coding agent prompt |
| `scripts/init.sh` | Environment initialization |
| `scripts/start_dev.sh` | Start development server |
| `scripts/test_e2e.sh` | Run E2E tests |
| `scripts/checkpoint.sh` | Create session checkpoint |
| `scripts/dev-agent.py` | CLI tool for workflow management |

---

## IMPORTANT

- Only mark `passes: true` after ALL steps in the feature are verified.
- Never delete or modify task descriptions in feature_list.json.
- Never remove tasks from the list.
- Run lint + build + browser tests before marking any feature as passing.
- Fix errors before proceeding — do not skip failing tests.

---

## Remember

> "A good session leaves the codebase cleaner than it found it."

- Clean code works
- Tests pass
- Progress is documented
- Next agent knows exactly where to start