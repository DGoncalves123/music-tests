// ─────────────────────────────────────────────────────────────────────────────
// LEFT PANEL — RHYTHM
// Design when things fire. Evaluate blocks top to bottom to start the network.
// Hot-swap any block mid-session: change values, Cmd+Enter inside the ( ), done.
// All controls (freeze, mute, tempo) are in utilities/control.scd (middle panel).
// ─────────────────────────────────────────────────────────────────────────────

// ── Tempo ────────────────────────────────────────────────────────────────────
// Re-evaluate this line alone anytime to change BPM while running.
(TempoClock.default.tempo = 120/60;)

// ── ÷2 THUMP — half-note grid ────────────────────────────────────────────────
(
~live[\thump] = {
    Pbind(
        \instrument, \thump,
        \dur, Pfunc({
            var d = #[0.5, 0.5, 0.5, 1.0].choose;
            ~push.(\thump, (instrument: \thump, dur: d, freq: 70, amp: 0.4, rel: 0.2));
            d
        }),
        \freq, 70,
        \amp,  0.4,
        \rel,  0.2,
    )
};
Pdef(\thump, ~live[\thump].value).play;
"[rhythm] thump loaded".postln;
)

// ── ÷3 BLIP — 3-against grid ─────────────────────────────────────────────────
(
~live[\blip] = {
    Pbind(
        \instrument, \blip,
        \dur, 3/4,
        \freq, Pfunc({
            var f = #[280, 320, 380, 420].choose;
            var c = rrand(1200, 3000);
            ~push.(\blip, (instrument: \blip, dur: 0.75, freq: f, cutoff: c, amp: 0.3));
            f
        }),
        \cutoff, Pwhite(1200, 3000),
        \amp,    0.3,
    )
};
Pdef(\blip, ~live[\blip].value).play;
"[rhythm] blip loaded".postln;
)

// ── ÷4 KICK — Bernoulli probability ──────────────────────────────────────────
// Change ~kickProb in utilities/control.scd, or change it here and re-evaluate.
(
~kickProb = 0.7;
~live[\kick] = {
    Pbind(
        \instrument, \kick,
        \dur, 1,
        \freq, 55,
        \amp, Pfunc({
            var a = if(1.0.rand < ~kickProb, { 0.7 }, { 0 });
            ~push.(\kick, (instrument: \kick, dur: 1, freq: 55, amp: a));
            a
        }),
    )
};
Pdef(\kick, ~live[\kick].value).play;
"[rhythm] kick loaded".postln;
)

// ── ÷8 HAT — 16th-note ticks ─────────────────────────────────────────────────
(
~live[\hat] = {
    Pbind(
        \instrument, \hat,
        \dur, 1/4,
        \amp, Pfunc({
            var a  = #[0.25, 0.08, 0.18, 0.08, 0.22, 0.08, 0.15, 0.08].choose;
            var r  = rrand(0.03, 0.09);
            var hp = rrand(5000, 9000).asInteger;
            ~push.(\hat, (instrument: \hat, dur: 0.25, amp: a, rel: r, hp: hp));
            a
        }),
        \rel, Pwhite(0.03, 0.09),
        \hp,  Pwhite(5000, 9000),
    )
};
Pdef(\hat, ~live[\hat].value).play;
"[rhythm] hat loaded".postln;
)

// ── AND PING — sparse coincidence ────────────────────────────────────────────
(
~live[\ping] = {
    Pbind(
        \instrument, \ping,
        \dur, 3,
        \freq, Pfunc({
            var f = #[330, 440, 550, 660].choose;
            var r = rrand(0.2, 0.6);
            ~push.(\ping, (instrument: \ping, dur: 3, freq: f, rel: r, amp: 0.3));
            f
        }),
        \rel, Pwhite(0.2, 0.6),
        \amp, 0.3,
    )
};
Pdef(\ping, ~live[\ping].value).play;
"[rhythm] ping loaded".postln;
)
