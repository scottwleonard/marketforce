# MarketForce

A competitive business strategy simulation where you manage a company across R&D, Marketing, Production, and Finance — competing against 5 AI-managed firms over 8 rounds.

**[Play Now](https://scottwleonard.github.io/marketforce/)**

## Gameplay

You run one of six companies, each with 4 products competing across 5 market segments (Traditional, Low End, High End, Performance, Size). Each round you make decisions across four departments, then the simulation calculates market demand, allocates sales, and produces financial results.

### Departments

- **R&D** — Reposition products by adjusting performance, size, and MTBF (reliability). Changes reset product age, affecting customer appeal.
- **Marketing** — Set prices within segment ranges. Allocate promotion budgets (drives awareness) and sales budgets (drives accessibility).
- **Production** — Set production schedules, manage capacity, and invest in automation to reduce labor costs.
- **Finance** — Issue or retire stock and bonds, set dividends, manage your capital structure. Emergency loans kick in automatically if cash goes negative.

### Reports

- Income Statement, Balance Sheet, Cash Flow Statement
- Market Share and Revenue charts
- Segment Analysis with ideal positions, price ranges, and growth rates
- Competitive Scoreboard ranking all 6 companies

### Winning

After 8 rounds, companies are ranked by cumulative profit. Stock price, ROA, and market share also matter. The AI competitors make reasonable decisions — they track segment drift, adjust pricing, and manage budgets — so you'll need a real strategy to come out on top.

## Development Setup

### Prerequisites

- [Godot 4.6+](https://godotengine.org/download/) (standard build, not .NET)
- Git

### Getting Started

```bash
git clone https://github.com/scottwleonard/marketforce.git
cd marketforce
```

Open the project in Godot:

```bash
# macOS
open /Applications/Godot.app --args --path "$(pwd)"

# Or just open Godot and import the project.godot file
```

Press F5 (or the Play button) to run.

### Project Structure

```
project.godot              # Godot config, autoloads, input maps
export_presets.cfg         # Web export configuration
STRUCTURE.md               # Architecture reference (scenes, scripts, signals)
scripts/
  game_manager.gd          # Autoload singleton — game state, rounds, AI
  simulation_engine.gd     # Pure math — demand, financials, scoring
  main_controller.gd       # Title screen and game flow
  game_screen_controller.gd # Dashboard with tabs, header, status bar
  rd_tab.gd                # R&D department UI
  marketing_tab.gd         # Marketing department UI
  production_tab.gd        # Production department UI
  finance_tab.gd           # Finance department UI
  reports_tab.gd           # Financial reports and charts
  perceptual_map.gd        # Custom-drawn product positioning chart
  bar_chart.gd             # Custom-drawn bar chart
  data_table.gd            # Reusable styled data table
scenes/
  main.tscn                # Entry point scene
  game_screen.tscn         # Game dashboard scene
  build_*.gd               # Headless scene builders
```

### Validating Changes

```bash
# Check a single script for errors
godot --headless --check-only -s scripts/your_script.gd

# Validate the full project
godot --headless --quit
```

### Web Export

Web builds deploy automatically to GitHub Pages on every push to `main` via GitHub Actions. To export locally:

```bash
mkdir -p build/web
godot --headless --export-release "Web" build/web/index.html
```

## Contributing

Create an issue describing your suggestion or bug. Issues labeled `approved` are automatically picked up by Claude and implemented via PR.

## License

MIT
