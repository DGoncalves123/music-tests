// voices/kick.scd — design the KICK in isolation.
//
// Workflow:
//   1. Edit the SynthDef. Cmd+Return on the block to reload it.
//      The running rhythm picks up the new version on the next trigger.
//   2. Solo it from rhythm: ~solo.(\kick);   ~unsolo.();
//   3. Trigger one-shots from this file to test without the rhythm running.

// ── The instrument ──────────────────────────────────────────────────────
(
SynthDef(\kick, { |out = 0, amp = 0.6, pan = 0,
                  freq = 60, click = 0.02, body = 0.18, tone = 1500|
    var env, pitchEnv, sig, noise;
    env = EnvGen.kr(Env.perc(0.001, body), doneAction: 2);
    pitchEnv = EnvGen.kr(Env([4, 1], [click], \exp));
    sig = SinOsc.ar(freq * pitchEnv);
    noise = HPF.ar(WhiteNoise.ar, tone) * EnvGen.kr(Env.perc(0.0, click));
    sig = (sig + noise) * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// ── Playground (Cmd+Return on individual lines) ─────────────────────────
// Synth(\kick);
// Synth(\kick, [\freq, 45, \body, 0.3]);
// Synth(\kick, [\freq, 80, \click, 0.005, \tone, 3000]);
// Synth(\kick, [\body, 0.4, \tone, 800]);

// Loop a kick at 4 Hz to audition while you tweak the SynthDef:
// (
// ~kickTest = Routine({ loop { Synth(\kick); 0.25.wait } }).play;
// )
// ~kickTest.stop;
