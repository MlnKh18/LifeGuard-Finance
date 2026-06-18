---
name: Premium Glassmorphic Dark Slate
colors:
  surface: '#0b1326'
  surface-dim: '#0b1326'
  surface-bright: '#31394d'
  surface-container-lowest: '#060e20'
  surface-container-low: '#131b2e'
  surface-container: '#171f33'
  surface-container-high: '#222a3d'
  surface-container-highest: '#2d3449'
  on-surface: '#dae2fd'
  on-surface-variant: '#bcc9c6'
  inverse-surface: '#dae2fd'
  inverse-on-surface: '#283044'
  outline: '#879391'
  outline-variant: '#3d4947'
  surface-tint: '#6bd8cb'
  primary: '#6bd8cb'
  on-primary: '#003732'
  primary-container: '#29a195'
  on-primary-container: '#00302b'
  inverse-primary: '#006a61'
  secondary: '#adc6ff'
  on-secondary: '#002e6a'
  secondary-container: '#0566d9'
  on-secondary-container: '#e6ecff'
  tertiary: '#b6c4ff'
  on-tertiary: '#05297a'
  tertiary-container: '#748de1'
  on-tertiary-container: '#00226e'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#89f5e7'
  primary-fixed-dim: '#6bd8cb'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#d8e2ff'
  secondary-fixed-dim: '#adc6ff'
  on-secondary-fixed: '#001a42'
  on-secondary-fixed-variant: '#004395'
  tertiary-fixed: '#dce1ff'
  tertiary-fixed-dim: '#b6c4ff'
  on-tertiary-fixed: '#00164e'
  on-tertiary-fixed-variant: '#264191'
  background: '#0b1326'
  on-background: '#dae2fd'
  surface-variant: '#2d3449'
  slate-surface: '#1E293B'
  slate-border: '#334155'
  text-primary: '#F8FAFC'
  text-secondary: '#94A3B8'
  status-safe: '#10B981'
  status-warning: '#F59E0B'
  status-vulnerable: '#F97316'
  status-critical: '#EF4444'
typography:
  display-lg:
    fontFamily: Outfit
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Outfit
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Outfit
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  data-display:
    fontFamily: Inter
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
    letterSpacing: -0.01em
  data-label:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-caps:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  margin-sm: 16px
  margin-lg: 24px
  gutter: 16px
  card-padding: 20px
---

## Brand & Style

The visual identity is anchored in a **Premium Glassmorphic Dark Slate** aesthetic. This design system is engineered to evoke feelings of security, technical precision, and modern sophistication—essential for a high-stakes financial resilience tool.

The style utilizes a deep, multi-layered dark mode foundation with high-contrast accents to guide the eye through complex data. Glassmorphism is applied selectively to card surfaces to create visual depth and a "high-tech" laboratory feel, symbolizing the app's role as a sandbox for crisis simulation. The contrast between the matte slate backgrounds and vibrant, glowing status colors ensures that critical financial risks are never missed.

## Colors

The palette is built on a "Dark Slate" foundation to provide a professional, low-strain environment for financial analysis.

- **Primary (Emerald Teal):** Used for growth indicators, primary actions, and positive progress.
- **Secondary (Electric Blue):** Reserved for interactive elements like sliders, focus states, and navigation tabs.
- **Risk Status Colors:** A strict four-tier color system (Safe, Warning, Vulnerable, Critical) is used globally to categorize financial health. These should be used for gauges, semantic icons, and specialized alerts.
- **Neutral/Surface:** The background uses `#0F172A`, while interactive cards use a lighter slate (`#1E293B`) to create hierarchy.

## Typography

This design system uses a dual-font strategy to balance character with legibility:
- **Outfit:** The primary UI font. Its geometric yet friendly curves provide a modern, accessible feel for headers and narrative text.
- **Inter:** The specialized font for numerical data and technical labels. It is chosen for its superior legibility in small sizes and high-precision digit shapes, which are critical for currency and score displays.

**Scaling Rules:**
- For mobile, `display-lg` should be capped at `36px` to maintain comfortable line lengths.
- Use `label-caps` (Uppercase with tracking) for section headers in the Settings or Dashboard cards to provide a structured, "modular" feel.

## Layout & Spacing

This design system employs a **Fluid Grid** model based on a **4px base unit**.

- **Mobile:** Uses a standard 4-column grid with 16px side margins and 16px gutters.
- **Spacing Rhythm:** Vertical spacing between cards and sections should follow a 16px/24px/32px progression to maintain breathing room.
- **Content Reflow:** In simulation views (Sandbox), controls like sliders should span the full width of the card padding, while result metrics can be grouped in a 2-column sub-grid.

## Elevation & Depth

Hierarchy is achieved through **Glassmorphism** and **Tonal Layering** rather than traditional black shadows.

- **The Base:** The deepest layer is the solid `#0F172A` background.
- **Glass Surfaces:** Cards use a semi-transparent slate (`#1E293B` at 80-90% opacity) with a `16px` backdrop blur.
- **Stroke Definition:** To compensate for the dark background, every surface must have a `1px` inner border of `#334155` at 40% opacity. This creates a "glass edge" effect that catches light.
- **Neon Accents:** Elements of high importance (like the active FVS projection card) may use a subtle outer glow (drop shadow with 8-12px blur) matching the semantic color of the risk level (e.g., a faint red glow for Critical).

## Shapes

The design uses a consistent **16px (Rounded)** corner radius for all primary containers, providing a approachable feel that balances the technical nature of the data.

- **Primary Cards & Modals:** 16px (`rounded-lg`).
- **Interactive Chips & Buttons:** 12px (adjusted for smaller scale).
- **Selection Indicators:** Use a pill shape (fully rounded) for tab indicators and slider handles.

## Components

### Buttons & Inputs
- **Primary Action:** Solid Emerald Teal background with White text. High-contrast and no shadow.
- **Interactive Sliders:** Electric Blue tracks with high-contrast white/blue handles. The value label should float above the handle in Inter font.
- **Input Fields:** Transparent backgrounds with a Slate Border (`#334155`). On focus, the border transitions to Electric Blue.

### Cards & Gauges
- **Glassmorphic Cards:** All containers must feature the 16px radius and the subtle 1px border.
- **Circular Gauge:** The arc thickness should be 12-16px. The center should house the Inter bold score. The color of the arc must transition based on the risk levels defined in the Colors section.

### Data Display
- **Checklists (Mitigation Plan):** Use custom checkbox styles. Completed items should transition to 60% opacity with a strike-through. Use category badges (e.g., Teal for 'Dana Darurat') with a 4px radius and 10% background opacity.
- **Status Chips:** Small, high-saturation chips used for priority levels (High, Medium, Low).
