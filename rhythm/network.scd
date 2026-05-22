// rhythm/network.scd — the PULSE NETWORK view.
//
// Run startup.scd first. Then evaluate each (...) block below to load /
// hot-swap that voice's pattern. Pdefs are named, so re-evaluating a block
// updates that voice without stopping anything else.

// ── 0. Master tempo ─────────────────────────────────────────────────────
// (TempoClock.default.tempo = 130/60;)   // 130 BPM

// ── 1. Heartbeat: the steady ÷1 pulse (drives the thump) ────────────────
// ÷2 thump — every other 8th note.
(
Pdef(\thump,
    Pbind(
        \instrument, \thump,
        \dur, 1/2,             // half-note grid
        \freq, 70,
        \amp, 0.4,
    )
).play;
)

// ── 2. ÷3 blip — tied to a 3-against grid ───────────────────────────────
(
Pdef(\blip,
    Pbind(
        \instrument, \blip,
        \dur, 3/4,             // dotted half — feels like ÷3 against ÷2
        \freq, Pseq([320, 380, 280], inf),
        \cutoff, Pwhite(1200, 3000),
        \amp, 0.3,
    )
).play;
)

// ── 3. ÷4 kick — gated by Bernoulli probability ─────────────────────────
// Pfunc returns \rest some of the time, dropping that step.
(
~kickProb = 0.7;  // 0..1 — re-evaluate this line then the block to update
Pdef(\kick,
    Pbind(
        \instrument, \kick,
        \dur, 1,                                            // ÷4 grid (quarter notes)
        \freq, 55,
        \amp, Pfunc({ if(1.0.rand < ~kickProb, { 0.7 }, { 0 }) }),
    )
).play;
)

// ── 4. ÷8 hat — fast ticks ──────────────────────────────────────────────
(
Pdef(\hat,
    Pbind(
        \instrument, \hat,
        \dur, 1/4,             // 16th notes
        \amp, Pseq([0.25, 0.12, 0.18, 0.12], inf),  // simple accent pattern
    )
).play;
)

// ── 5. AND ping — the coincidence trigger ───────────────────────────────
// Plugdata version: fires when ÷3 AND ÷4 align (every 12 steps).
// Here: a ping every 3 bars (LCM-style coincidence).
(
Pdef(\ping,
    Pbind(
        \instrument, \ping,
        \dur, 3,
        \freq, Pseq([440, 660, 550], inf),
        \rel, 0.4,
        \amp, 0.3,
    )
).play;
)

// ── Mute / solo controls ────────────────────────────────────────────────
// ~mute.(\kick);
// ~unmute.(\kick);
// ~solo.(\hat);
// ~unsolo.();

// ── Stop everything ─────────────────────────────────────────────────────
// ~voices.do({ |v| Pdef(v).stop });
