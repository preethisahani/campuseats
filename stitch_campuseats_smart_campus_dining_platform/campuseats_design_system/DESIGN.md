---
name: CampusEats Design System
colors:
  surface: '#fbf9f5'
  surface-dim: '#dbdad6'
  surface-bright: '#fbf9f5'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f5f3ef'
  surface-container: '#efeeea'
  surface-container-high: '#eae8e4'
  surface-container-highest: '#e4e2de'
  on-surface: '#1b1c1a'
  on-surface-variant: '#41484a'
  inverse-surface: '#30312e'
  inverse-on-surface: '#f2f0ed'
  outline: '#71787b'
  outline-variant: '#c1c8ca'
  surface-tint: '#3b6470'
  primary: '#002831'
  on-primary: '#ffffff'
  primary-container: '#123f4a'
  on-primary-container: '#81aab7'
  inverse-primary: '#a3cddb'
  secondary: '#006492'
  on-secondary: '#ffffff'
  secondary-container: '#84cbff'
  on-secondary-container: '#00567d'
  tertiary: '#401900'
  on-tertiary: '#ffffff'
  tertiary-container: '#612a00'
  on-tertiary-container: '#fe8128'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bfe9f7'
  primary-fixed-dim: '#a3cddb'
  on-primary-fixed: '#001f27'
  on-primary-fixed-variant: '#224c58'
  secondary-fixed: '#c9e6ff'
  secondary-fixed-dim: '#8bceff'
  on-secondary-fixed: '#001e2f'
  on-secondary-fixed-variant: '#004b6f'
  tertiary-fixed: '#ffdbc9'
  tertiary-fixed-dim: '#ffb68c'
  on-tertiary-fixed: '#321200'
  on-tertiary-fixed-variant: '#753400'
  background: '#fbf9f5'
  on-background: '#1b1c1a'
  surface-variant: '#e4e2de'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '800'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
  body-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Be Vietnam Pro
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-bold:
    fontFamily: Be Vietnam Pro
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Be Vietnam Pro
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 14px
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
  2xl: 48px
  3xl: 64px
  container-max: 1280px
  gutter: 20px
  margin-mobile: 16px
  margin-desktop: 40px
---

## Brand & Style

The design system is crafted for a high-energy, campus-centric environment. It balances the urgency of student life with a premium, reliable service layer. The aesthetic draws from **Modern Corporate** principles but injects **Youthful Vitality** through vibrant accents and soft, approachable geometry.

The visual narrative focuses on "smart motion"—the idea that ordering food should be seamless, fast, and delightful. We leverage the warmth of the cream-based background to differentiate from sterile competitors, creating a "campus-hearth" feeling that is both inviting and technologically advanced.

## Colors

This design system utilizes a sophisticated "Sea and Sun" palette. The **Deep Teal (#123F4A)** serves as the anchor for typography and high-level navigation, providing a grounded, premium feel. The **Primary Blue** and **Soft Blue** represent the fluid, digital nature of the platform.

**Accent Orange (#F47A20)** is the primary action color, used sparingly for CTAs, notifications, and "Live" status indicators to ensure maximum visibility against the **Main Background (#FFFDF9)**. Use **Soft Peach** for subtle containers and secondary background groupings to maintain warmth without the harshness of pure white.

## Typography

We use **Plus Jakarta Sans** for headlines to provide a modern, friendly, and geometric personality that matches the logo’s character. For body copy and labels, **Be Vietnam Pro** is selected for its exceptional legibility and contemporary, slightly technical feel.

- **Headlines:** Use Bold or ExtraBold weights to establish clear hierarchy. Use tight letter-spacing on larger displays.
- **Body:** Stick to Regular weight for long-form reading. Use Medium for emphasis within paragraphs.
- **Micro-copy:** Labels should use the uppercase variant with slight letter-spacing to distinguish them from standard body text.

## Layout & Spacing

The layout utilizes a **12-column fluid grid** for desktop and a **4-column grid** for mobile. We employ an 8pt spacing system to maintain mathematical consistency across all components.

- **Desktop:** 12 columns, 24px gutters, and 40px side margins. 
- **Mobile:** 4 columns, 16px gutters, and 16px side margins. 
- **Stacking:** Use vertical spacing of 48px (2xl) between major sections and 16px (md) between related elements within a card or list item.
- **Safe Areas:** Ensure interactive elements (buttons) maintain a minimum of 12px padding from edge containers to prevent visual crowding.

## Elevation & Depth

Visual hierarchy is established through **Tonal Layering** and **Soft Ambient Shadows**. We avoid harsh black shadows in favor of tinted shadows that use the Primary Deep Teal color at very low opacities.

- **Level 0 (Flat):** Main background surface.
- **Level 1 (Low):** Cards and secondary containers. Use a 4px blur, 2px Y-offset, 4% opacity shadow: `rgba(18, 63, 74, 0.04)`.
- **Level 2 (Active/Floating):** Hover states and floating action buttons. Use a 12px blur, 6px Y-offset, 8% opacity shadow: `rgba(18, 63, 74, 0.08)`.
- **Level 3 (Modal):** Dialogs and popovers. Use a 24px blur, 12px Y-offset, 12% opacity shadow: `rgba(18, 63, 74, 0.12)`.

## Shapes

The design system uses a **Rounded (Level 2)** shape language to mirror the friendly, organic curves found in the platform's mascot and logo.

- **Standard Elements (Buttons, Inputs):** 0.5rem (8px) radius.
- **Cards & Containers:** 1rem (16px) radius for `rounded-lg`.
- **Featured Banners/Imagery:** 1.5rem (24px) radius for `rounded-xl`.
- **Interactive Pill States:** Use fully rounded corners for tags, chips, and filter toggles to create a "tactile" button feel.

## Components

### Buttons
- **Primary:** Background: Accent Orange; Text: White; Weight: Bold. On hover, darken by 10%.
- **Secondary:** Background: Soft Peach; Text: Deep Teal. On hover, change background to Primary Blue with White text.
- **Ghost:** Transparent background; Border: 1px Soft Blue; Text: Primary Blue.

### Input Fields
- **Default:** Background: White; Border: 1px Soft Blue (50% opacity); Text: Deep Teal.
- **Focus:** Border: 2px Primary Blue; Shadow: Level 1 elevation.
- **Error:** Border: 2px Busy (#E76F51); Include error icon in the right-hand slot.

### Cards (The "Food Card")
- White background with Level 1 elevation.
- Image takes the top 60% with a `rounded-t-lg` clip.
- Content area uses 16px padding.
- Footer uses a 1px border-top (Soft Peach) to separate price/rating from the description.

### Chips & Badges
- **Status Badges (Success/Busy):** Use a 10% opacity version of the color as the background, with the full-strength color for the text and a 2px lead dot.
- **Category Chips:** Light cream background, rounded-full, with an icon prefix.

### Lists
- Use horizontal dividers (1px Soft Peach) only when list density is high. Otherwise, rely on 16px vertical spacing between list items.
- Chevron indicators should use the Soft Blue color to remain subtle.