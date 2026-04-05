# MarketForce Business Simulation

## Dimension: 2D

## Input Actions

| Action | Keys |
|--------|------|
| ui_accept | Enter, Space |
| ui_cancel | Escape |

## Scenes

### Main
- **File:** res://scenes/main.tscn
- **Root type:** Control
- **Children:** TitleScreen, GameScreen (initially hidden)

### GameScreen
- **File:** res://scenes/game_screen.tscn
- **Root type:** Control
- **Children:** HeaderBar, TabContainer (R&D, Marketing, Production, Finance, Reports), StatusBar, RoundResultsPopup

## Scripts

### GameManager
- **File:** res://scripts/game_manager.gd
- **Extends:** Node
- **Autoload singleton**
- **Signals emitted:** round_completed, game_started, game_ended, decisions_submitted
- **Purpose:** Core simulation engine — company data, market segments, demand calculation, financial model, AI decisions, round processing

### SimulationEngine
- **File:** res://scripts/simulation_engine.gd
- **Extends:** RefCounted
- **Purpose:** Pure calculation — demand allocation, revenue, costs, financial statements. Called by GameManager.

### MainController
- **File:** res://scripts/main_controller.gd
- **Extends:** Control
- **Attaches to:** Main:Main
- **Signals received:** GameManager.game_started, GameManager.round_completed, GameManager.game_ended

### GameScreenController
- **File:** res://scripts/game_screen_controller.gd
- **Extends:** Control
- **Attaches to:** GameScreen:GameScreen
- **Signals received:** GameManager.round_completed, GameManager.decisions_submitted
- **Purpose:** Manages tab navigation, header updates, round flow

### RDTab
- **File:** res://scripts/rd_tab.gd
- **Extends:** Control
- **Purpose:** R&D department — product repositioning (performance, size), MTBF, displays age and revision date, perceptual map

### MarketingTab
- **File:** res://scripts/marketing_tab.gd
- **Extends:** Control
- **Purpose:** Marketing department — price, promotion budget, sales budget per product

### ProductionTab
- **File:** res://scripts/production_tab.gd
- **Extends:** Control
- **Purpose:** Production department — schedule, buy/sell capacity, automation level per product

### FinanceTab
- **File:** res://scripts/finance_tab.gd
- **Extends:** Control
- **Purpose:** Finance department — stock issue/retire, bonds, dividends, current debt, cash position

### ReportsTab
- **File:** res://scripts/reports_tab.gd
- **Extends:** Control
- **Purpose:** Reports — income statement, balance sheet, cash flow, market share bar chart, segment analysis

### PerceptualMap
- **File:** res://scripts/perceptual_map.gd
- **Extends:** Control
- **Purpose:** Custom drawn chart showing product positions on Performance vs Size axes with segment circles

### BarChart
- **File:** res://scripts/bar_chart.gd
- **Extends:** Control
- **Purpose:** Custom drawn bar chart for market share and financial comparisons

### DataTable
- **File:** res://scripts/data_table.gd
- **Extends:** Control
- **Purpose:** Reusable data table with headers and row data, styled with alternating colors

## Signal Map

- GameManager.game_started -> MainController._on_game_started
- GameManager.round_completed -> GameScreenController._on_round_completed
- GameManager.game_ended -> MainController._on_game_ended

## Build Order

1. scenes/build_game_screen.gd -> scenes/game_screen.tscn
2. scenes/build_main.gd -> scenes/main.tscn (depends: game_screen.tscn)
