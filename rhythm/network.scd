// ─────────────────────────────────────────────────────────────────────────────
// LEFT PANEL — RHYTHM
// Design when things fire. Evaluate blocks top to bottom to start the network.
// Hot-swap any block mid-session: change values, Cmd+Enter inside the ( ), done.
// All controls (freeze, mute, tempo) are in utilities/control.scd (middle panel).
// Slots: voice1=kick  voice2=thump  voice3=blip  voice4=hat  voice5=ping
// ─────────────────────────────────────────────────────────────────────────────

// ── Tempo ────────────────────────────────────────────────────────────────────
(TempoClock.default.tempo = 120/60;)


// ══════════════════════════════════════════════════════════════════════════════
// KICK  (voice1)
// ══════════════════════════════════════════════════════════════════════════════

// -- Bernoulli probability (default) ------------------------------------------
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

// -- Four-on-the-floor --------------------------------------------------------
// (
// ~live[\kick] = {
//     Pbind(
//         \instrument, \kick,
//         \dur, 1,
//         \freq, 55,
//         \amp, 0.7,
//     )
// };
// Pdef(\kick, ~live[\kick].value).play;
// )

// -- Euclidean (5 hits in 8 steps) --------------------------------------------
// (
// ~live[\kick] = {
//     var hits = Bjorklund(5, 8);   // [1,0,1,0,1,0,1,0,...] — requires JITLib
//     Pbind(
//         \instrument, \kick,
//         \dur, 0.5,
//         \amp, Pseq(hits.collect({ |h| h * 0.7 }), inf),
//     )
// };
// Pdef(\kick, ~live[\kick].value).play;
// )


// ══════════════════════════════════════════════════════════════════════════════
// THUMP  (voice2)
// ══════════════════════════════════════════════════════════════════════════════

// -- Wandering half-note grid (default) ---------------------------------------
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

// -- Steady half-notes --------------------------------------------------------
// (
// ~live[\thump] = {
//     Pbind(
//         \instrument, \thump,
//         \dur, 2,
//         \freq, 70,
//         \amp,  0.4,
//         \rel,  0.3,
//     )
// };
// Pdef(\thump, ~live[\thump].value).play;
// )

// -- Pitched sequence (bassline-ish) ------------------------------------------
// (
// ~live[\thump] = {
//     Pbind(
//         \instrument, \thump,
//         \dur, Pseq(#[1, 1, 0.5, 0.5], inf),
//         \freq, Pseq(#[55, 55, 70, 82], inf),
//         \amp,  0.45,
//         \rel,  0.25,
//     )
// };
// Pdef(\thump, ~live[\thump].value).play;
// )


// ══════════════════════════════════════════════════════════════════════════════
// BLIP  (voice3)
// ══════════════════════════════════════════════════════════════════════════════

// -- 3-against grid, random pitch (default) -----------------------------------
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

// -- Steady 8th-notes, fixed pitch --------------------------------------------
// (
// ~live[\blip] = {
//     Pbind(
//         \instrument, \blip,
//         \dur, 0.5,
//         \freq, 320,
//         \cutoff, 2000,
//         \amp, 0.25,
//     )
// };
// Pdef(\blip, ~live[\blip].value).play;
// )

// -- Random bursts (density controlled) --------------------------------------
// (
// ~blipDensity = 0.5;   // 0.0–1.0
// ~live[\blip] = {
//     Pbind(
//         \instrument, \blip,
//         \dur, Pfunc({
//             var d = if(1.0.rand < ~blipDensity, { 0.25 }, { 0.75 });
//             ~push.(\blip, (instrument: \blip, dur: d, freq: #[280,320,380,420].choose, amp: 0.3));
//             d
//         }),
//         \freq, Pwhite(200, 500),
//         \amp, 0.3,
//     )
// };
// Pdef(\blip, ~live[\blip].value).play;
// )


// ══════════════════════════════════════════════════════════════════════════════
// HAT  (voice4)
// ══════════════════════════════════════════════════════════════════════════════

// -- 16th-note shuffle with velocity accents (default) ------------------------
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

// -- Straight 8ths, open feel -------------------------------------------------
// (
// ~live[\hat] = {
//     Pbind(
//         \instrument, \hat,
//         \dur, 0.5,
//         \amp, Pseq(#[0.2, 0.1, 0.2, 0.1, 0.2, 0.1, 0.2, 0.1], inf),
//         \rel, 0.12,
//         \hp,  6000,
//     )
// };
// Pdef(\hat, ~live[\hat].value).play;
// )

// -- Probabilistic skips (sparse hi-hat) -------------------------------------
// (
// ~live[\hat] = {
//     Pbind(
//         \instrument, \hat,
//         \dur, 1/4,
//         \amp, Pfunc({
//             var a = if(0.6.coin, { rrand(0.1, 0.25) }, { 0 });
//             ~push.(\hat, (instrument: \hat, dur: 0.25, amp: a, rel: 0.05, hp: 7000));
//             a
//         }),
//         \rel, 0.05,
//         \hp,  7000,
//     )
// };
// Pdef(\hat, ~live[\hat].value).play;
// )


// ══════════════════════════════════════════════════════════════════════════════
// PING  (voice5)
// ══════════════════════════════════════════════════════════════════════════════

// -- Sparse coincidence, random pitch (default) -------------------------------
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

// -- Melodic phrase (looped sequence) -----------------------------------------
// (
// ~live[\ping] = {
//     Pbind(
//         \instrument, \ping,
//         \dur, Pseq(#[2, 1, 1, 2, 2], inf),
//         \freq, Pseq(#[440, 550, 495, 330, 660], inf),
//         \rel, 0.4,
//         \amp, 0.28,
//     )
// };
// Pdef(\ping, ~live[\ping].value).play;
// )

// -- Random walk (drifting melody) --------------------------------------------
// (
// ~pingNote = 60;
// ~live[\ping] = {
//     Pbind(
//         \instrument, \ping,
//         \dur, Pwhite(1.0, 4.0),
//         \freq, Pfunc({
//             ~pingNote = (~pingNote + #[-2,-1,0,1,2].choose).clip(48, 84);
//             var f = ~pingNote.midicps;
//             ~push.(\ping, (instrument: \ping, dur: 2, freq: f, rel: 0.4, amp: 0.28));
//             f
//         }),
//         \rel, 0.4,
//         \amp, 0.28,
//     )
// };
// Pdef(\ping, ~live[\ping].value).play;
// )
