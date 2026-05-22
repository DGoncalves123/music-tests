# music-tests

A Plugdata (Pure Data) playground for building modular synths, reusable
instruments, and live patches by wiring objects together — no code.

## Install (macOS)

```sh
brew install --cask plugdata
```

Or download from https://plugdata.org.

## Layout

```
instruments/    .pd patches — reusable synth "instrument templates"
effects/        .pd patches — reverb, delay, filters, etc.
songs/          .pd patches — full compositions / sessions
abstractions/   small reusable sub-patches (LFOs, ADSRs, utility blocks)
samples/        audio files (gitignored — keep large files out of the repo)
```

Plugdata can load any `.pd` from these folders as an "abstraction" inside
another patch — that's how you reuse instruments. Just type the file name
(without `.pd`) into a new object box.

## Getting started

1. Open Plugdata.
2. **File → Open** → `instruments/sine.pd` to see a minimal synth.
3. Toggle **DSP on** (top-right speaker icon, or Cmd+/).
4. Click the toggle/bang in the patch to hear sound.

To build a new instrument: **File → New**, save it into `instruments/` with a
descriptive name. To use it inside another patch, create an object box and
type the file name (e.g. `sine`).

## Edit vs Run mode

- **Edit mode** (Cmd+E) — wire objects, move things around.
- **Run mode** — click bangs/toggles/sliders to play.

## Stopping sound

Toggle DSP off (Cmd+/) or close the patch.
