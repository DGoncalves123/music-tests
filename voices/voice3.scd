// voices/voice3.scd — SLOT 3 — blip
// Edit the SynthDef, Cmd+Enter on the block to hot-swap it while rhythm runs.

(
SynthDef(\blip, { |out = 0, amp = 0.3, pan = 0, freq = 320, rel = 0.09, cutoff = 2400|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.002, rel), doneAction: 2);
    sig = Pulse.ar(freq, 0.4);
    sig = RLPF.ar(sig, cutoff, 0.4);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
"blip loaded".postln;
)

// Synth(\blip);
// Synth(\blip, [\freq, 220, \cutoff, 1500]);
// Synth(\blip, [\freq, 880, \rel, 0.3, \cutoff, 4000]);
