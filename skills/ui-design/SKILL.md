---
name: ui-design
description: Use when designing or reviewing a user interface, including landing pages, dashboards, forms, and mobile screens, and when an interface looks generic or AI-generated and needs specific typography, spacing, color, real content, accessibility, and mobile-first fixes.
---

# UI Design

Make interfaces that look designed by a person for a specific user, not generated from a template.
Most AI-generated interfaces fail in the same ways: a purple-blue gradient hero, a centered headline
that could belong to any product, three identical feature cards, lorem ipsum text, and buttons that
all say "Get Started". This skill names those patterns and replaces each one with a concrete decision.

## What Good Looks Like

- One clear purpose per screen. A visitor can say in five seconds what
  the page does and what to do next.
- Specific content, not placeholders. Real names, real numbers, real prices, real screenshots.
  If the content is not real yet, write the real headline first and mark the missing data plainly.
- A visual hierarchy that matches the message: one dominant element,
  a few supporting elements, and everything else quiet.
- Restraint: two typefaces at most, three colors at most (plus neutrals),
  one accent used sparingly, and whitespace doing the separating
  instead of borders and boxes.
- Accessibility built in, not added later: real contrast, real labels,
  keyboard access, and text that scales.

## Workflow

1. Name the user and the one job. Write one sentence: "A shop owner in
   Dhaka opens this page to check today's orders." If you cannot write
   that sentence, do not design yet.
2. Write the content first. Headline, subhead, button labels, and the
   three most important facts — before any layout or color. Content
   decides the layout, never the reverse.
3. Sketch the hierarchy. Pick the single most important element and make it biggest, boldest, or first.
   If two elements compete for attention, one of them is wrong.
4. Set the type scale. One font for headings, one for body (or one font
   with two weights). Sizes on a scale — 13 / 15 / 18 / 24 / 32 / 48 px —
   and never a size off the scale.
5. Set the color system. One neutral palette (background, surface,
   border, text, muted text), one accent, and one status color each for
   success and error. No gradients unless the brand already uses one.
6. Lay out mobile-first. Design the 360 px-wide phone layout first,
   single column, thumb-reachable actions. Then expand to desktop;
   never shrink a desktop layout down and hope it fits.
7. Replace every placeholder. Swap lorem ipsum for real copy, grey boxes for real images, and "Feature 1"
   for the actual feature name. If an image is missing, use a real product screenshot or a plain color block —
   never a stock photo that means nothing.
8. Test the real thing. Open the page on a real phone, at 200% zoom,
   with keyboard only, and with images off. Fix what breaks before
   calling the design done.

## Typography

- Body text 15–17 px on desktop, 16 px minimum on mobile; line height
  1.5–1.7 for body, 1.1–1.2 for headings.
- Headings carry meaning: "Welcome to Our Platform" says nothing.
  "Track every bKash order in one place" says the job.
- Left-align body text. Centered paragraphs longer than two lines are
  hard to read; reserve centering for short hero lines.
- Never use more than two typefaces, and never set body text below
  14 px to "fit more in".
- Use real weights: 400 for body, 600 or 700 for headings. Avoid fake bold and letter-spacing wider than 0.05em on body text.

## Spacing and Layout

- Use an 8 px spacing scale: 8, 16, 24, 32, 48, 64, 96. Never use a
  random value like 13 px or 27 px for a margin.
- One section does one thing. A hero, then one proof section, then
  one feature section — not five sections competing at once.
- Whitespace separates; borders and background tints are a last resort.
  If every card needs a border to be visible, the spacing is wrong.
- Align to a grid. Text, images, and buttons share the same left edge;
  a stray element 12 px off the grid is visible at a glance.
- Buttons: one primary action per screen, 44 px minimum touch height,
  label in verb form ("Download the APK", not "Submit").

## Color

- Pick the accent from the brand or the content, not from a default
  palette. A streaming app can be red; a finance app can be green;
  neither needs a purple-blue gradient.
- Text contrast: body text at least 4.5:1 against its background, large headings at least 3:1. Check with a contrast tool, not by eye.
- Never use color alone to mean something. An error needs an icon and
  words, not just red text; a success needs a checkmark, not just green.
- Dark mode is a real second design: re-check contrast, borders, and
  muted text on the dark background instead of inverting the light one.

## Real Content Over Placeholders

- Bad: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
  Good: "Boishakhi TV, Ekushey TV, and 300+ live channels, checked
  every morning. Dead links removed before you open the app."
- Bad: three cards titled "Fast", "Secure", "Reliable" with the same
  icon. Good: one card per real capability, each with a number:
  "320 channels", "15-minute delivery", "2 servers per channel".
- Bad: a stock photo of people smiling at a laptop. Good: a real
  screenshot of the product, or a plain block with the real price.
- Bad: a testimonial from "John D., CEO". Good: a real quote with a
  real name, or no testimonial at all until one exists.

## Before / After Examples

Bad — generic gradient hero:

```html
<section style="background: linear-gradient(135deg, #667eea, #764ba2);
  text-align: center; padding: 100px 20px; color: white;">
  <h1>Welcome to Our Amazing Platform</h1>
  <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
  <button>Get Started</button>
  <button>Learn More</button>
</section>
```

Why it fails: the gradient says nothing, the headline could belong to
any product, the copy is placeholder text, and two equal buttons give
no clear next step.

Good — specific hero for a real product:

```html
<section style="background: #0f172a; color: #f8fafc;
  padding: 96px 24px;">
  <p style="color: #f59e0b;">320 live channels · checked daily</p>
  <h1>Every Bangla TV channel, in one app.</h1>
  <p>Boishakhi, Ekushey, NTV and 300 more — free, with a second
  server when the first one fails.</p>
  <button style="background: #f59e0b; color: #0f172a;
    padding: 14px 28px;">Download the APK — free</button>
  <p>2.1 MB · Android 8+ · No account needed</p>
</section>
```

Why it works: one deliberate dark background, a real number in the eyebrow, a headline that names the
product and the user, one primary action, and the honest details (size, version, no account) under the button.

Bad — three identical feature cards:

```html
<div class="card"><h3>Fast</h3><p>Lorem ipsum dolor sit amet.</p></div>
<div class="card"><h3>Secure</h3><p>Lorem ipsum dolor sit amet.</p></div>
<div class="card"><h3>Reliable</h3><p>Lorem ipsum dolor sit amet.</p></div>
```

Good — one real capability per card, each with proof:

```html
<div class="card"><h3>2 servers per channel</h3>
  <p>If Server 1 fails, tap Server 2. 14 channels have a backup today.</p></div>
<div class="card"><h3>Checked every morning</h3>
  <p>Dead links are removed at 08:00 Dhaka time, before you open the app.</p></div>
<div class="card"><h3>16:9 player, full width</h3>
  <p>The video never grows past its frame on mobile. Tested on a real phone.</p></div>
```

## Accessibility Checklist

- [ ] Contrast 4.5:1 for body text, 3:1 for large text, verified.
- [ ] Every image has alt text that says what it shows; decorative
  images have empty alt (`alt=""`).
- [ ] Every form field has a visible label, not placeholder-only text.
- [ ] Focus is visible on every interactive element when tabbing.
- [ ] The whole flow works keyboard-only, with no mouse-only hover action.
- [ ] Text scales to 200% zoom without overlapping or clipping.
- [ ] Color is never the only signal for success, error, or status.
- [ ] Touch targets are at least 44 × 44 px on mobile.

## Mobile-First Checklist

- [ ] Layout designed at 360 px wide first, single column.
- [ ] Primary action reachable with one thumb, near the bottom.
- [ ] No horizontal scrolling at any width; no text cut off.
- [ ] Tap targets 44 px minimum, spaced at least 8 px apart.
- [ ] Images sized for mobile; no 2 MB hero image on a phone.
- [ ] Tested on a real phone, not only a desktop browser resized.

## Design Review Checklist

- [ ] One sentence names the user and the one job of this screen.
- [ ] Headline is specific; it could not belong to another product.
- [ ] No lorem ipsum, no "Feature 1", no stock photo that means nothing.
- [ ] At most two typefaces, sizes on a scale, body 15 px or larger.
- [ ] At most three colors plus neutrals; no default purple-blue gradient.
- [ ] One primary action per screen, verb label, 44 px touch height.
- [ ] Spacing on the 8 px scale; elements aligned to a shared grid.
- [ ] Contrast, labels, focus, keyboard, and 200% zoom all verified.
- [ ] Real numbers and real content everywhere a claim is made.

## Pitfalls

- Do not start with a template and fill in the blanks. Templates produce the generic look; start with the content and the user.
- Do not add a gradient, glass effect, or animation to make a weak layout interesting. Fix the hierarchy and the copy first.
- Do not use an icon as a substitute for a label. An icon plus a word is clear; an icon alone is a guessing game.
- Do not center everything. Centering is for short hero lines, not for paragraphs, forms, or lists.
- Do not design only at desktop width. A layout that works at 1440 px and breaks at 360 px is not finished.
- Do not fake social proof. No invented testimonials, no invented user counts, no "trusted by" logos of companies that never used it.
- Do not ship placeholder text "for now". Placeholder text that ships is the product the user sees.
