# Game Plan: MarketForce Business Simulation

## Game Description

Multiplayer competitive business strategy simulation like MarketForce. 8 rounds. Each player manages a company with 4 products across 5 market segments (Traditional, Low End, High End, Performance, Size). Core departments: R&D (product repositioning, age, MTBF), Marketing (price, promotion budget, sales budget), Production (capacity, automation, scheduling), Finance (stock issues, retire stock, bonds, dividends, short/long term debt). Dashboard with financial reports (income statement, balance sheet, cash flow), market share charts, production analysis, and segment analysis. Professional corporate UI with navy/dark blue headers, data tables, tabs for each department. Round-based: all players submit decisions then results calculated simultaneously. Competitive results shown between teams each round.

## Risk Tasks

None — this is a pure UI/data simulation with no physics, animation, or procedural generation. All systems are standard Godot Control nodes and arithmetic.

## Main Build

Build a complete business simulation with:

**Core simulation engine** (GameManager autoload):
- Company data model: 4 products per company, financial state, round tracking
- 5 market segments with buying criteria (ideal position drift, price range, age, MTBF)
- Customer survey scoring: accessibility + awareness + positioning + price + age + MTBF
- Demand allocation based on scores across all companies
- Full financial model: revenue, COGS, SGA, depreciation, interest, taxes, profit
- Balance sheet tracking: assets, liabilities, equity
- Cash flow statement
- AI competitor decision-making for 5 opponent companies
- 8-round game loop

**UI system** (themed Control nodes):
- Corporate theme: navy headers, white backgrounds, gray borders, professional typography
- Main dashboard with company overview and key metrics
- Tab-based navigation: R&D, Marketing, Production, Finance, Reports
- R&D tab: product table with performance, size, MTBF editing, perceptual map
- Marketing tab: price, promotion budget, sales budget per product
- Production tab: production schedule, capacity purchase/sell, automation investment
- Finance tab: stock issue/retire, bond issue/retire, dividends, current debt display
- Reports tab: income statement, balance sheet, cash flow statement, market share chart
- Round control: submit decisions button, advance round, results display
- Segment analysis: demand, growth, buying criteria per segment
- Competitive scoreboard: all teams ranked by metrics

**Game flow:**
- Title screen → New game setup (company name)
- Lobby showing all 6 teams (1 player + 5 AI)
- Decision phase → Submit → Simulation → Results → Next round
- After round 8: final results and rankings

- **Verify:**
  - All tabs navigate correctly, no overlap or overflow
  - R&D changes update product specs correctly
  - Marketing/Production/Finance inputs save and persist across tab switches
  - Simulation produces reasonable financial results (no negative prices, revenues scale with market share)
  - AI competitors make plausible decisions
  - 8 rounds complete without errors
  - Financial statements balance (assets = liabilities + equity)
  - Charts render with correct data
  - UI readable at 1280x720, no text clipping
  - Competitive results update each round
  - Gameplay flow matches game description
  - No visual glitches, clipping, or placeholder assets
  - **Presentation video:** ~30s cinematic MP4 showcasing gameplay
    - Write test/presentation.gd (SceneTree script), ~900 frames at 30 FPS
    - **2D:** camera pans, zoom transitions, tight viewport framing
    - Output: screenshots/presentation/gameplay.mp4

## Status

- [x] Scaffold
- [x] Core simulation engine
- [x] UI theme and layout
- [x] R&D department
- [x] Marketing department
- [x] Production department
- [x] Finance department
- [x] Reports and charts
- [x] Game flow and AI
- [x] Presentation video
