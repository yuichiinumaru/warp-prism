# Screenshot 40 — Dashboard: Storage (General Settings)

## Page Title & Breadcrumb

- **Header icon**: Purple cylinder/database icon
- **Page title**: "Storage" (bold, large)
- **Subtitle**: "Storage, database, backups, and retention settings"
- **Breadcrumb**: Dashboard > Settings > General

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar with white text. "Storage" under CONFIGURATION is highlighted in red/coral background.
- **Top bar**: White. "Cybernetics-Core v2.5.29" branding on left. Right: search, "Quick nav" (Cmd+K), EN language, avatar, bell (red dot), gear.
- **Bottom left footer**: Red "Restart" and "Shut down" buttons.
- **Main content**: White background, scrollable, organized into card sections.

## Sections (Top to Bottom)

### 1. Storage Header
- **Icon**: Green cylinder/database icon
- **Title**: "Storage"
- **Description**: "All data stored locally on your machine"
- **Status badge**: Green "OK" badge on the right

### 2. Database Path
- **Label**: "DATABASE PATH"
- **Value**: `/app/data/storage.sqlite` (monospace, bold)

### 3. Database Statistics
- **Icon**: Purple chart/statistics icon
- **Title**: "Database Statistics"
- **Refresh button**: Top-right with circular refresh icon and "Refresh" text
- **Grid layout**: 3 columns × 2 rows
  - **Database Size**: "7.6 MB"
  - **Page Count**: "1,957"
  - **Freelist Count**: "0"
  - **Last Vacuum**: "Never"
  - **Last Optimization**: "Never"
  - **Integrity Check**: "✓ OK" (green checkmark)

### 4. Export
- **Icon**: Purple upload/export icon
- **Title**: "Export"
- **Button row** (6 buttons, horizontal, each with an icon):
  - "Export Database" (download icon)
  - "Export All (No gzip)" (download icon)
  - "Import Database" (upload icon)
  - "Export JSON" (braces icon)
  - "Import JSON" (braces icon)

### 5. Maintenance
- **Icon**: Purple wrench/tools icon
- **Title**: "Maintenance"
- **Button row** (5 buttons, horizontal, each with an icon):
  - "Clear Cache" (broom icon)
  - "Purge Expired Logs" (trash icon)
  - "Manual VACUUM" (database icon)
  - "Purge Quota Snapshots" (trash icon)
  - "Purge Call Logs" (trash icon)
  - "Purge Detailed Logs" (trash icon)

### 6. Last Backup
- **Icon**: Orange/clock backup icon
- **Title**: "Last Backup"
- **Timestamp**: "7/2/2026, 8:57:48 PM (17m ago)" in gray
- **Buttons** on the right: "Backup Now" (cloud upload icon) and "View Backups" (outlined)

### 7. Retention Settings
- **Icon**: Purple clock/retention icon
- **Title**: "Retention Settings"
- **Description**: "Configure operational record retention and database backup cleanup."
- **Retention type tabs** (top-right): "Off 7d" · "App 7d" · "180 days" (last one selected/highlighted)
- **Form fields** (2-column grid):
  - **Quota Snapshots (days)**: "90"
  - **Compression Analytics (days)**: "30"
  - **MCP Audit (days)**: "30"
  - **A2A Events (days)**: "30"
  - **Call Logs (days)**: "90"
  - **Usage History (days)**: "365"
  - **Memory Entries (days)**: "180"
- **Save button**: Red "Save retention settings" button

### 8. Database Backups
- **Description**: "Automatic SQLite backups are stored in db_backups. Configure how many snapshots to keep and optionally delete backups older than N days."
- **Status indicators** (right side): "3 backups" · "Max 20" · "Age retention: off"
- **Form fields**:
  - **Keep latest backups**: "20"
  - **Delete older than days**: "0"
- **Buttons**: "Save retention" (outlined with save icon) and "Clean old backups" (outlined with broom icon)

### 9. Optimization Settings
- **Icon**: Purple settings/gear icon
- **Title**: "Optimization Settings"
- **Form fields** (2-column layout):
  - **Auto Vacuum Mode**: Dropdown set to "Incremental"
  - **Scheduled Vacuum**: Dropdown set to "Weekly"
  - **Vacuum Hour (0-23)**: "2"
  - **Page Size (bytes)**: "4096"
  - **Cache Size (KB, negative = % of RAM)**: "16384"
- **Checkbox**: "Optimize on Startup" (checked, green/blue checkmark)
- **Save button**: Red "Save Optimization Settings" button

### 10. Compression & Aggregation Settings
- **Icon**: Purple compress/arrows icon
- **Title**: "Compression & Aggregation Settings"
- **Checkbox**: "Enable Data Aggregation" (unchecked)
- **Form fields**:
  - **Raw Data Retention (days)**: "7"
  - **Granularity**: Dropdown set to "Daily"
- **Save button**: Red "Save Aggregation Settings" button

## Color Palette

- Background: White
- Sidebar: Dark navy/charcoal
- Primary accent: Red/coral for save buttons and active sidebar item
- Green: OK badge, checkmarks, checked checkboxes
- Orange: Last Backup icon
- Database path: Bold monospace black text
- Stats labels: Light gray background cards with dark text
- Buttons: Outlined (gray border) for maintenance/export, Red filled for save actions
