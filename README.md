# music-tests

A SuperCollider workspace split into three panels, each with a single job.

## Install

```sh
brew install --cask --appdir=~/Applications supercollider
```

VS Code extension: Cmd+Shift+X → search **supercollider** → install **mozochrome.supercollider**.

---

## 3-panel layout

Set this up once, then VS Code remembers it.

```
┌─────────────────────┬──────────────────────┬─────────────────────┐
│   LEFT              │   MIDDLE             │   RIGHT             │
│   rhythm/           │   utilities/         │   voices/           │
│   network.scd       │   control.scd        │   <name>.scd        │
│                     │                      │                     │
│  Design WHEN        │  Operate the system  │  Design WHAT        │
│  things fire        │  while it runs       │  each voice sounds  │
│                     │                      │                     │
│  • Pbind patterns   │  • freeze / thaw     │  • SynthDef         │
│  • durations        │  • mute / solo       │  • one-shot tests   │
│  • probabilities    │  • tempo             │  • parameter tweaks │
│  • pitch sequences  │  • stop / restart    │                     │
└─────────────────────┴──────────────────────┴─────────────────────┘
                              ↑
                        post window
                        (bottom panel)
```

**To open the layout:**
1. Open VS Code with this folder.
2. Open `rhythm/network.scd` — drag it to the **left** column.
3. Open `utilities/control.scd` — drag it to the **centre** column.
4. Open any `voices/<name>.scd` — drag it to the **right** column.
5. Open `startup.scd` anywhere (or as a 4th tab) — run it once then close/minimise.

VS Code tip: View → Editor Layout → Three Columns sets up the columns in one step.

---

## Session workflow

### 1. Boot (once per session)
Open `startup.scd`. Cmd+A, Cmd+Enter. Wait for "Ready" in the post window.

### 2. Start the rhythm (left panel)
In `network.scd`, Cmd+Enter inside each `( )` block top to bottom.
Each block starts one voice. Re-evaluate any block anytime to hot-swap it.

### 3. Control the network (middle panel)
Single lines — put cursor on a line, Cmd+Enter to fire it:
- `~freeze.(\kick)` — locks kick on its last 8 steps at the next bar
- `~freezeAll.()` — locks everything at once
- `~thaw.(\kick)` — releases it back to evolving
- `~solo.(\hat)` — solo one voice
- `~kickProb = 0.3` + Cmd+Enter — make kick sparse

### 4. Shape a sound (right panel)
Open a voice file. Edit its SynthDef, Cmd+Enter on the `( )` block to reload.
The running rhythm picks up the new sound immediately — no restart.
Use the commented playground lines below the SynthDef to fire one-shots.

### 5. Stop
- `Cmd+.` — panic, stops everything
- `(~voices.do({ |v| Pdef(v).stop });)` in control.scd — graceful stop

---

## File layout

```
startup.scd              boot + all infrastructure (freeze, mute, solo helpers)
rhythm/
  network.scd            LEFT panel — pattern design only
utilities/
  control.scd            MIDDLE panel — operational controls only
voices/
  kick.scd               RIGHT panel — swap these out per voice
  thump.scd
  blip.scd
  hat.scd
  ping.scd
instruments/             SynthDefs loaded at boot (one file per voice)
live/scratch.scd         free experimentation
samples/                 audio files (gitignored)
```

---

## Quick reference

| What                        | How                                      |
|-----------------------------|------------------------------------------|
| Evaluate block              | Cmd+Enter inside `( )`                   |
| Evaluate single line        | Cmd+Enter on the line                    |
| Panic / stop all sound      | Cmd+.                                    |
| Freeze voice at next bar    | `~freeze.(\name);` in middle panel       |
| Thaw voice                  | `~thaw.(\name);` in middle panel         |
| Solo                        | `~solo.(\name);` / `~unsolo.();`         |
| Change tempo                | `TempoClock.default.tempo = 130/60;`     |
| Reload a SynthDef           | Cmd+Enter on the SynthDef `( )` block    |
