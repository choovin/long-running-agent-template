# Agent Workflow Guide

This guide explains the complete workflow for agents working on this project.

## Choosing Your Mode

This project supports two execution modes:

| Mode | Description | Best For |
|------|-------------|----------|
| **Mode A (Interactive)** | Claude implements features directly | Visibility, MCP tools, user control |
| **Mode B (Autopilot)** | Autonomous execution via CLI | Long-running tasks, parallel work |

## Mode A: Interactive Workflow

### Phase 1: Orientation (5-10 minutes)

```bash
# 1. Confirm location
pwd

# 2. Check recent git history
git log --oneline -20

# 3. Read progress file
cat progress/claude-progress.md

# 4. Check current state
git status

# 5. Check feature status using CLI
python3 scripts/dev-agent.py status
python3 scripts/dev-agent.py next
```

### Phase 2: Environment Verification (5-10 minutes)

```bash
# 1. Start development server (in background)
./scripts/start_dev.sh &

# 2. Wait for server to be ready
sleep 5

# 3. Run smoke tests
./scripts/test_e2e.sh --smoke

# If smoke tests fail:
# - STOP and fix existing bugs first
# - Do NOT start new features
```

### Phase 3: Feature Selection (5 minutes)

```bash
# Use the CLI to get next feature
python3 scripts/dev-agent.py next

# Or manually check feature details
cat features/feature_list.json | jq '.features[] | select(.id == "F00X")'

# Check dependencies
cat features/feature_list.json | jq '.features[] | select(.id == "F00X") | .dependencies'
```

1. Review failing features
2. Check priorities (critical > high > medium > low)
3. Check dependencies (all dependencies must be passing)
4. Select ONE feature to work on

### Phase 4: Implementation (variable)

1. **Plan** the implementation
   - Break feature into small steps
   - Identify files to modify/create
   - Identify tests needed

2. **Implement** incrementally
   - One small change at a time
   - Test after each change
   - Commit working states

3. **Write tests**
   - Unit tests for business logic
   - E2E tests for user flows

### Phase 5: Verification (15-30 minutes)

```bash
# 1. Run unit tests
npm test

# 2. Run E2E tests
npm run test:e2e

# 3. Specific feature test (if available)
./scripts/test_e2e.sh --feature F00X

# 4. Manual browser verification
# Use Playwright or open browser and test manually
```

### Phase 6: Documentation (10 minutes)

```bash
# 1. Update feature status
python3 scripts/dev-agent.py complete F00X

# 2. Commit changes
git add -A
git commit -m "feat: implement F00X - [description]

- What was done
- Tests added
- Any notes

Co-Authored-By: Claude <noreply@anthropic.com>"

# 3. Log progress
python3 scripts/dev-agent.py log --feature-id F00X --done "- changes" --testing "- how tested" --notes "- tips"
```

### Phase 7: Team Mode Check (once per session)

```bash
# Check for parallelizable features
python3 scripts/dev-agent.py find-parallel --count 3
```

If output shows >= 2 parallelizable features AND remaining >= 6:
- Prompt user: **"Detected N parallelizable features (M remaining). Enable Team Mode?"**

### Phase 8: Next Feature or Clear

- If context is still short: return to Phase 1
- If context is getting long or 2+ features done:
  - Ensure git status is clean
  - Say: **"Done with [N] features ([passing]/[total]). Run /clear then send 'go ahead' to continue."**
  - Wait for user

## Mode B: Autopilot Workflow

### Phase 1: Environment Setup

```bash
# Initialize environment
chmod +x scripts/init.sh && ./scripts/init.sh
```

### Phase 2: Check Status

```bash
python3 scripts/dev-agent.py status
```

### Phase 3: Start Autonomous Loop

```bash
# Basic run
python3 scripts/dev-agent.py run

# With options
python3 scripts/dev-agent.py run --max-features 10     # Limit features
python3 scripts/dev-agent.py run --parallel 3          # Parallel execution
python3 scripts/dev-agent.py run --timeout 3600        # Timeout per feature
python3 scripts/dev-agent.py run --model claude-opus-4-5  # Override model
```

The autonomous loop will:
1. Find next available feature
2. Spawn a `claude -p` process
3. Implement the feature
4. Run tests
5. Mark complete and commit
6. Continue to next feature

### Parallel Execution (Team Mode)

When running with `--parallel N`:

```
┌─────────────────────────────────────────────────────────────┐
│                    PARALLEL EXECUTION                        │
├─────────────────────────────────────────────────────────────┤
│  1. Find N parallelizable features                          │
│  2. Create git worktrees for each                           │
│  3. Spawn N claude processes in parallel                    │
│  4. Wait for completion                                     │
│  5. Merge completed worktrees                               │
│  6. Clean up                                                │
└─────────────────────────────────────────────────────────────┘
```

## CLI Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `status` | Show progress summary | `python3 scripts/dev-agent.py status` |
| `next` | Get next feature | `python3 scripts/dev-agent.py next` |
| `find-parallel` | Show parallelizable features | `python3 scripts/dev-agent.py find-parallel -n 3` |
| `complete` | Mark feature passing | `python3 scripts/dev-agent.py complete F001` |
| `skip` | Skip a feature | `python3 scripts/dev-agent.py skip F001 "blocked by API"` |
| `regression` | Pick features to verify | `python3 scripts/dev-agent.py regression` |
| `log` | Log progress | `python3 scripts/dev-agent.py log --feature-id F001 --done "..."` |
| `run` | Autonomous loop | `python3 scripts/dev-agent.py run --parallel 3` |

## Common Scenarios

### Scenario: Smoke Tests Fail

```
$ ./scripts/test_e2e.sh --smoke
[FAIL] Health check failed

[Agent] Smoke tests failed. I need to fix existing bugs first.

$ git log --oneline -3
abc123 feat: add new feature
...

[Agent] Let me investigate the issue...
[Finds and fixes the bug]

$ ./scripts/test_e2e.sh --smoke
[PASS] All smoke tests passing

[Agent] Fixed! Now I can proceed with new feature work.
```

### Scenario: Feature Has Dependencies

```
$ python3 scripts/dev-agent.py next
NEXT FEATURE: F006 (priority high)
Depends on: F005

$ python3 scripts/dev-agent.py status
Progress: 2/25 passing

[Agent] F006 depends on F005, which is not yet complete.
I need to work on F005 first.
```

### Scenario: Cannot Complete Feature

```
[Agent] I've made progress on F010, but I'm blocked by:
- External API not responding
- Need clarification on requirements

[Agent] Documenting current state...

$ python3 scripts/dev-agent.py skip F010 "Blocked: External API unavailable"
[SKIP] Feature F010 marked as SKIPPED

$ git add -A && git commit -m "wip: F010 partial implementation..."

[Agent] Moving to next feature...
```

### Scenario: If Blocked After Multiple Attempts

```
[Agent] I've tried 3 times to implement F015 but keep hitting issues.

$ python3 scripts/dev-agent.py skip F015 "Multiple failed attempts, needs investigation"
[SKIP] Feature F015 marked as SKIPPED

$ git checkout -- . && git clean -fd
[Agent] Cleaned up. Moving to next available feature.
```

## Example Session

```
═══════════════════════════════════════════════════════════════════
SESSION START - Mode A (Interactive)
═══════════════════════════════════════════════════════════════════

[Agent] I'll start by getting my bearings.

$ pwd
/home/user/my-project

$ git log --oneline -5
abc123 feat: implement user registration (F004)
def456 feat: add database models (F011)
...

$ python3 scripts/dev-agent.py status
Project: My Project
Progress: 4/25 passing (16.0%)
Remaining: 21

$ python3 scripts/dev-agent.py next
NEXT FEATURE: F005 (priority critical)
Description: User can log in with valid credentials
Category: functional

Steps:
  1. Navigate to /login
  2. Enter registered email
  3. Enter correct password
  4. Click login button
  5. Verify redirect to dashboard

$ ./scripts/start_dev.sh &
Server running on port 3000

$ ./scripts/test_e2e.sh --smoke
[PASS] Health check passed
[PASS] Homepage loads

[Agent] Environment is healthy. I will work on F005: User login.

[... implementation ...]

$ npm test
[PASS] All unit tests passing

$ npm run test:e2e
[PASS] E2E tests passing

[Agent] Feature F005 is complete.

$ python3 scripts/dev-agent.py complete F005
[PASS] Feature F005 marked as PASSING (5/25)

$ git add -A && git commit -m "feat: implement user login (F005)..."
[xyz789]

$ python3 scripts/dev-agent.py log --feature-id F005 --done "- Added login form, validation, API endpoint" --testing "- Unit tests, E2E tests, manual browser verification" --notes "- Session tokens expire after 24h"
Logged to progress/claude-progress.md

[Agent] Checking for parallelizable features...

$ python3 scripts/dev-agent.py find-parallel
Remaining features: 20
Parallelizable features found: 1
Not enough independent features for parallel execution.

[Agent] Context is still short. Continuing with next feature...

═══════════════════════════════════════════════════════════════════
SESSION END
═══════════════════════════════════════════════════════════════════

Summary:
- Feature: F005 (complete)
- Commits: xyz789
- Tests: All passing
- Progress: 5/25
- Next: F006 (user logout)
```

## Best Practices

### DO

- Always run orientation phase first
- Always verify environment before new work
- Work on ONE feature at a time
- Test thoroughly before marking complete
- Commit frequently with clear messages
- Update progress file every session
- Leave codebase in clean state
- Use the CLI tool for status management

### DON'T

- Skip orientation phase
- Start new features with failing smoke tests
- Try to implement multiple features
- Mark features passing without testing
- Leave uncommitted changes
- Leave failing tests
- Skip updating documentation
- Modify feature descriptions in feature_list.json