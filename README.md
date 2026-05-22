# music-tests

A SuperCollider workspace organized around two activities:

1. **Designing rhythms** — a pulse network where you decide *when* things fire.
2. **Designing voices** — per-instrument files where you decide *what* each
   trigger sounds like, in isolation.

Each voice can be muted, soloed, retuned, or rebuilt without stopping the
others. The rhythm file and the voices talk through named `Pdef`s and shared
SynthDefs.

## Install (macOS)

```sh
brew install --cask --appdir=~/Applications supercollider
```

## Workflow

### 1. Boot once

Open `startup.scd` and evaluate the whole file (Cmd+A, Cmd+Return).
This boots the audio server, loads every SynthDef in `instruments/`, and
defines the master tempo clock.

### 2. Design rhythms in `rhythm/network.scd`

This is your "pulse network" view: master tempo, division streams, AND
coincidence, Bernoulli probability, and the `Pdef`s that route triggers
to each voice. Evaluate parenthesized blocks to load/update the patterns.
Patterns hot-swap — change something and re-evaluate, no need to stop.

Mute / solo individual voices from there:
```supercollider
Pdef(\kick).stop;        // mute one
Pdef(\kick).play;        // unmute
~mute.(\kick);           // helper if you prefer
~solo.(\hat);            // solo one (mutes all others)
~unsolo.();              // back to normal
```

### 3. Design a single voice in `voices/<name>.scd`

Each voice file is self-contained. Open `voices/kick.scd` and you'll see:

- A **SynthDef** for the sound (the "instrument template").
- A small **playground** block — trigger the voice in isolation while you tweak
  oscillators, envelopes, filters. Cmd+Return on individual lines to fire it.
- Once the SynthDef is reloaded (`.add`), the rhythm in `rhythm/network.scd`
  immediately uses the new version on the next trigger. No restart needed.

This means you can have `network.scd` running in one tab, `voices/kick.scd`
open in another, and shape the kick while the groove keeps playing.

### 4. Free experimentation

`live/scratch.scd` is a notebook for one-off ideas, sketches, and tests.

## Layout

```
startup.scd          boot server, load instruments, define helpers + tempo clock
instruments/         SynthDefs (one file per voice — the reusable "templates")
rhythm/network.scd   the pulse-network: tempo, divisions, AND, Bernoulli, Pdefs
voices/              per-voice playgrounds (isolated tweaking + soloing)
live/scratch.scd     free experimentation
samples/             audio files (gitignored)
```

## Cheatsheet

| Action                          | Mac          |
|---------------------------------|--------------|
| Evaluate line / selection / block | Cmd+Return |
| Stop ALL sound (panic)          | Cmd+.        |
| Help for word under cursor      | Cmd+D        |
| Boot server                     | run `startup.scd` |
| Stop one voice                  | `Pdef(\name).stop;` |
| Play one voice                  | `Pdef(\name).play;` |
| Solo one voice                  | `~solo.(\name);`   |
| Clear solo                      | `~unsolo.();`      |
