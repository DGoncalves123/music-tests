// startup.scd — boot the server, load instruments, define helpers.
// Evaluate the whole file: Cmd+A, then Cmd+Return.

(
s.waitForBoot({
    var root = thisProcess.nowExecutingPath.dirname;

    // ── Load every SynthDef in instruments/ ─────────────────────────────
    PathName(root +/+ "instruments").files.do({ |f|
        if(f.extension == "scd", {
            ("Loading instrument: " ++ f.fileName).postln;
            f.fullPath.load;
        });
    });

    s.sync;

    // ── Master tempo ─────────────────────────────────────────────────────
    // Change this BPM and every Pdef on TempoClock.default follows.
    TempoClock.default.tempo = 120 / 60;  // 120 BPM

    // ── Mute / solo helpers ──────────────────────────────────────────────
    // Use from anywhere: ~mute.(\kick);  ~solo.(\hat);  ~unsolo.();
    ~voices = [\kick, \thump, \blip, \hat, \ping];

    ~mute = { |name| Pdef(name).stop; ("muted: " ++ name).postln; };
    ~unmute = { |name| Pdef(name).play; ("unmuted: " ++ name).postln; };

    ~solo = { |name|
        ~voices.do({ |v| if(v != name, { Pdef(v).stop }) });
        Pdef(name).play;
        ("solo: " ++ name).postln;
    };
    ~unsolo = { ~voices.do({ |v| Pdef(v).play }); "all voices on".postln; };

    "── Ready. Server up, instruments loaded. ──".postln;
    "Next: open rhythm/network.scd and evaluate the blocks.".postln;
});
)
