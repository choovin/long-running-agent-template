# System Architecture

This document describes the architecture of the Long-Running Agent System.

## Overview

The system is designed to enable AI agents to work effectively across multiple context windows by implementing a harness structure with clear state management and progress tracking.

## Key Features

- **Dual Execution Modes**: Interactive and Autopilot modes for different workflows
- **CLI Automation**: `dev-agent.py` tool for workflow management
- **Team Mode**: Parallel development with git worktree isolation
- **YAML Configuration**: Flexible configuration system

## Core Components

### 1. Initializer Agent

**Role**: Sets up the initial environment for the project.

**Responsibilities**:
- Analyze project requirements
- Generate comprehensive feature list
- Create development scripts
- Set up initial git repository
- Document project structure

**Output Artifacts**:
- `features/feature_list.json` - Complete feature requirements
- `progress/claude-progress.md` - Initial progress documentation
- `scripts/init.sh` - Environment initialization
- `scripts/start_dev.sh` - Development server startup
- `scripts/test_e2e.sh` - E2E testing

### 2. Coding Agent

**Role**: Makes incremental progress on features.

**Responsibilities**:
- Read and understand current state
- Choose appropriate feature to work on
- Implement features incrementally
- Test thoroughly
- Commit progress
- Update documentation

**Session Workflow**:
1. Get bearings (pwd, git log, progress)
2. Verify environment (start server, smoke tests)
3. Choose feature (highest priority, dependencies met)
4. Implement incrementally
5. Test thoroughly
6. Commit and document

### 3. CLI Tool (dev-agent.py)

**Role**: Automates workflow management and provides consistent interface.

**Commands**:
- `status` - Show progress summary
- `next` - Get next feature to implement
- `find-parallel` - Find parallelizable features
- `complete <id>` - Mark feature as passing
- `skip <id> "reason"` - Mark feature as skipped
- `regression` - Pick features to re-verify
- `log` - Append structured progress
- `run` - Start autonomous loop

### 4. State Management

**Progress File** (`progress/claude-progress.md`):
- Session-by-session log
- Features worked on
- Commits made
- Issues encountered
- Next steps

**Feature List** (`features/feature_list.json`):
- Comprehensive feature requirements
- Test steps for each feature
- Pass/fail/skipped status
- Dependencies between features

**Checkpoints** (`.agent/state/checkpoints/`):
- Session snapshots
- Git state at checkpoint
- Feature progress

### 5. Testing Infrastructure

**Unit Tests** (`tests/unit/`):
- Fast, isolated tests
- Test individual functions/modules

**E2E Tests** (`tests/e2e/`):
- Browser automation tests
- Full user flow testing
- Playwright-based

## Execution Modes

### Mode A: Interactive (Default)

```
┌─────────────────────────────────────────────────────────────────┐
│                    INTERACTIVE MODE                              │
├─────────────────────────────────────────────────────────────────┤
│  1. dev-agent.py status ──────► Check current progress         │
│  2. dev-agent.py next ────────► Get next feature               │
│  3. Implement feature ────────► Write code, run tests          │
│  4. dev-agent.py complete ────► Mark feature passing           │
│  5. Commit & log ─────────────► Save progress                  │
│  6. /clear or continue ───────► Repeat or end session          │
└─────────────────────────────────────────────────────────────────┘
```

**Benefits**:
- Full visibility of each action
- MCP tools work (Playwright, etc.)
- No extra permissions needed
- User can intervene at any step

### Mode B: Autopilot

```
┌─────────────────────────────────────────────────────────────────┐
│                    AUTOPILOT MODE                                │
├─────────────────────────────────────────────────────────────────┤
│  1. dev-agent.py run ─────────► Start autonomous loop          │
│  2. For each feature:                                            │
│     ├── Spawn claude -p process                                  │
│     ├── Implement feature                                        │
│     ├── Run tests                                                │
│     ├── Mark complete                                            │
│     └── Commit                                                   │
│  3. Continue until done or error                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Benefits**:
- Fully autonomous
- Works on multiple features
- No context management needed
- Parallel execution support

### Team Mode (Parallel)

```
┌─────────────────────────────────────────────────────────────────┐
│                    TEAM MODE                                     │
├─────────────────────────────────────────────────────────────────┤
│  1. find-parallel ────────────► Find N parallelizable features │
│  2. Create worktrees ─────────► Isolated git worktrees         │
│  3. Run parallel sessions ────► Spawn N claude processes       │
│  4. Merge completed ──────────► Merge worktree branches        │
│  5. Clean up ─────────────────► Remove worktrees               │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        Session Start                             │
├─────────────────────────────────────────────────────────────────┤
│  1. Read State                                                   │
│     ├── git log ──────────────────────► Recent commits          │
│     ├── progress/claude-progress.md ──► Session history         │
│     └── features/feature_list.json ───► Feature status          │
│                                                                  │
│  2. Verify Environment                                           │
│     ├── ./scripts/start_dev.sh ───────► Dev server running      │
│     └── ./scripts/test_e2e.sh --smoke ─► Basic functionality    │
│                                                                  │
│  3. Choose Feature                                               │
│     └── Highest priority, dependencies met                       │
│                                                                  │
│  4. Implement                                                    │
│     ├── Write code                                               │
│     ├── Write tests                                              │
│     └── Test locally                                             │
│                                                                  │
│  5. Verify                                                       │
│     ├── npm test ─────────────────────► Unit tests pass         │
│     ├── npm run test:e2e ─────────────► E2E tests pass          │
│     └── Browser automation ───────────► Manual verification     │
│                                                                  │
│  6. Commit & Document                                            │
│     ├── git commit ───────────────────► Save progress           │
│     ├── dev-agent.py complete ────────► Mark passing            │
│     └── dev-agent.py log ─────────────► Document session        │
└─────────────────────────────────────────────────────────────────┘
```

## Failure Modes & Solutions

### Mode 1: Premature Completion

**Problem**: Agent declares project complete too early.

**Solution**: Comprehensive feature list with explicit test steps. Agent must verify each feature individually.

### Mode 2: Undocumented State

**Problem**: Agent leaves bugs or undocumented changes.

**Solution**: Git commits with descriptive messages + progress file updates. Smoke tests at session start catch bugs.

### Mode 3: Skipped Testing

**Problem**: Agent marks features as passing without proper verification.

**Solution**: Strict verification protocol. Features can only be marked as passing after:
- Unit tests pass
- E2E tests pass
- Browser automation verification
- No regressions

### Mode 4: Environment Confusion

**Problem**: Agent wastes time figuring out how to run the app.

**Solution**: `init.sh` script sets up everything. `start_dev.sh` starts the server.

## Directory Structure

```
.
├── .agent/                    # Agent configuration
│   ├── config.yaml           # Settings
│   ├── prompts/              # Agent prompts
│   │   ├── initializer.md    # First session prompt
│   │   └── coding.md         # Subsequent sessions
│   └── state/                # Runtime state
│       ├── session.json      # Current session
│       └── checkpoints/      # Session snapshots
│
├── features/                  # Feature management
│   ├── feature_list.json     # Main feature list
│   └── feature_schema.json   # JSON schema
│
├── progress/                  # Progress tracking
│   ├── claude-progress.md    # Main progress log
│   └── session_logs/         # Detailed logs
│
├── scripts/                   # Automation
│   ├── dev-agent.py          # CLI workflow tool
│   ├── init.sh               # Initialize environment
│   ├── start_dev.sh          # Start dev server
│   ├── test_e2e.sh           # Run E2E tests
│   └── checkpoint.sh         # Create checkpoint
│
├── templates/                 # Workflow templates
│   └── AGENTS.md             # Agent workflow template
│
├── tests/                     # Test suites
│   ├── e2e/                  # End-to-end tests
│   ├── unit/                 # Unit tests
│   └── integration/          # Integration tests
│
├── src/                       # Source code
│
├── docs/                      # Documentation
│
├── CLAUDE.md                  # Claude Code instructions
└── README.md                  # Project readme
```

## Configuration

The `.agent/config.yaml` file controls:

- Model selection
- Session duration limits
- Feature workflow settings
- Testing requirements
- Git workflow preferences
- Execution mode settings
- Team mode settings
- Notification settings

## Integration Points

### Claude Code

The `CLAUDE.md` file provides instructions that Claude Code follows automatically when working on the project.

### Browser Automation

Playwright is used for E2E testing. Tests are stored in `tests/e2e/` with the naming convention `{feature-id}.spec.js`.

### Git

All progress is tracked through git commits. The system expects:
- Descriptive commit messages
- Clean working state at session end
- Use of conventional commits format

## Extending the System

### Adding New Feature Categories

Edit `features/feature_schema.json` to add new categories in the enum.

### Custom Testing

Add custom test scripts in `scripts/` and reference them in `.agent/config.yaml`.

### Multi-Agent Architecture

The system can be extended to use specialized agents:
- Testing agent: Focuses solely on testing
- QA agent: Reviews code quality
- Documentation agent: Maintains docs

## References

- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Claude Agent SDK](https://github.com/anthropics/claude-agent-sdk)