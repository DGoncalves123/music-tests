// startup.scd — run this once at the start of every session.
// Cmd+A, Cmd+Enter. Watch the post window for "Ready."
//
// What this does:
//   1. Boots the audio server
//   2. Loads every SynthDef in instruments/
//   3. Defines the freeze/thaw/mute/solo infrastructure
//   4. Sets the master tempo clock
//
// After this: open the 3-panel layout (see README) and start with network.scd.

(
s.waitForBoot({
    var root = thisProcess.nowExecutingPath.dirname;
    var n = 8;  // circular buffer size per voice (steps captured for freeze)

    // ── Load SynthDefs ───────────────────────────────────────────────────
    PathName(root +/+ "instruments").files.do({ |f|
        if(f.extension == "scd", {
            ("loading: " ++ f.fileName).postln;
            f.fullPath.load;
        });
    });
    s.sync;

    // ── Voice list ───────────────────────────────────────────────────────
    ~voices = [\kick, \thump, \blip, \hat, \ping];

    // ── Freeze infrastructure ────────────────────────────────────────────
    ~buf      = Dictionary.new;
    ~live     = Dictionary.new;
    ~isFrozen = Dictionary.new;
    ~freezeQuant = 1;  // bars — change in utilities/control.scd

    ~push = { |name, dict|
        var b = ~buf.at(name.asSymbol);
        if(b.isNil, { b = Array.new(n); ~buf.put(name.asSymbol, b) });
        b = b.add(dict);
        if(b.size > n, { b = b[1..] });
        ~buf.put(name.asSymbol, b);
    };

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
                            Pseq(snap.collect({ |ev| Pbind(*ev.asSortedArray.flatten) }), inf)
                        );
                        ("FROZEN " ++ name ++ " [" ++ snap.size ++ " steps]").postln;
                    });
                    nil
                }
            );
            ("freeze scheduled → next bar: " ++ name).postln;
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
            ("thaw scheduled → next bar: " ++ name).postln;
        });
    };

    ~freezeAll = { ~voices.do({ |v| ~freeze.(v) }) };
    ~thawAll   = { ~voices.do({ |v| ~thaw.(v)   }) };

    // ── Mute / solo ──────────────────────────────────────────────────────
    ~mute   = { |name| Pdef(name).stop;  ("muted: "   ++ name).postln };
    ~unmute = { |name| Pdef(name).play;  ("unmuted: " ++ name).postln };

    ~solo = { |name|
        ~voices.do({ |v| if(v != name, { Pdef(v).stop }) });
        Pdef(name).play;
        ("solo: " ++ name).postln;
    };
    ~unsolo = { ~voices.do({ |v| Pdef(v).play }); "all voices on".postln };

    // ── Master tempo ─────────────────────────────────────────────────────
    TempoClock.default.tempo = 120/60;

    "".postln;
    "── Ready ──────────────────────────────────────────────────────".postln;
    "  Left   → rhythm/network.scd    (pattern design)".postln;
    "  Middle → utilities/control.scd (freeze / mute / tempo)".postln;
    "  Right  → voices/<name>.scd     (sound design)".postln;
    "────────────────────────────────────────────────────────────────".postln;
});
)
