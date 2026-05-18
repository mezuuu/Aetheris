---
name: Aetheris High-Fidelity Audio
colors:
  surface: '#131314'
  surface-dim: '#131314'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1c'
  surface-container: '#201f20'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e5e2e2'
  on-surface-variant: '#c4c6ce'
  inverse-surface: '#e5e2e2'
  inverse-on-surface: '#313030'
  outline: '#8e9198'
  outline-variant: '#43474d'
  surface-tint: '#b2c8e8'
  primary: '#b2c8e8'
  on-primary: '#1c314b'
  primary-container: '#5e7390'
  on-primary-container: '#f5f7ff'
  inverse-primary: '#4b607c'
  secondary: '#bec7db'
  on-secondary: '#283140'
  secondary-container: '#40495a'
  on-secondary-container: '#b0b9cc'
  tertiary: '#cbc2df'
  on-tertiary: '#332d44'
  tertiary-container: '#756e88'
  on-tertiary-container: '#fcf6ff'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d3e4ff'
  primary-fixed-dim: '#b2c8e8'
  on-primary-fixed: '#041c35'
  on-primary-fixed-variant: '#334863'
  secondary-fixed: '#dae3f7'
  secondary-fixed-dim: '#bec7db'
  on-secondary-fixed: '#131c2a'
  on-secondary-fixed-variant: '#3e4757'
  tertiary-fixed: '#e8defc'
  tertiary-fixed-dim: '#cbc2df'
  on-tertiary-fixed: '#1d182e'
  on-tertiary-fixed-variant: '#49435b'
  background: '#131314'
  on-background: '#e5e2e2'
  surface-variant: '#353535'
  deep-midnight: '#161126'
  surface-dark: '#353E4E'
  slate-muted: '#666571'
  sky-accent: '#5E7390'
  silver-highlight: '#9A9898'
typography:
  display-lg:
    fontFamily: Montserrat
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Montserrat
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-lg-mobile:
    fontFamily: Montserrat
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Montserrat
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-md:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 10px
    fontWeight: '700'
    lineHeight: 12px
    letterSpacing: 0.08em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-margin: 1.5rem
  gutter: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2rem
  section-gap: 2.5rem
---

## Brand & Style

The design system is engineered for the audiophile who demands absolute clarity and a premium, futuristic experience. It centers on the "Aetheris" ethos—sky, clarity, and expansive space—translated into a digital environment that feels lightweight yet technically superior.

The visual direction is a sophisticated blend of **Corporate Modern** structure and **Premium Glassmorphism**. It utilizes deep, starlight-inspired dark backgrounds to provide a sense of infinite depth, while UI elements appear as frosted glass layers floating in this void. The aesthetic is "Gen Z-friendly futuristic," avoiding heavy cyberpunk tropes in favor of clean lines, ethereal blurs, and smooth, high-fidelity transitions.

Key visual pillars:
- **Atmospheric Depth:** Usage of starlight gradients and fluid background blobs that react to album art.
- **Precision:** Clear, centered technical indicators (e.g., Bit-Perfect, FLAC) to emphasize hardware-level performance.
- **Immersive Utility:** Combining the structural efficiency of grid-based navigation with full-bleed, emotional visual canvases for active listening.

## Colors

The palette is strictly dark-mode centric, designed to reduce visual noise and emphasize the vibrant colors of album artwork.

- **Deep Midnight Purple:** The foundation of the UI, used for the primary background to create an expansive, "starlight" atmosphere.
- **Surface/Card (Dark Blue Gray):** Used for glassmorphic containers and secondary surfaces to provide subtle separation from the background.
- **Muted Sky Blue:** Reserved for primary actions, active states, and highlighting specific high-fidelity technical data.
- **Soft Silver:** The primary typeface and iconography color, ensuring high legibility against dark surfaces without the harshness of pure white.
- **Slate Gray:** Employed for tertiary information, secondary text, and inactive UI states to maintain a clear visual hierarchy.

## Typography

Typography in this design system balances geometric modernity with utilitarian clarity.

- **Headlines (Montserrat):** Used for major titles and wordmarks. Its geometric construction provides a futuristic, high-end feel. High-weight variants are used for track titles to ensure they command the space.
- **Body & Controls (Inter):** Chosen for its exceptional legibility at small sizes and its neutral, systematic character. It is used for all technical data, metadata, and body content.
- **Labels:** Technical audio badges (FLAC, 24-bit) utilize Inter in a bold, all-caps format with increased letter-spacing to mimic professional hardware labeling.

## Layout & Spacing

This design system utilizes a **fluid grid** model optimized for mobile-first interaction. 

- **Grid System:** A 12-column grid for tablet/desktop and a 4-column grid for mobile.
- **Margins:** Consistent 24px (1.5rem) side margins for all primary content containers to ensure a breathable, premium feel.
- **Spacing Rhythm:** Based on an 8px base unit. 16px is the standard gutter between cards in a grid (Recently Played).
- **Component Layout:** The player interface uses a centered vertical stack for metadata to maintain visual balance, while the library uses a list-based horizontal layout for rapid scanning.

## Elevation & Depth

Visual hierarchy is established through **Glassmorphism** and tonal layering rather than traditional drop shadows.

- **Background Layers:** The deepest layer is the Midnight Purple with subtle starlight textures. Fluid, low-opacity blobs of color (derived from album art) float behind content to provide warmth.
- **Surface Layers:** Cards and menus use a semi-transparent Dark Blue Gray (30-50% opacity) with a background blur (15px to 30px). 
- **Outlines:** To define boundaries without adding bulk, glassmorphic elements feature a 1px "inner glow" or "ghost border" in a low-opacity Soft Silver.
- **Shadows:** Only used sparingly on the primary album art container in the full player to "lift" it off the blurred background. These shadows are extra-diffused and tinted with the primary accent color.

## Shapes

The shape language is consistently "Rounded" to convey a friendly yet modern technological feel.

- **Cards & Containers:** 1rem (16px) corner radius provides a soft, premium appearance that feels tactile.
- **Interactive Elements:** Small buttons and technical chips use the 0.5rem base roundedness.
- **Player Controls:** The play/pause and secondary transport controls should maintain a circular or highly rounded profile to contrast with the square album art.
- **Album Art:** Should mirror the card roundedness (1rem) to maintain system consistency.

## Components

### Buttons & Controls
- **Primary Action:** Solid Muted Sky Blue with Soft Silver text.
- **Secondary Action:** Glassmorphic background with 1px Soft Silver border.
- **Transport Controls:** High-contrast icons in Soft Silver. The central Play/Pause button should be the largest interactive element on the screen.

### Technical Badges (Audio Labels)
- **Style:** Small, pill-shaped containers with a 1px border. 
- **Content:** "FLAC", "24-bit / 96kHz", "Bit-Perfect".
- **Placement:** Always horizontally centered under the track title in the Full Player to emphasize the "Hi-Fi" status as a badge of quality.

### Cards
- **Album/Playlist Cards:** Feature a large cover art image, a 16px corner radius, and a glassmorphic footer for the title and artist.
- **Genre Cards:** Utilize vibrant gradients masked within the glassmorphic card style.

### Inputs & Search
- **Search Bar:** A full-width frosted glass field with a search icon on the left. The placeholder text should be Slate Gray to denote inactivity.

### Mini-Player
- **Structure:** A floating glassmorphic bar positioned above the bottom navigation. It must include a tiny thumbnail, song details, and a centered quality indicator.

### Sliders (Seek Bar & EQ)
- **Style:** Thin tracks in Slate Gray with an active segment in Muted Sky Blue. The "thumb" or handle should be a small Soft Silver circle.