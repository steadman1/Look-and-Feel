# Look and Feel

I'm Spencer, a cs student at vt (go hokies), and after years of paying for and loving Adobe Illustrator, it's time for a change. With my as of writing, 5+ years of Swift experience, I'm building **Look and Feel**, an open source "alternative" (quotes bc I obviously wont be able to add all of Ai's features) to Adobe Illustrator that fits my needs as a graphic designer, and also adds some pretty cool features that more engineer-minded people might find cool.

## What is Look and Feel going to be?

tldr; Figma/Illustrator x Text Editor x Git

Look and Feel is a WIP, vector design tool for macOS that merges the intuitive, visual-first workflow of a traditional artboard with the power and precision of a code-based editor.

I wanted both creative freedom and logical control, so I'm building two distinct ways to design in one place: an **Artboard Canvas** (like Figma or Illustrator) and the unique **Semantic Canvas.** This system is also backed by the **Edit Tree Canvas"**, a customizable, version control system that visualizes the entire lifecycle of your design, allowing you to experiment with changes, view every single edit made to a design, and merge ideas with confidence. Like Git, but for design.

## Core Features
1. The Dual Canvas System
You're no longer limited to a single mode of creation. Look and Feel syncs two canvases in real-time, giving you the right tool for any task.
Artboard Canvas: The direct-manipulation, WYSIWYG canvas you know and love. Drag, drop, resize, group, and style elements visually. It's perfect for rapid prototyping, exploration, and spatial arrangement.
Semantic Canvas: A code-editor interface where your design is represented as declarative code. This allows for:

Unmatched Precision: Set exact values, spacing, and relationships
Programmatic Design: Use variables, loops, and logic to generate complex patterns or layouts
Reusability: Define components and styles in code for perfect consistency
Accessibility: Edit your design in a text-first environment

2. The Edit Tree
Forget a simple undo/redo stack. The Edit Tree is a robust, Git-inspired version control system built directly into the app.

Complete History: Every single edit, from the moment you create a file, is saved as a node in the tree
Branching & Merging: Explore a new design idea by creating a branch. If you like it, merge it back into your main design. If you don't, simply discard the branch
Visual Lifecycle: The Edit Tree panel gives you a high-level overview of your entire creative process. See where you experimented, compare two branches visually, and instantly revert to any point in time without losing subsequent work

3. Native macOS Performance
Look and Feel is built from the ground up as a native macOS application, leveraging a hybrid SwiftUI and AppKit stack. This means you get a modern, clean interface powered by SwiftUI, combined with the raw performance and deep system integration of AppKit for the demanding tasks of a professional design tool.
Technology Stack

Swift: The core application language
SwiftUI: Used for the main application chrome, panels, and modern UI elements
AppKit: Leveraged for the high-performance artboard canvas, complex window management, and deep-level system interactions where performance is critical
Core Graphics: Powers the underlying vector rendering engine

Project Status & Roadmap
Look and Feel is currently in pre-alpha development. The core concepts are being implemented, and the foundation is being laid for a stable and feature-rich tool.
Our immediate roadmap is focused on building out the core user experience:

 Semantic Canvas: Develop the parser and syntax for the design-code language
 Canvas Sync: Implement the real-time, two-way data binding between the Artboard and Semantic canvases
 Edit Tree: Build the data model and UI for the branching version history
 Vector Tools: Implement basic shape tools (Pen, Rectangle, Ellipse, Text)
 Styling Panel: Create the initial UI for managing fills, strokes, and effects

Installation
As the project is in early development, you must build from source to run it.

Clone the repository:

bashgit clone https://github.com/your-username/look-and-feel.git
cd look-and-feel

Open in Xcode:

bashopen LookAndFeel.xcodeproj

Build & Run:

Select the Look and Feel target
Choose My Mac as the destination
Click the "Run" button (or press Cmd+R)



Contributing
We are actively looking for contributors! Whether you're a Swift developer, a UI/UX designer, or someone with great ideas, we'd love your help.
Please read our CONTRIBUTING.md file for details on our code of conduct and the process for submitting pull requests.
License
This project is licensed under the MIT License - see the LICENSE.md file for details.

Built with ☕ and way too many late nights in Blacksburg, VA
