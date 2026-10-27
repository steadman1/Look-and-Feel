# Look & Feel — Build Roadmap

A step-by-step plan for building Look & Feel, organized into **compartments** (cohesive modules) and ordered by **dependency** so each phase is self-contained and independently testable.

---

## Guiding Principle: One Document Model, Three Views

The three canvases are **three projections of the same design document**, not three separate apps.

```
                 ┌──────────────┐
                 │  LFDocument  │   ← single source of truth (Codable value type)
                 └──────┬───────┘
        ┌────────────────┼─────────────────┐
        │                │                 │
  ┌─────▼─────┐    ┌─────▼─────┐     ┌─────▼──────┐
  │ Artboard  │    │ Semantic  │     │  Edit Tree │
  │  (visual) │    │  (code)   │     │ (history)  │
  └───────────┘    └───────────┘     └────────────┘
        │                │                 │
   edit in any one  →  mutates the same doc  →  the others reflect it
```

- **Artboard Canvas** = visual editor over the document
- **Semantic Canvas** = code editor over the document (doc ⇄ code, bidirectional)
- **Edit Tree Canvas** = versioned *snapshots* of the document (doc → commit)
- **Persistence** = the serialized document on disk

> Everything downstream — persistence, git-like versioning, code sync — only works if the
> document model is **serializable and diffable**. That is why the model is Phase 0 and every
> other compartment hangs off it.

---

## Compartments (Modules)

We split the codebase into focused compartments so similar pieces live together and each can be
built + tested in isolation. Recommended as local Swift packages (or clearly-bounded folders if
we keep a single target for now):

| Compartment | Responsibility | Depends on | UI? |
|---|---|---|---|
| **LFCore** | The design document model: layers, properties, enums. Pure data, `Codable`. | — | No |
| **LFPersistence** | Save/load the document to/from disk; file format + versioning. | LFCore | No |
| **LFVersionControl** | Edit Tree *engine*: commits, branches, diffs, merges. Pure logic. | LFCore | No |
| **LFSemantic** | Code ⇄ document engine: serializer + parser. Pure logic. | LFCore | No |
| **LFUI** | Reusable design-system components (buttons, inputs, panels, interaction states). | — | Yes |
| **App** | Artboard canvas (rendering + tools) + app shell/navigation. Wires it all together. | All of the above | Yes |

**Why this split:** the four "engine" compartments (Core, Persistence, VersionControl,
Semantic) are **UI-free and fully unit-testable** — which is exactly where the project's
differentiating features live. The UI and the visual canvas are the only parts that touch
AppKit/SwiftUI. This keeps the risky, novel logic testable without spinning up a window.

---

## Phases (dependency-ordered)

Each phase ends in something **testable and demonstrable**. Phases 2, 3, and 4 are
**independent of each other** (all depend only on Phase 0) and can be done in any order or
in parallel.

### Phase 0 — LFCore: The Design Document Model  ⭐ keystone — ✅ COMPLETE
The foundation. Everything depends on it.

- [x] Define `LFDocument` (root): name, root layer list (`Codable`)
- [x] Model the layer tree: `LFLayer` **enum** (`.path` / `.text` / `.group`) over `LFPath`, `LFText`, `LFGroup`
- [x] Make the entire model **`Codable`** (unlocks Phases 1–3)
- [x] Make all enums `Codable` (`LFReflectionAxis`, `LFTypeStyle`, `LFParagraphStyle`, `LFStrokePosition`, `LFCornerStyle`)
- [x] `LFBezierPoint` as a clean `Codable` value (anchor + handle1/handle2 + corner style)
- [x] Group children as nested `LFLayer` values (tree representation)
- [x] Value semantics: a document is a cheap copy (snapshot) and `Hashable`/`Equatable` (diff-ready)
- [x] Unit tests: transform math, rendering-bridge smoke tests (size + draw)

**Decision #1 — settled: value types (Option A).** The canonical model is `Codable` **structs**.
Snapshots are cheap copies → trivial versioning + serialization. The live editing state wraps the
value in an `ObservableObject` container (`ArtboardViewModel`) for the UI.

**What was built (this session):**
- `LFCore/` — `LFColor` (pure RGBA, replaces non-`Codable` `NSColor`), `LFBase` (shared
  identity/transform), `LFBezierPoint`, `LFPath`, `LFText`, `LFGroup`, the unified `LFLayer`
  **enum**, and `LFDocument`. All `Codable` + `Hashable`.
- `LFCore/Protocols/` — `Transformable`, `Resizable`, `Traceable`, `Colorable`, `Typographic`
  (now with `mutating` requirements, satisfied by the enum + structs).
- `LFLayer+Rendering.swift` (UI seam) — `draw(in:)`, `symbol`, `recomputeSize()`, and the
  `LFColor`↔`NSColor` bridge. Keeps AppKit/SwiftUI out of `LFCore`.
- Migrated the UI to value semantics: `ArtboardViewModel` (write-back via `updateLayer(_:)`,
  capability queries replace protocol casts), `DesignPanel` (non-generic bindings),
  `CanvasLayerMutation` (copy → mutate → write back).
- Deleted the old class hierarchy (`Classes/LFLayer|LFPath|LFText|LFGroup|LFBezierPoint` +
  the old `Protocols/`).

**Verified:** clean build; app launches and runs; transform tests + rendering-bridge smoke
tests pass. (Rendering tests touch AppKit — run via Xcode, not the bare CLI runner.)

---

### Phase 1 — LFPersistence: Save / Open  ✅ COMPLETE
Depends on: LFCore.

- [x] Choose a file format → **`.lffile` bundle** (a directory: `document.json` + `assets/`)
- [x] `LFDocumentFile`: a SwiftUI `FileDocument` that reads/writes the bundle via `FileWrapper`
- [x] File-format **version field** (`formatVersion: 1`) + migration hook (`LFFile.migrating`)
- [x] Document lifecycle: New / Open / Save / Save As / autosave — via `DocumentGroup`
- [x] Unit tests: bundle round-trip; asset storage; version migration; snapshot

**Deliverable:** you can create a design, close the app, reopen it, and it's intact.

**Decision #2 — settled: `.lffile` bundle + `DocumentGroup`.**
- **Bundle, not single file.** A `.lffile` is a *directory* with `document.json` (the
  `LFFile` envelope, pretty-printed) + an `assets/` folder for binary images. `FileWrapper`
  natively represents a directory, so the bundle maps directly onto it — no custom container
  parsing. Keeps JSON clean (images stay real files on disk).
- **`DocumentGroup` (Option A).** The app entry point is a `DocumentGroup(newDocument:)`,
  giving native macOS Open / Save / Save As / Recent / autosave / multi-window for free.
- **`LFFile` envelope wraps `LFDocument`.** The envelope adds `formatVersion`, `appVersion`,
  `createdAt`, `modifiedAt`. Only Persistence touches `LFFile`; VersionControl + Semantic
  operate on the clean `LFDocument`.
- **Versioning from day one.** `formatVersion: 1` + a `migrateStep` switch, ready for v1→v2.

**What was built (this session):**
- `LFPersistence/LFFile.swift` — the envelope (`Codable, Equatable`); stamps
  `currentFormatVersion` + the running app's marketing version.
- `LFPersistence/LFDocumentFile.swift` — the `FileDocument`. Core I/O lives in
  `makeFileWrapper()` / `fromFileWrapper(_:)` (pure `FileWrapper`, unit-testable); the
  `FileDocument` methods are thin wrappers. `snapshot(contentType:)` returns the *design*
  (not the envelope) so volatile timestamps never trigger false "modified" states.
- `LFPersistence/LFFile+Migration.swift` — `migrating(_:)` rejects newer-version files and
  steps older ones forward via a version switch.
- `LFPersistence/LFPersistenceError.swift` — typed errors (missing doc, unsupported version,
  migration/encode/decode failures).
- `Helpers/UTType+LF.swift` — the exported `com.spencersteadman.look-and-feel.document` UTI
  (`.lffile` extension, conforms to `public.data` + `public.directory`).
- **Manual `Info.plist`** — the project switched from `GENERATE_INFOPLIST_FILE = YES` to a
  manual plist (required to declare the UTI). It carries the standard `CFBundle*` identity
  keys (via build-setting variables) + `UTExportedTypeDeclarations`. Excluded from Copy Bundle
  Resources via a filesystem-synchronized membership exception.
- **App integration** — `look___feelApp` uses `DocumentGroup`; `ContentView` takes a
  `Binding<LFDocumentFile>`, seeds `ArtboardViewModel` from the document, and syncs layer
  changes back (drives autosave). `ArtboardViewModel.init(document:)` bridges the two.

**Verified:** clean build; app launches and runs (DocumentGroup); all `PersistenceTests`
pass (round-trip, assets, migration, snapshot).

---

### Phase 2 — LFVersionControl: The Edit Tree Engine
Depends on: LFCore. (Pure logic — no UI.)

- [ ] `LFCommit`: a serialized document snapshot + metadata (message, timestamp, parent id, author)
- [ ] `LFBranch`: named pointer to a commit; `HEAD` concept
- [ ] Commit **tree** structure (parent/child links, DAG)
- [ ] **Diff**: given two commits, report which layers were added / removed / changed (and how)
- [ ] **Checkout**: restore the document to any commit
- [ ] **Merge**: combine two branches; define + test conflict behavior
- [ ] Unit tests: commit → branch → diverge → merge; diff correctness; checkout fidelity

**Deliverable:** a fully-tested, UI-free engine that records every edit as a node and can
branch/merge/revert — "Git, but for design." (The Edit Tree *Canvas* UI is Phase 5.)

---

### Phase 3 — LFSemantic: The Code ⇄ Document Engine
Depends on: LFCore. (Pure logic — no UI.)

- [ ] Design the **DSL**: a small, readable declarative language for describing a document
      (e.g. layers as indented blocks, properties as `key: value`, support for vars/loops later)
- [ ] **Serializer**: `LFDocument -> String` (stable, pretty-printed, deterministic)
- [ ] **Parser**: `String -> LFDocument` (with clear error reporting: line/column + message)
- [ ] **Round-trip guarantee**: `parse(serialize(doc)) == doc`
- [ ] (Stretch) support variables, loops, and logic for generative layouts
- [ ] Unit tests: round-trip fidelity; parser error cases; determinism

**Deliverable:** a design can be expressed as code and read back losslessly. (The Semantic
*Canvas* editor UI is Phase 5.)

---

### Phase 4 — Artboard Canvas: Complete the Visual Editor
Depends on: LFCore. (The most built-out area; we finish it.)

- [ ] **Real bezier rendering** — `LFPath` currently draws a placeholder rect; render actual
      curves from `LFBezierPoint`s (open + closed, all corner styles)
- [ ] Wire the **tools** that are currently buttons-only: pen, polygon, text, marker, erase,
      rotate, shear, scale
- [ ] **Direct selection** — edit individual bezier points/handles
- [ ] **Group / ungroup** (exercise `LFGroup`)
- [ ] Route all canvas mutations **through the document model** (so Semantic + Edit Tree see them)
- [ ] Performance: cull off-screen layers, batch redraws (the `overloadedPreview` 5k-layer case)

**Deliverable:** a genuinely usable visual editor whose edits flow into the shared document.

---

### Phase 5 — LFUI + New Canvas UIs
Depends on: Phases 2, 3, 4 (the engines they visualize).

- [ ] **Edit Tree Canvas UI** — visualize the commit tree; branch / merge / checkout / diff views
- [ ] **Semantic Canvas UI** — code editor (syntax highlighting, live preview, error overlay)
- [ ] **Design Panel** — finish property editors for every layer type (color, stroke, typography, bezier)
- [ ] **Constants Panel** — shared variables/styles
- [ ] Polish the interaction system (hover/focus/error states, cursors) across all new UI

**Deliverable:** all three canvases are real, navigable screens.

---

### Phase 6 — App Shell + Integration
Depends on: everything.

- [ ] Re-enable **canvas switching** (currently commented out in the toolbar)
- [ ] Wire the **single source of truth**: one `LFDocument`, three live views, all in sync
- [ ] Document management UI (menus: New / Open / Save / Save As; branch/commit actions)
- [ ] Connect Edit Tree commits to edits (auto-commit policy: manual vs. per-action)
- [ ] End-to-end test: edit in Artboard → see it in Semantic → commit → branch → merge → revert

**Deliverable:** the coherent, working app that matches the README's promise.

---

## Key Decisions

1. **Canonical model: value types (structs) vs. reference types (classes)?**
   → **Settled: value types.** `Codable` structs; the UI wraps them in an `ObservableObject`
   container. (Done in Phase 0.)
2. **File format:** plain JSON first, or a custom `.lf` container?
   → **Settled: `.lffile` bundle** (directory: `document.json` + `assets/`) via `FileWrapper`,
   surfaced through SwiftUI `DocumentGroup`. (Done in Phase 1.)
3. **DSL design:** what does the Semantic language *look* like?
   → Needs a small spec before Phase 3.
4. **Commit policy:** does every edit auto-commit, or do users commit explicitly?
   → Affects Phase 2/6 UX. (Decide in Phase 2.)
5. **Module structure:** local Swift packages now, or bounded folders in the single target first?
   → **Settled: bounded folders** (`LFCore/`, `LFPersistence/`, …) in the single target for now.
   The Xcode project uses filesystem-synchronized groups, so new folders are picked up
   automatically — no `project.pbxproj` edits. Split into local packages once Phase 0 is stable.

**Other Phase 0 decisions:**
- **Colors:** `NSColor` is not `Codable`, so the model uses a pure `LFColor` (RGBA) value type;
  an `LFColor`↔`NSColor` bridge lives in the UI layer.
- **Symbols:** the model stores `symbolName: String`; the SwiftUI `AnyView` is built in the
  rendering bridge (keeps SwiftUI out of `LFCore`).
- **Heterogeneous layers:** `LFLayer` is an **enum** (`.path`/`.text`/`.group`) — `Codable`
  conformance + type-safe pattern matching, replacing the old `as? (any Resizable)` casts.
- **Rendering is a UI-layer extension** (`LFLayer+Rendering.swift`), keeping `LFCore` pure.

---

## Current Status & Next Steps

**Phase 0 (LFCore) and Phase 1 (LFPersistence) are complete and verified.** The `Codable`
value-type document model is in place, the app is a native `DocumentGroup` document app that
saves/opens `.lffile` bundles, and it builds + launches cleanly.

**Next up — Phases 2–4 fan out independently** (all depend only on Phase 0). Suggested order:
1. **Phase 2 (LFVersionControl)** — the differentiator: git-like commit/branch/diff/merge
   engine over `LFDocument` snapshots. Pure logic, fully unit-testable.
2. **Phase 3 (LFSemantic)** — the other differentiator: code ⇄ document engine
   (serializer + parser with a round-trip guarantee). Pure logic.
3. **Phase 4 (Artboard Canvas)** — finish the visual editor (real bezier rendering, tools).

Phases 2 and 3 can run in parallel. Each is UI-free and unit-testable, so they can be built
and verified in isolation before the Phase 5/6 UI integration.
