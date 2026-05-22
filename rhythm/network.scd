// rhythm/network.scd — PULSE NETWORK + LOOP/FREEZE view.
//
// Run startup.scd first. Then evaluate each (...) block top to bottom.
//
// ─── FREEZE WORKFLOW ────────────────────────────────────────────────────
//
//   1. Evaluate blocks 0 → 6 (infrastructure + each voice).
//   2. Listen. When a rhythm feels right, evaluate ONE of:
//
//        ~freeze.(\kick);     // lock just that voice on its last N steps
//        ~freezeAll.();       // lock the entire network at once
//
//   3. The voice loops its captured steps as a Pseq. No glitch, no restart.
//
//   4. When you want it to evolve again:
//        ~thaw.(\kick);
//        ~thawAll.();
//
// ─── HOW IT WORKS ──────────────────────────────────────────────────────
//
// Every voice records its resolved values (freq, amp, dur …) into a circular
// buffer as it plays. ~freeze schedules a Pdef source-swap to fire at the
// NEXT BAR BOUNDARY — so pressing it slightly early or late doesn't matter.
// At the swap moment, the buffer snapshot is taken (last N steps before the
// bar), and the Pdef source becomes a Pseq of plain per-step Pbinds.
// ~thaw does the same in reverse, also quantised to the bar.
//
// Change ~freezeQuant in block [0] to snap to a different grid:
//   1 = bar  |  0.5 = half-bar  |  2 = 2-bar  |  0 = immediate

// ── 0. Infrastructure ───────────────────────────────────────────────────
(
var n = 8;   // default buffer size (steps captured per voice)
~buf      = Dictionary.new;
~live     = Dictionary.new;
~isFrozen = Dictionary.new;
~voices   = [\kick, \thump, \blip, \hat, \ping];

// ── Quantisation ─────────────────────────────────────────────────────
// ~freezeQuant controls when the Pdef source-swap actually fires.
// SC waits until the next boundary before swapping, so pressing freeze
// slightly early or late still locks cleanly on the bar.
//
//   1   = next bar (4 beats at current tempo)   ← default
//   0.5 = next half-bar
//   2   = next 2-bar boundary
//   0   = immediate (no quantisation)
~freezeQuant = 1;   // in bars; change and re-evaluate block [0] to update

// push one resolved event dict into the circular buffer for this voice
~push = { |name, dict|
    var b = ~buf.at(name.asSymbol);
    if(b.isNil, { b = Array.new(n); ~buf.put(name.asSymbol, b) });
    b = b.add(dict);
    if(b.size > n, { b = b[1..] });
    ~buf.put(name.asSymbol, b);
};

// freeze: schedule a quantised source-swap, snapshot taken at swap time
~freeze = { |name|
    if(~isFrozen.at(name.asSymbol) == true, {
        (name ++ " already frozen").postln;
    }, {
        var beatsPerBar = TempoClock.default.beatsPerBar;
        var quantBeats  = ~freezeQuant * beatsPerBar;
        TempoClock.default.schedAbs(
            TempoClock.default.nextTimeOnGrid(quantBeats),
            {
                var b = ~buf.at(name.asSymbol);
                if(b.isNil || b.isEmpty, {
                    ("freeze: no data yet for " ++ name).postln;
                }, {
                    var snap = b.copy;
                    ~isFrozen.put(name.asSymbol, true);
                    Pdef(name.asSymbol,
                        Pseq(
                            snap.collect({ |ev|
                                Pbind(*ev.asSortedArray.flatten)
                            }),
                            inf
                        )
                    );
                    ("FROZEN " ++ name ++ " [" ++ snap.size ++ " steps]").postln;
                });
                nil  // don't reschedule
            }
        );
        ("freeze scheduled for next bar: " ++ name).postln;
    });
};

~thaw = { |name|
    var fn = ~live.at(name.asSymbol);
    if(fn.isNil, {
        ("thaw: no live fn for " ++ name).postln;
    }, {
        var beatsPerBar = TempoClock.default.beatsPerBar;
        var quantBeats  = ~freezeQuant * beatsPerBar;
        TempoClock.default.schedAbs(
            TempoClock.default.nextTimeOnGrid(quantBeats),
            {
                ~isFrozen.put(name.asSymbol, false);
                Pdef(name.asSymbol, fn.value);
                ("LIVE " ++ name).postln;
                nil
            }
        );
        ("thaw scheduled for next bar: " ++ name).postln;
    });
};

~freezeAll = { ~voices.do({ |v| ~freeze.(v) }) };
~thawAll   = { ~voices.do({ |v| ~thaw.(v)   }) };

// mute / solo (kept from startup.scd, safe to re-define)
~mute   = { |name| Pdef(name).stop;  ("muted: "   ++ name).postln };
~unmute = { |name| Pdef(name).play;  ("unmuted: " ++ name).postln };
~solo   = { |name|
    ~voices.do({ |v| if(v != name, { Pdef(v).stop }) });
    Pdef(name).play;
    ("solo: " ++ name).postln;
};
~unsolo = { ~voices.do({ |v| Pdef(v).play }); "all voices on".postln };

"[0] Infrastructure ready.".postln;
)

// ── 1. Tempo ─────────────────────────────────────────────────────────────
// Re-evaluate just this line anytime to change tempo while running.
(TempoClock.default.tempo = 120/60;)

// ── 2. ÷2 THUMP ──────────────────────────────────────────────────────────
(
~live[\thump] = {
    Pbind(
        \instrument, \thump,
        \dur,  Pfunc({ |ev|
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
"[2] thump loaded".postln;
)

// ── 3. ÷3 BLIP ───────────────────────────────────────────────────────────
(
~live[\blip] = {
    Pbind(
        \instrument, \blip,
        \dur, 3/4,
        \freq, Pfunc({
            var freqs = #[280, 320, 380, 420];
            var f = freqs.choose;
            var c = rrand(1200, 3000);
            ~push.(\blip, (instrument: \blip, dur: 0.75, freq: f, cutoff: c, amp: 0.3));
            f
        }),
        \cutoff, Pwhite(1200, 3000),
        \amp,    0.3,
    )
};
Pdef(\blip, ~live[\blip].value).play;
"[3] blip loaded".postln;
)

// ── 4. ÷4 KICK — Bernoulli probability ──────────────────────────────────
(
~kickProb = 0.7;  // 0.0–1.0; change this line and re-evaluate the block
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
"[4] kick loaded  (~kickProb = " ++ ~kickProb ++ ")".postln;
)

// ── 5. ÷8 HAT ────────────────────────────────────────────────────────────
(
~live[\hat] = {
    Pbind(
        \instrument, \hat,
        \dur, 1/4,
        \amp, Pfunc({
            var amps = #[0.25, 0.08, 0.18, 0.08, 0.22, 0.08, 0.15, 0.08];
            var a  = amps.choose;
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
"[5] hat loaded".postln;
)

// ── 6. AND PING — sparse coincidence ─────────────────────────────────────
(
~live[\ping] = {
    Pbind(
        \instrument, \ping,
        \dur, 3,
        \freq, Pfunc({
            var freqs = #[330, 440, 550, 660];
            var f = freqs.choose;
            var r = rrand(0.2, 0.6);
            ~push.(\ping, (instrument: \ping, dur: 3, freq: f, rel: r, amp: 0.3));
            f
        }),
        \rel, Pwhite(0.2, 0.6),
        \amp, 0.3,
    )
};
Pdef(\ping, ~live[\ping].value).play;
"[6] ping loaded".postln;
)

// ═══════════════════════════════════════════════════════════════════════════
// FREEZE / THAW CONTROLS
// Put your cursor on any line and Cmd+Return to evaluate just that line.
// ═══════════════════════════════════════════════════════════════════════════

// -- Freeze one voice on its last 8 steps:
// ~freeze.(\kick);
// ~freeze.(\hat);
// ~freeze.(\blip);
// ~freeze.(\thump);
// ~freeze.(\ping);

// -- Freeze everything at once:
// ~freezeAll.();

// -- Thaw (back to evolving):
// ~thaw.(\kick);
// ~thawAll.();

// -- Adjust kick probability while live (thaw first if frozen):
// ~kickProb = 0.4;   // sparse
// ~kickProb = 0.9;   // dense
// ~thaw.(\kick);     // re-apply if it was frozen

// -- Tempo:
// TempoClock.default.tempo = 140/60;
// TempoClock.default.tempo = 90/60;

// -- Mute / solo:
// ~solo.(\hat);
// ~unsolo.();
// ~mute.(\kick);  ~unmute.(\kick);

// -- Stop all:
// ~voices.do({ |v| Pdef(v).stop });
