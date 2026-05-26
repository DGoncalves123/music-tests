// startup.scd — run once per session.
// Cmd+Shift+Enter (Load File) or Cmd+A → Cmd+Enter.
// Watch the post window for "Ready."

(
s.waitForBoot({
    var root = thisProcess.nowExecutingPath !? { |p| p.dirname }
               ?? { "/Users/diogo.costa/Documents/music-tests" };
    var n = 8;

    ("project root: " ++ root).postln;

    // ── Load all voices (SynthDefs) ──────────────────────────────────────
    PathName(root +/+ "voices").files.do({ |f|
        if(f.extension == "scd" && { f.fileNameWithoutExtension != "template" }, {
            ("loading: " ++ f.fileName).postln;
            f.fullPath.load;
        });
    });
    s.sync;

    // ── Voice slot list — add new slots here when you add voiceN.scd ────
    ~voices = [\kick, \thump, \blip, \hat, \ping];

    // ── Freeze infrastructure ────────────────────────────────────────────
    ~buf      = Dictionary.new;
    ~live     = Dictionary.new;
    ~isFrozen = Dictionary.new;
    ~freezeQuant = 1;

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
            var quantBeats = ~freezeQuant * TempoClock.default.beatsPerBar;
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
            var quantBeats = ~freezeQuant * TempoClock.default.beatsPerBar;
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
    ~solo   = { |name|
        ~voices.do({ |v| if(v != name, { Pdef(v).stop }) });
        Pdef(name).play;
        ("solo: " ++ name).postln;
    };
    ~unsolo = { ~voices.do({ |v| Pdef(v).play }); "all voices on".postln };

    // ── Tempo ────────────────────────────────────────────────────────────
    TempoClock.default.tempo = 120/60;

    "".postln;
    "── Ready ──────────────────────────────────────────────────────────".postln;
    "  Left   →  rhythm/network.scd       pattern design".postln;
    "  Middle →  utilities/control.scd    freeze / mute / tempo".postln;
    "  Right  →  voices/voiceN.scd        sound design per slot".postln;
    "  Voices →  voice1..voice5  (add more in voices/ + ~voices list)".postln;
    "───────────────────────────────────────────────────────────────────".postln;
});
)
