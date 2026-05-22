// voices/hat.scd — design the HAT in isolation.

(
SynthDef(\hat, { |out = 0, amp = 0.25, pan = 0, rel = 0.05, hp = 6000|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.001, rel), doneAction: 2);
    sig = HPF.ar(WhiteNoise.ar, hp);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

// Synth(\hat);
// Synth(\hat, [\rel, 0.15, \hp, 4000]);  // open hat
// Synth(\hat, [\rel, 0.02, \hp, 9000]);  // tight tick
