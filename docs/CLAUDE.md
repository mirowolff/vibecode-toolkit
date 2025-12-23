# Vibecode Toolkit Website Documentation

## Project Overview

Static GitHub Pages site for Vibecode Toolkit - a macOS development environment installer for designers learning to code ("vibecoding"). The site documents the installation process, tools included, and provides post-install guidance.

**Live Site:** https://mirowolff.github.io/vibecode-toolkit/
**Repository:** https://github.com/mirowolff/vibecode-toolkit

## Target Audience

Designers transitioning from browser-based AI coding tools (like Claude.ai) to local development environments. They're comfortable with prompting but new to terminal workflows, git, and development tooling.

## Site Structure

```
docs/
├── index.html           # Homepage with hero, features, tools overview
├── about.html           # Why the project exists (narrative, not collapsible)
├── tools.html           # Detailed tool documentation
├── faq.html             # FAQ with collapsible accordion sections
├── next-steps.html      # Post-install guidance
├── install.sh           # The actual installation script (v1.0)
├── styles.css           # Global styles
├── scripts.js           # Interactive behaviors
├── img/                 # Logos and assets
│   └── logo.png         # 256x256px favicon as PNG (transparent bg)
└── config/              # Config templates for users
    ├── ghostty.conf
    └── starship.toml
```

## Design System

### Color Palette
```css
--bg: #000000               /* Pure black background */
--bg-elevated: #1d1d1f      /* Elevated surfaces */
--text: #f5f5f7             /* Primary text (white) */
--text-muted: #86868b       /* Secondary text (gray) */
--accent: #a855f7           /* Purple (primary brand) */
--accent-bright: #c084fc    /* Bright purple (hover states) */
--green: #06c167            /* Success states */
--green-bright: #a3ff85     /* Terminal prompt */
--blue: #0ea5e9             /* Links, info */
--orange: #fb923c           /* Flags, warnings */
--yellow: #fbcc17           /* Logo color, highlights */
```

### Typography
- **Font:** System fonts (Inter from Google Fonts)
- **Headings:** No emojis (professional style)
- **Monospace:** SF Mono, Monaco, Courier New for code
- **Size scale:** Responsive with clamp() for fluid typography

### Visual Style
- **Dark theme only** - No light mode
- **Glass morphism** - backdrop-blur, semi-transparent backgrounds
- **Purple gradient ambient** - Radial gradient overlay with animated dots
- **Smooth animations** - 0.3s transitions, shimmer effects on hover
- **Rounded corners** - 16px for cards, 980px for pills/buttons

## Key Components

### Navigation Bar
- Fixed position, glassmorphic with blur
- Desktop: Horizontal with all links visible
- Mobile: Hamburger menu with high-opacity background (#000000dd)
- Version badge (v1.0) and GitHub icon in nav

### Hero Section
- Large gradient text headings (96px max)
- Terminal command box with copy functionality
- Click anywhere on terminal box to copy
- Animated shimmer effect on hover

### Collapsible Sections (FAQ only)
- Accordion pattern: only one section open at a time
- Chevron rotates 180° when expanded
- Purple accent on hover and active states
- Used ONLY for FAQ page (not for narrative content like About)

### Back to Top Button
- Purple gradient background with shimmer effect
- Bouncing arrow animation on hover
- Positioned in footer, centered

## Interactive Behaviors

### Copy Command Functionality
```javascript
// Terminal box click copies install command
// Shows green border and checkmark feedback
// Auto-reverts after 2 seconds
```

### Collapsible Accordion (FAQ)
```javascript
// Click any FAQ header:
// 1. Closes all other sections
// 2. Toggles clicked section
// 3. Updates aria-expanded attributes
// Keyboard accessible (Enter/Space)
```

### Mobile Menu
```javascript
// Hamburger toggles .active class
// Closes when clicking outside or on link
// GitHub icon + version badge on same row at bottom
```

## Spacing System

### Responsive Spacing
- **Hero padding:** 140px top (desktop), 80px (mobile)
- **Section padding:** 100px vertical (desktop), 30px (mobile)
- **About page special:** Reduced top padding (50px) for tighter feel
- **Gap between elements:** 12px standard, 4px for mobile menu

### About Page vs FAQ Page
- **About:** Linear narrative, NO collapsibles, flows top to bottom
- **FAQ:** Collapsible accordion, user cherry-picks questions

## Code Patterns

### Inline Code Styling
```css
/* Purple background, monospace font */
background: rgba(139, 92, 246, 0.15);
padding: 2px 8px;
border-radius: 4px;
color: var(--accent-bright);
```

### Terminal Command Styling
```css
/* Single line with ellipsis truncation */
white-space: nowrap;
overflow: hidden;
text-overflow: ellipsis;
/* Child spans also need white-space: nowrap */
```

### Card Hover Effects
```css
/* Shimmer sweep animation */
.card::before {
  content: '';
  position: absolute;
  left: -100%;
  background: linear-gradient(90deg, transparent, rgba(168, 85, 247, 0.1), transparent);
  transition: left 0.6s ease;
}
.card:hover::before {
  left: 100%;
}
```

## Development Workflow

### Local Development
```bash
bun dev  # Starts dev server on port 3000
```

Server serves static files from docs/ directory with proper routing.

### File Paths
- All navigation uses relative paths (`index.html`, not `/`)
- Works both with dev server and `file://` protocol
- Images referenced as `img/filename.svg` (relative to page)

### Git Workflow
- Branch: `main`
- Auto-deploys to GitHub Pages on push
- GitHub Actions workflow handles deployment

## Content Guidelines

### Voice & Tone
- **Professional but approachable** - not academic, not overly casual
- **Direct and concise** - respect the user's time
- **Transparent** - honest about what works and what doesn't
- **Encouraging** - "you'll learn as you go" mindset

### Terminology
- **"Vibecoding"** (one word) - established term, matches URL
- **"Local vibecoding"** - emphasis on local development
- **"Tools" not "packages"** - more approachable for designers
- **"Install" not "deploy"** - simpler language

### Writing Style
- Short paragraphs (2-3 sentences)
- Bullet points for scannable lists
- No marketing fluff or excessive adjectives
- Action-oriented (imperative mood for instructions)

## Common Tasks

### Adding a New Page
1. Copy existing HTML structure (nav, footer, scripts)
2. Update active class in nav links
3. Ensure styles.css and scripts.js are linked
4. Add page link to all other pages' navigation
5. Test on mobile (hamburger menu)

### Updating Styles
- Edit `styles.css` (single file, no build process)
- Use existing CSS variables for consistency
- Mobile breakpoints: 768px (tablet), 734px (mobile), 480px (small mobile)
- Test hover states and animations

### Modifying Installation Script
- Edit `docs/install.sh` directly
- Update version number in script header (VERSION="1.0")
- Update version badges in HTML files (`<span class="nav-version">`)
- Script creates backups before modifying user files

### Editing FAQ
- Use collapsible-section structure
- Keep questions concise (one sentence)
- Answers should be 1-3 paragraphs max
- Link to full documentation pages when needed
- Remember: only one section open at a time (accordion pattern)

## Technical Constraints

### Browser Support
- Modern browsers only (ES6+)
- Relies on CSS backdrop-filter (may not work in all browsers)
- Fallback: solid backgrounds with higher opacity

### Performance
- No build process - static HTML/CSS/JS
- All assets inline or served from docs/
- External fonts loaded from Google Fonts CDN
- Minimal JavaScript (< 200 lines total)

### Accessibility
- Semantic HTML structure
- ARIA labels on interactive elements
- Keyboard navigation support (Tab, Enter, Space)
- Focus-visible styles for keyboard users
- Color contrast meets WCAG AA standards

## Assets

### Favicon
- Inline SVG data URI in HTML `<link>` tag
- Lucide Terminal icon in yellow (#fbcc17)
- Also exported as 256×256px PNG at `docs/img/logo.png`

### Tool Logos
Location: `docs/img/`
- Claude, Ghostty, Starship, Cursor, VS Code, etc.
- All SVG format for crisp rendering
- Various sizes (preserve original dimensions)

## Version Management

### Current Version: 1.0
- Displayed in nav badge
- Defined in install.sh header
- Update both places when bumping version

### Breaking Changes Checklist
- [ ] Update install.sh VERSION variable
- [ ] Update all HTML nav badges
- [ ] Update README.md if needed
- [ ] Test fresh install on clean macOS

## Things to Remember

### DO
✅ Keep About page narrative (no collapsibles)
✅ Use accordion pattern for FAQ (one open at a time)
✅ Test mobile hamburger menu layout
✅ Maintain consistent purple accent color
✅ Use relative paths for all links
✅ Include back to top button in footer
✅ Add `white-space: nowrap` to terminal command child spans

### DON'T
❌ Add emojis to section headings (use in content only)
❌ Make About page collapsible (it's a story)
❌ Use absolute paths in navigation
❌ Add Claude Code attribution to git commits (user preference)
❌ Change "vibecoding" to two words (brand consistency)
❌ Remove MCP server configs from install script

## Common Gotchas

1. **Terminal command wrapping on mobile:** Child spans need `white-space: nowrap` too
2. **Mobile menu blur not working:** Use solid background (`#000000dd`) as fallback
3. **Back to top animation:** SVG needs `transform` to bounce, not the parent
4. **Collapsible max-height:** Set high enough (1000px) for longest FAQ answer
5. **Nav spacing on mobile:** GitHub icon and version badge use `justify-content: space-between`

## Future Considerations

### Potential Enhancements
- Add search functionality to FAQ
- Include video walkthrough on homepage
- Create troubleshooting page with common errors
- Add "installed components" status checker
- Analytics to track popular tools/pages

### Not Planned
- Light theme (dark theme is brand identity)
- Multiple language support (English only)
- Windows/Linux versions (macOS only)
- Package customization UI (fork the script instead)

## Session Learnings (2024-12-23)

### Key Improvements Made
1. Created FAQ page with accordion collapsibles (appropriate use case)
2. Reverted About page collapsibles (narrative flow is better)
3. Enhanced mobile menu with better opacity and positioning
4. Fixed terminal command truncation on mobile
5. Improved back to top button with animations and purple theme
6. Created Got-style README with centered logo
7. Refined tagline to "local vibecoding"

### Design Decisions
- **Collapsibles are for FAQs, not narratives** - User pointed out About page shouldn't hide content
- **Mobile menu needs solid background** - Backdrop blur doesn't work reliably
- **Spacing matters** - Tightened hero → content gap on About page
- **Professional trumps cute** - No emoji in headings, clean typography
- **"Vibecoding" stays one word** - Brand consistency with URL/repo name

### Technical Fixes
- Terminal `.cmd` child spans need individual `white-space: nowrap`
- Mobile menu uses `flex-wrap` with `justify-content: space-between`
- Back to top button uses `::before` pseudo-element for shimmer effect
- Collapsible sections use `max-height` transition (not height)

## Quick Reference Commands

```bash
# Start dev server
bun dev

# Kill port 3000
lsof -ti:3000 | xargs kill -9

# Search for text across all HTML
grep -r "search term" docs/*.html

# Convert SVG to PNG (logo)
convert -background none -resize 256x256 logo.svg logo.png

# Commit and push
git add -A && git commit -m "message" && git push
```

---

**Last Updated:** 2024-12-23
**Maintained By:** Mauricio Wolff
**For:** Claude AI assistance with website changes
