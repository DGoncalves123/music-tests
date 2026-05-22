# pulse-network — VCV Rack build (Fundamental modules only)

Same idea as `pulse-network.pd`: a master pulse → division LEDs → AND coincidence
→ Bernoulli probability gate → five quick voices.

All modules below are from the **Fundamental** pack that ships with VCV Rack 2.
No 3rd-party modules. Where Fundamental can't do something exactly, the
substitution is noted.

## Modules to add

| # | Module           | Role                                |
|---|------------------|-------------------------------------|
| 1 | **LFO**          | master pulse (square out)           |
| 2 | **8vert**        | per-voice attenuators / probability knob |
| 3 | **VCO-1**        | low thump (÷2)                      |
| 4 | **VCO-1**        | mid blip (÷3)                       |
| 5 | **VCO-1**        | sine ping (AND)                     |
| 6 | **Noise**        | source for kick + hat               |
| 7 | **VCF**          | hi-pass for hat (use HP out)        |
| 8 | **ADSR** ×5      | one envelope per voice              |
| 9 | **VCA-1** ×5     | one VCA per voice                   |
| 10| **Mixer** (Mixer / VCA Mix 4) | sum the voices         |
| 11| **Audio-8** or **Audio-2** | output to soundcard       |
| 12| **S&H** (Sample & Hold, in Random) | Bernoulli gate    |
| 13| **Random**       | noise/random voltage source for S&H |
| 14| **WT LFO** or another **LFO** | slow modulation (optional) |

VCV doesn't ship a stock clock-divider or logic-AND in Fundamental. The
substitutions:

- **÷N divisions** → use one **LFO** running at the master rate, plus extra
  LFOs at half / third / quarter / eighth that rate. Sync them by patching the
  master square out into the **SYNC** input of each follower LFO and tuning
  the FREQ knob until you get the ratio you want. Visually they'll feel like
  divisions even though they're really synced sub-oscillators.
- **÷3 AND ÷4 (logic AND)** → use a **VCA-1** in series. Patch ÷3 gate into
  the audio in, ÷4 gate into the CV in. Output is high only when both are
  high — that's a multiplicative AND for unipolar gates.
- **Bernoulli gate** → one **S&H** sampling **Random** noise; compare it
  against a knob using a second **VCA-1** as a threshold gate (pulse → audio
  in, S&H output → CV in, knob attenuation = probability). Imperfect (it's
  amplitude-based, not boolean) but works for most pulses.

## Patching steps

1. **Master pulse** — LFO #1: rate ~2 Hz, square out → mult (right-click → "Add
   stack"). One copy goes everywhere a "pulse" is needed.
2. **Divisions** — LFOs #2–#5: square out of LFO #1 → SYNC of each follower.
   Tune their FREQ knobs to ÷2, ÷3, ÷4, ÷8 of the master. Each follower's
   square out is a "÷N" trigger.
3. **AND (÷3 AND ÷4)** — VCA-1: ÷3 sq → IN, ÷4 sq → CV. OUT is your AND gate.
4. **Bernoulli on ÷4** — S&H: Random's noise → IN, ÷4 sq → TRIG. Now the S&H
   output steps to a new random voltage on every ÷4. Then VCA-1: ÷4 sq → IN,
   S&H out → CV, attenuate CV with the LEVEL knob to set probability.
5. **Voices** — for each of the 5 trigger streams, repeat:
   trigger → ADSR GATE; ADSR OUT → VCA-1 CV; source → VCA-1 IN.
   - ÷2 thump: VCO-1 saw, ~70 Hz, ADSR (A 0, D 0.2, S 0, R 0.05).
   - ÷3 blip: VCO-1 sin, ~320 Hz, ADSR (A 0, D 0.09, S 0, R 0).
   - ÷4 (Bernoulli) kick: Noise white, ADSR (A 0, D 0.05, S 0, R 0).
   - ÷8 hat: Noise → VCF (HP out, fc ~6 kHz), ADSR (A 0, D 0.03, S 0, R 0).
   - AND ping: VCO-1 sin, ~440 Hz, ADSR (A 0, D 0.25, S 0, R 0).
6. **Mix** — each VCA OUT → Mixer channel. Mixer OUT → Audio module L/R.
7. **(optional) macro modulation** — slow LFO (rate 0.05 Hz) → one of the
   8vert inputs → fan it out to: probability VCA's CV mixer, ÷N follower LFO
   FM inputs. One slow knob controls the whole feel.

## What's missing vs. Plugdata version

- True clock divider with phase-locked outputs. The synced-LFO trick drifts a
  little and isn't perfectly integer-divided. For exact divisions you need
  a 3rd-party module like **Bogaudio CLKD** or **Impromptu Clocked**.
- Boolean logic. The VCA trick works for unipolar gates but isn't true logic.
  3rd-party **Bogaudio LGSW** or **Count Modula Logic** give you real AND/OR/XOR.
- A real Bernoulli gate (random pass/block per pulse). 3rd-party **Bogaudio
  POLY** "Bool" or **Frozen Wasteland** has this. The S&H+VCA approximation
  here gives you variable probability but the "block" is amplitude-attenuation,
  not a hard reject.

If you decide later that you can use 3rd-party modules, `Bogaudio` is free,
official-feeling, and fills every gap above.
