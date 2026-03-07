# Agent Workflow Guide

This guide explains the complete workflow for agents working on this project.

## Session Types

### Type 1: Initialization Session

**When**: First time setting up the project, or after major requirements changes.

**Prompt**: Use `.agent/prompts/initializer.md`

**Goals**:
- Set up development environment
- Generate comprehensive feature list
- Create necessary scripts
- Document initial architecture

**Duration**: Typically 1-2 hours

**Outputs**:
- Complete `features/feature_list.json`
- Working `scripts/init.sh`
- Working `scripts/start_dev.sh`
- Working `scripts/test_e2e.sh`
- Initial `progress/claude-progress.md`
- Initial git commit

### Type 2: Coding Session

**When**: All sessions after initialization.

**Prompt**: Use `.agent/prompts/coding.md`

**Goals**:
- Make incremental progress on features
- Leave codebase in clean state
- Document all work done

**Duration**: Typically 2-4 hours

**Outputs**:
- Implemented features
- Passing tests
- Git commits
- Updated progress file

## Detailed Workflow

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

# 5. Read feature list - find failing features
cat features/feature_list.json | jq '.features[] | select(.passes == false) | {id, priority, description}'
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

1. Review failing features
2. Check priorities (critical > high > medium > low)
3. Check dependencies (all dependencies must be passing)
4. Select ONE feature to work on

```bash
# Check feature details
cat features/feature_list.json | jq '.features[] | select(.id == "F00X")'

# Check dependencies
cat features/feature_list.json | jq '.features[] | select(.id == "F00X") | .dependencies'
```

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
jq '(.features[] | select(.id == "F00X")) |= . + {
  "passes": true,
  "last_tested": "'$(date -Iseconds)'",
  "tested_by": "e2e_test"
}' features/feature_list.json > features/feature_list.tmp.json
mv features/feature_list.tmp.json features/feature_list.json

# 2. Commit changes
git add -A
git commit -m "feat: implement F00X - [description]

- What was done
- Tests added
- Any notes

Co-Authored-By: Claude <noreply@anthropic.com>"

# 3. Update progress file
# Add session entry to progress/claude-progress.md
```

## Example Session

```
═══════════════════════════════════════════════════════════════════
SESSION START
═══════════════════════════════════════════════════════════════════

[Agent] I'll start by getting my bearings.

$ pwd
/home/user/my-project

$ git log --oneline -5
abc123 feat: implement user registration (F004)
def456 feat: add database models (F011)
...

$ cat progress/claude-progress.md
[Shows F005 is next: User login]

$ git status
On branch main
nothing to commit, working tree clean

[Agent] Now I'll verify the environment.

$ ./scripts/start_dev.sh &
Server running on port 3000

$ ./scripts/test_e2e.sh --smoke
✓ Health check passed
✓ Homepage loads

[Agent] Environment is healthy. Based on my analysis:
- Last session: F004 (user registration) completed
- Next feature: F005 (user login)
- Dependencies: F004 ✓ (complete)

I will work on F005: User can log in with valid credentials.

[Agent] Let me review the feature requirements...

$ cat features/feature_list.json | jq '.features[] | select(.id == "F005")'
{
  "id": "F005",
  "description": "User can log in with valid credentials",
  "steps": [...],
  "acceptance_criteria": [...]
}

[Agent] Planning implementation:
1. Create login page component
2. Add login form with validation
3. Create login API endpoint
4. Add session management
5. Write E2E test

[... implementation ...]

[Agent] Running tests...

$ npm test
✓ All unit tests passing

$ npm run test:e2e
✓ E2E tests passing

[Agent] Manual verification with Playwright...
[Tests login flow in browser]
✓ Login successful, redirected to dashboard

[Agent] Feature F005 is complete. Updating status...

$ jq '(.features[] | select(.id == "F005")) |= . + {...}'

$ git add -A && git commit -m "feat: implement user login (F005)..."
[xyz789]

[Agent] Updating progress file...

═══════════════════════════════════════════════════════════════════
SESSION END
═══════════════════════════════════════════════════════════════════

Summary:
- Feature: F005 (complete)
- Commits: xyz789
- Tests: All passing
- Next: F006 (user logout)
```

## Common Scenarios

### Scenario: Smoke Tests Fail

```
$ ./scripts/test_e2e.sh --smoke
✗ Health check failed

[Agent] Smoke tests failed. I need to fix existing bugs first.

$ git log --oneline -3
abc123 feat: add new feature
...

[Agent] Let me investigate the issue...
[Finds and fixes the bug]

$ ./scripts/test_e2e.sh --smoke
✓ All smoke tests passing

[Agent] Fixed! Now I can proceed with new feature work.
```

### Scenario: Feature Has Dependencies

```
$ cat features/feature_list.json | jq '.features[] | select(.id == "F006") | .dependencies'
["F005"]

$ cat features/feature_list.json | jq '.features[] | select(.id == "F005") | .passes'
false

[Agent] F006 depends on F005, which is not yet complete.
I need to work on F005 first.
```

### Scenario: Cannot Complete Feature

```
[Agent] I've made progress on F010, but I'm blocked by:
- External API not responding
- Need clarification on requirements

[Agent] Documenting current state...

$ git add -A && git commit -m "wip: F010 partial implementation..."

[Agent] Updating feature notes...
jq '(.features[] | select(.id == "F010")).notes = "Blocked: API issues"'

[Agent] Moving to next feature...
```

## Best Practices

### DO

- ✅ Always run orientation phase first
- ✅ Always verify environment before new work
- ✅ Work on ONE feature at a time
- ✅ Test thoroughly before marking complete
- ✅ Commit frequently with clear messages
- ✅ Update progress file every session
- ✅ Leave codebase in clean state

### DON'T

- ❌ Skip orientation phase
- ❌ Start new features with failing smoke tests
- ❌ Try to implement multiple features
- ❌ Mark features passing without testing
- ❌ Leave uncommitted changes
- ❌ Leave failing tests
- ❌ Skip updating documentation