# Design System: Slate & Emerald M3 (Dark)

> Reference only — not currently applied to the app. The app's active theme is the
> **light** Stitch palette documented in `design_system.md`, derived from the actual
> Stitch HTML mockups used for the screen-by-screen rebuild. This dark M3 variant was
> supplied separately and is kept here for future use if/when a dark mode is built.

```yaml
name: Slate & Emerald M3
colors:
  surface: '#0f1413'
  surface-dim: '#0f1413'
  surface-bright: '#353a39'
  surface-container-lowest: '#0a0f0e'
  surface-container-low: '#171d1c'
  surface-container: '#1b2120'
  surface-container-high: '#262b2a'
  surface-container-highest: '#303635'
  on-surface: '#dee4e1'
  on-surface-variant: '#bcc9c6'
  inverse-surface: '#dee4e1'
  inverse-on-surface: '#2c3130'
  outline: '#879391'
  outline-variant: '#3d4947'
  surface-tint: '#6bd8cb'
  primary: '#6bd8cb'
  on-primary: '#003732'
  primary-container: '#29a195'
  on-primary-container: '#00302b'
  inverse-primary: '#006a61'
  secondary: '#b9c8de'
  on-secondary: '#233143'
  secondary-container: '#39485a'
  on-secondary-container: '#a7b6cc'
  tertiary: '#ffb59a'
  on-tertiary: '#591c02'
  tertiary-container: '#d27956'
  on-tertiary-container: '#4f1700'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#89f5e7'
  primary-fixed-dim: '#6bd8cb'
  on-primary-fixed: '#00201d'
  on-primary-fixed-variant: '#005049'
  secondary-fixed: '#d4e4fa'
  secondary-fixed-dim: '#b9c8de'
  on-secondary-fixed: '#0d1c2d'
  on-secondary-fixed-variant: '#39485a'
  tertiary-fixed: '#ffdbce'
  tertiary-fixed-dim: '#ffb59a'
  on-tertiary-fixed: '#370e00'
  on-tertiary-fixed-variant: '#773215'
  background: '#0f1413'
  on-background: '#dee4e1'
  surface-variant: '#303635'

typography:
  display-large:
    fontFamily: Outfit
    fontSize: 57px
    fontWeight: '400'
    lineHeight: 64px
    letterSpacing: -0.25px
  headline-large:
    fontFamily: Outfit
    fontSize: 32px
    fontWeight: '400'
    lineHeight: 40px
  headline-medium:
    fontFamily: Outfit
    fontSize: 28px
    fontWeight: '400'
    lineHeight: 36px
  title-large:
    fontFamily: Outfit
    fontSize: 22px
    fontWeight: '500'
    lineHeight: 28px
  title-medium:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
    letterSpacing: 0.15px
  body-large:
    fontFamily: Outfit
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
    letterSpacing: 0.5px
  body-medium:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
    letterSpacing: 0.25px
  label-large:
    fontFamily: Outfit
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.1px
  label-medium:
    fontFamily: Outfit
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.5px

rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px

spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  margin-desktop: 24px
  gutter: 16px
```

---

## Brand & Style

The brand personality is sophisticated, high-tech, and precise. It targets a professional audience that values deep focus and premium aesthetics. By merging the structural rigor of **Material Design 3 (M3)** with a **Glassmorphic** overlay, the UI evokes a sense of depth and clarity.

The style is defined by "Material Glassmorphism": it utilizes M3's tonal elevation system as the foundation but enhances it with backdrop blurs and subtle translucency. The primary aesthetic is dark, utilizing "Dark Slate" as a grounding force, contrasted by a vibrant "Emerald Teal" that signals action and vitality.

## Colors

The palette is built strictly on M3 color roles to ensure accessible contrast and semantic clarity.

- **Primary (Emerald Teal):** Used for key action buttons and active states.
- **Surface (Dark Slate):** The foundational background color. Surfaces receive a subtle teal-tinted overlay proportional to their elevation level, following M3 logic.
- **Glassmorphic Accents:** Semi-transparent versions of `surface_variant` (60-80% opacity) should be used for floating panels, paired with a `blur` effect of 16px to maintain legibility.

## Typography

This design system utilizes **Outfit** across all levels to maintain a modern, geometric feel. We follow the Flutter `TextTheme` naming convention.

- **Headlines:** Use generous tracking for larger sizes to maintain a premium feel.
- **Body Text:** Optimized for readability on dark backgrounds with `body-large` as the default for long-form content.
- **Labels:** Used for functional elements like buttons, navigation tabs, and chips.

## Layout & Spacing

The system follows an 8dp grid for vertical rhythm and a 4dp increment for fine-tuned internal component spacing.

- Use a 12-column grid for desktop and a 4-column grid for mobile.
- **TopAppBar:** Fixed at 64px height (standard) or 112px (large/expanded).
- **NavigationBar:** Height is set to 80px, ensuring touch targets are generous and the active pill indicator has sufficient breathing room.
- **Margins:** Standardize on 16px for mobile edges to maximize screen real estate while maintaining a safe "touch buffer."

## Elevation & Depth

Elevation is achieved through **M3 Tonal Palettes** rather than traditional black drop shadows.

- **Level 0 (Surface):** Default background (#0F172A).
- **Level 1-5:** Surfaces are layered with the `primary_color` at increasing opacities (5% to 15%) to simulate height.
- **Glassmorphic Overlay:** For components like the `NavigationBar` or `TopAppBar`, a backdrop filter (`SigmaX/Y: 12.0`) is applied over the surface color to create a "frosted" effect that lets content peek through from behind.
- **Outlines:** Use the `outline` token (1px width) for low-elevation cards to keep the UI crisp without adding visual weight.

## Shapes

We strictly follow M3 shape categories to define component boundaries:

- **Extra Large (28px):** Dialogs and Bottom Sheets.
- **Large (16px):** Standard Cards and expanded floating action buttons.
- **Medium (12px):** Menus and small cards.
- **Small (8px):** Text fields and internal chips.
- **Pill/Full:** Active state indicators in the NavigationBar and standard Buttons.

## Components

- **TopAppBar:** Centered title for standard pages. On scroll, the background transitions from transparent to a glassmorphic `surface-variant` with a 1px bottom border.
- **NavigationBar:** 80px height. Active states must use a pill-shaped "container" behind the icon using the `primary_container` color. Icons use `on_primary_container`.
- **Buttons:** Filled buttons use `primary` with 100% rounded (pill) corners. Text buttons use `primary` color for the label only.
- **Cards:** Use `ElevatedCard` for primary content (with tonal tint) and `OutlinedCard` for secondary content to maintain a hierarchy of importance.
- **Input Fields:** Filled style with a 1px bottom stroke or fully outlined with `small` (8px) rounded corners. Background should be `surface_variant` at 50% opacity when unfocused.
- **Chips:** `Medium` rounded corners, using `outline` for inactive states and `primary_container` for active selection.
