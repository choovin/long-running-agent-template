# Long-Running Agent System Template

A production-ready template for building AI agents that work effectively across multiple context windows, based on Anthropic's research on effective harnesses for long-running agents.

## Core Concepts

This template implements a two-part solution:

1. **Initializer Agent** - Sets up the environment on the first run
2. **Coding Agent** - Makes incremental progress in every session while leaving clear artifacts

## Project Structure

```
.
├── .agent/                    # Agent configuration and state
│   ├── config.yaml           # Agent configuration
│   ├── prompts/              # Agent prompts
│   │   ├── initializer.md    # Initial session prompt
│   │   └── coding.md         # Incremental progress prompt
│   └── state/                # Runtime state (git-ignored)
│       ├── session.json      # Current session info
│       └── checkpoints/      # Session checkpoints
├── features/                  # Feature management
│   ├── feature_list.json     # Comprehensive feature requirements
│   └── feature_schema.json   # JSON schema for features
├── progress/                  # Progress tracking
│   ├── claude-progress.md    # Human-readable progress log
│   └── session_logs/         # Detailed session logs
├── scripts/                   # Automation scripts
│   ├── init.sh               # Environment initialization
│   ├── start_dev.sh          # Start development server
│   ├── test_e2e.sh           # End-to-end testing
│   └── checkpoint.sh         # Create session checkpoint
├── tests/                     # Test suites
│   ├── e2e/                  # End-to-end tests
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
├── src/                       # Source code
│   └── ...                   # Your application code
├── docs/                      # Documentation
│   ├── architecture.md       # System architecture
│   ├── agent-workflow.md     # Agent workflow guide
│   └── troubleshooting.md    # Common issues and solutions
├── .gitignore
├── CLAUDE.md                  # Instructions for Claude Code
└── README.md
```

## Quick Start

### 1. Initialize the Project

```bash
# Run the initializer agent
./scripts/init.sh
```

### 2. Start Development

The coding agent will:
1. Read git logs and progress files to understand current state
2. Read feature list and choose the next priority feature
3. Start the development server and verify basic functionality
4. Implement the feature incrementally
5. Run end-to-end tests
6. Commit progress with descriptive messages
7. Update progress notes

## Key Components

### Feature List (`features/feature_list.json`)

```json
{
  "project": "Your Project Name",
  "version": "1.0.0",
  "features": [
    {
      "id": "F001",
      "category": "functional",
      "priority": "high",
      "description": "Feature description",
      "steps": [
        "Step 1: Navigate to X",
        "Step 2: Perform Y",
        "Step 3: Verify Z"
      ],
      "acceptance_criteria": [
        "Criteria 1",
        "Criteria 2"
      ],
      "passes": false,
      "last_tested": null,
      "notes": ""
    }
  ]
}
```

### Progress File (`progress/claude-progress.md`)

Tracks all work done across sessions:

```markdown
# Progress Log

## Session 2024-01-15-001
- Started: 2024-01-15 10:00
- Duration: 2 hours
- Features worked on: F001, F002
- Status: F001 complete, F002 in progress
- Commits: abc123, def456
- Notes: Basic authentication working

## Session 2024-01-16-001
...
```

### Initialization Script (`scripts/init.sh`)

Sets up the complete development environment:

```bash
#!/bin/bash
# Initializes project for long-running agent workflow
```

## Agent Workflow

### Session Start

1. **Get Bearings**
   ```bash
   pwd                    # Confirm working directory
   git log --oneline -20  # Recent changes
   cat progress/claude-progress.md  # Progress history
   ```

2. **Load Feature State**
   ```bash
   cat features/feature_list.json | jq '.features[] | select(.passes == false)'
   ```

3. **Verify Environment**
   ```bash
   ./scripts/start_dev.sh
   ./scripts/test_e2e.sh --smoke
   ```

### During Session

1. Choose ONE feature to work on
2. Implement incrementally
3. Test thoroughly (unit + e2e)
4. Mark feature as passing ONLY after verification

### Session End

1. Run full test suite
2. Commit with descriptive message
3. Update progress file
4. Create checkpoint if significant progress

## Testing Strategy

### Browser Automation Testing

Uses Playwright/Puppeteer for end-to-end testing:

```javascript
// tests/e2e/basic_flow.spec.js
test('User can send a message', async ({ page }) => {
  await page.goto('/');
  await page.fill('[data-testid="message-input"]', 'Hello');
  await page.click('[data-testid="send-button"]');
  await expect(page.locator('.response')).toBeVisible();
});
```

### Self-Verification Protocol

Before marking any feature as "passing":

1. Run unit tests: `npm test`
2. Run e2e tests: `npm run test:e2e`
3. Manual browser verification
4. Check for regressions

## Configuration

### Agent Config (`.agent/config.yaml`)

```yaml
agent:
  name: "long-running-coder"
  model: "claude-opus-4-5"
  max_context_tokens: 200000

session:
  max_duration: "4h"
  checkpoint_interval: "30m"

features:
  max_per_session: 3
  require_tests: true

testing:
  e2e_required: true
  browser_automation: true
  screenshot_on_failure: true
```

## Failure Modes and Solutions

| Problem | Solution |
|---------|----------|
| Agent declares victory too early | Feature list with explicit tests |
| Environment left in buggy state | Git commits + progress notes |
| Features marked done prematurely | Self-verification protocol |
| Time wasted figuring out setup | init.sh script |

## Best Practices

1. **Incremental Progress** - One feature at a time
2. **Clean State** - Always commit working code
3. **Documentation** - Update progress every session
4. **Testing** - Verify before marking complete
5. **Recovery** - Use git to revert bad changes

## Integration with Claude Code

This template includes a `CLAUDE.md` file with instructions for Claude Code to follow the long-running agent workflow automatically.

## References

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)
- [Claude 4 Prompting Guide](https://docs.anthropic.com/en/docs/prompting-guide)

## License

MIT