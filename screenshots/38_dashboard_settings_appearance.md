# Screenshot 38 — Dashboard: Appearance Settings

## Page Title & Breadcrumb

- **Header icon**: Purple/pink paint palette icon
- **Page title**: "Appearance" (bold, large)
- **Subtitle**: "Display, theming, and visual customization"
- **Breadcrumb**: Dashboard > Settings > Appearance

## Global Layout

- **Left sidebar**: Dark charcoal/navy vertical navigation bar with white text. Sections: OMNIPROXY, ANALYTICS, MONITORING, AGENTIC FEATURES, OTHER FEATURES, CONFIGURATION, HELP. The "Appearance" item under CONFIGURATION is highlighted with a red/coral background, indicating the current page.
- **Top bar**: White. Left: "Cybernetics-Core v2.5.29" branding in red. Right: search icon, "Quick nav" button (Cmd+K), EN language selector with US flag, user avatar, bell notification icon (red dot), settings gear.
- **Bottom left footer**: Red "Restart" button and "Shut down" button with power icon.
- **Main content**: White background, scrollable, ~800px content width, centered. Settings arranged in card-like sections.

## Sections (Top to Bottom)

### 1. Appearance Header
- **Icon**: Purple/pink paint palette icon
- **Title**: "Appearance"
- **Description**: "Display, theming, and visual customization"
- **Dark Mode** toggle (OFF — gray) on the right side

### 2. Dark Mode
- **Label**: "Dark Mode"
- **Description**: "Switch between light and dark themes"
- **Three toggle buttons** in a row:
  - **Light** (selected — has sun icon, white/light background with border)
  - **Dark** (has moon icon)
  - **System** (has monitor icon — selected with green fill/background)

### 3. Pin Information to Home Page
- **Description**: "Choose which sections to pin to the top of the Home page."
- **Three toggle rows**, each with a toggle switch on the right:
  - **Provider Quota Limits** (ON — green toggle): "Pin the Provider Quota status container (with Refresh All button) to the top of the Home page."
  - **Quick Start** (ON — green toggle): "Show the Quick Start panel on the Home page."
  - **Provider Topology** (ON — green toggle): "Show the Provider Topology on the Home page."

### 4. Endpoint Tunnel Visibility
- **Description**: "Hide tunnel controls from the Endpoint page without changing tunnel state."
- **Three toggle rows**:
  - **Cloudflare Quick Tunnel** (OFF — gray): "Show Cloudflare Quick Tunnel controls on the Endpoint page."
  - **Tailscale Funnel** (OFF — gray): "Show Tailscale Funnel controls on the Endpoint page."
  - **ngrok Tunnel** (OFF — gray): "Show ngrok controls on the Endpoint page."

### 5. Combo Configuration Mode
- **Description**: "Choose how the combo create and edit dialog is organized."
- **Two selectable cards** side by side:
  - **Left card** (selected, red/coral border): "Guided" — "Use the current step-by-step combo builder."
  - **Right card** (highlighted with pink/red border): "Expert" — "Show every combo option on one page and enable direct model entry."

### 6. Provider Quota Auto Refresh
- **Description**: "Refresh the Provider Limits view automatically while it stays open."
- **Automatic refresh** toggle (ON — green): "Refresh the quota view every few minutes while the page is visible."
- **Refresh interval** input: "3600" with label "seconds" on the right. Description: "How often the quota view should refresh, in seconds."

### 7. Account Email Visibility
- **Description**: "Show full account emails across providers, combos, logs, quota, and playground screens. Turn this off to mask them by default."
- **Toggle**: OFF (gray)

### 8. Hide Health Check Logs
- **Description**: "When ON, suppress [HealthCheck] messages in server console"
- **Toggle**: OFF (gray)

### 9. Theme Color
- **Description**: "Choose a preset color or create your own theme with one color"
- **Preset color grid** (2 columns, 4 rows):
  - **Coral** (selected — has a coral/red dot, light pink background highlight)
  - **Blue** (blue dot)
  - **Red** (red dot)
  - **Green** (green dot)
  - **Violet** (purple dot)
  - **Orange** (orange dot)
  - **Cyan** (cyan/teal dot)
- **Custom color row**:
  - Blue color swatch square
  - Hex input: "#3ba276" (green-ish value)
  - Red "Create theme" button on the right

### 10. Branding
- **Icon**: Purple building/brand icon
- **Title**: "Branding"
- **Description**: "Customize the application name and logo"
- **Application Name** input: "Cybernetics-Core" with label "Display name shown in sidebar and browser tab"
- **Custom Logo URL** input: placeholder "https://example.com/logo.png" with label "URL to your custom logo image"
- **Upload Logo** row: "Upload Logo" button (with upload icon) and "Reset to Default" button (outlined)
- **Browser Favicon** input: placeholder "https://example.com/favicon.ico" with label "URL to your custom favicon (shown in browser tab)"
- **Upload Favicon** row: "Upload Favicon" button (with upload icon) and "Reset Favicon" button (outlined)

## Color Palette

- Background: White (#FFFFFF)
- Sidebar: Dark navy/charcoal
- Primary accent: Red/coral (#EF4444) for active sidebar, save buttons, selected cards
- Toggle ON: Green (#22C55E)
- Toggle OFF: Gray (#D1D5DB)
- Selected card border: Pink/red (#F87171)
- Preset color dots: Coral, Blue, Red, Green, Violet, Orange, Cyan
- Text primary: Dark gray/black
- Text secondary: Medium gray
