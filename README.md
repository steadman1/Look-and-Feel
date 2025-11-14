# Look and Feel

I'm Spencer, a cs student at vt (go hokies), and after years of paying for and loving Adobe Illustrator, it's time for a change. With my as of writing, 5+ years of Swift experience, I'm building **Look and Feel**, an open source "alternative" (quotes bc I obviously wont be able to add all of Ai's features) to Adobe Illustrator that fits my needs as a graphic designer, and also adds some pretty cool features that more engineer-minded people might find cool.

## What is Look and Feel going to be?

tldr; Figma/Illustrator x Text Editor x Git

Look and Feel is a WIP, vector design tool for macOS that merges the intuitive, visual-first workflow of a traditional artboard with the power and precision of a code-based editor.

I wanted both creative freedom and logical control, so I'm building two distinct ways to design in one place: an **Artboard Canvas** (like Figma or Illustrator) and the unique **Semantic Canvas.** This system is also backed by the **Edit Tree Canvas**, a customizable, version control system that visualizes the entire lifecycle of your design, allowing you to experiment with changes, view every single edit made to a design, and merge ideas with confidence. Like Git, but for design.

## Core Features
### The Multi-Canvas System
By bringing multiple canvases/environments into one place, I'm building Look and Feel to encourage everyone, designers, engineers, etc. to feel at home with the ability to create in the best environment for their needs.


**Artboard Canvas**: The WYSIWYG canvas style you know and love from Figma and Illustrator that you love, so you can:
1. Create and edit designs visually, with a familiar interface
2. Use layers, groups, and shapes to build complex compositions
3. Export designs as images or vector files for further editing or sharing


**Semantic Canvas**: A code-editor interface where your design is represented as declarative code, so you can:
1. Set exact values, spacing, and relationships
2. Use variables, loops, and logic to generate complex patterns or layouts
3. Define components and styles in code for perfect consistency
4. Edit your design in a text-first environment


**Edit Tree Canvas**: A robust, Git-inspired version control system with a powerful UI—no more simple undo/redo stack, so you can:
1. View every single edit, from the moment you create a file, is saved as a node in the tree
2. Explore a new design idea by creating a branch. If you like it, merge it back into your main design. If you don't, discard the branch
3. Review your entire creative process, see where you experimented, compare two branches visually, and instantly revert to any point in time without losing subsequent work

## Tech Stack

Swift: Core app language

SwiftUI: Used for the main app, Edit Tree & Semantic Canvas, panels, and modern UI elements

AppKit: Leveraged for the high-performance Artboard Canvas by wrapping into SwiftUI

## Installation
Clone the repository:
```bash
git clone https://github.com/your-username/look-and-feel.git
cd look-and-feel
```
Open in Xcode:
```bash
open LookAndFeel.xcodeproj
```
Build & Run:

1. Select the Look and Feel target
2. Choose My Mac as the destination
3. Click the "Run" button (or press Cmd+R)

## License
This project is licensed under the MIT License - see the LICENSE.md file for details.

Made with ❤️ by steadman1
