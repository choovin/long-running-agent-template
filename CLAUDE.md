# Project Instructions for Claude Code

This file contains instructions for Claude Code to follow when working on this project.

## Project Overview

This is a **Long-Running Agent System** designed for AI agents that need to work across multiple context windows. The system implements a harness structure based on Anthropic's research.

## Critical Rules

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

3. **ALWAYS read the feature list:**
   ```bash
   cat features/feature_list.json | jq '.features[] | select(.passes == false)'
   ```

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

### Before Ending Session

1. **Verify all tests pass:**
   ```bash
   npm test
   npm run test:e2e
   ```

2. **Commit with descriptive message:**
   ```bash
   git add -A
   git commit -m "feat: implement F00X - [description]

   - What was implemented
   - Tests added
   - Any notes

   Co-Authored-By: Claude <noreply@anthropic.com>"
   ```

3. **Update progress file:**
   - Add session entry to `progress/claude-progress.md`
   - Include what was done, commits, and next steps

4. **Update feature status (if applicable):**
   - Only mark features as `passes: true` after thorough testing
   - Update `last_tested` timestamp
   - Add notes about testing method

## Feature Workflow

### Choosing a Feature

1. Read feature list: `cat features/feature_list.json | jq '.'`
2. Filter failing features: `jq '.features[] | select(.passes == false)'`
3. Check dependencies: `jq '.features[] | select(.id == "F00X") | .dependencies'`
4. Choose highest priority with all dependencies met

### Implementing a Feature

1. Read feature details: `jq '.features[] | select(.id == "F00X")'`
2. Review acceptance criteria
3. Plan implementation steps
4. Implement step by step
5. Test after each step

### Verifying a Feature

**DO NOT mark as passing until:**

- [ ] Unit tests pass
- [ ] E2E tests pass
- [ ] Manual browser verification complete
- [ ] No regressions in other features
- [ ] Code is clean and committed

### Updating Feature Status

```bash
# Use jq to update the feature
jq '(.features[] | select(.id == "F00X")) |= . + {
  "passes": true,
  "last_tested": "'$(date -Iseconds)'",
  "tested_by": "e2e_test"
}' features/feature_list.json > features/feature_list.tmp.json
mv features/feature_list.tmp.json features/feature_list.json
```

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

## Error Handling

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

### If You Find Bugs

1. Stop new feature work
2. Document the bug
3. Fix the bug
4. Verify the fix
5. Commit with `fix:` prefix

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

## Session Templates

### Session Start

```
I'll start by getting my bearings and understanding the current state.

[Run pwd]
[Run git log]
[Read progress file]
[Check git status]

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

## Remember

> "A good session leaves the codebase cleaner than it found it."

- Clean code works
- Tests pass
- Progress is documented
- Next agent knows exactly where to start