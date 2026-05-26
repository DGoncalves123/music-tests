// voices/template.scd — copy this to voiceN.scd to add a new slot.
// Replace every occurrence of \voiceN with your slot name (e.g. \voice6).
// Then add \voice6 to ~voices in startup.scd and a Pdef block in network.scd.

(
SynthDef(\voiceN, { |out = 0, amp = 0.3, pan = 0, freq = 440, rel = 0.2|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, rel), doneAction: 2);
    sig = SinOsc.ar(freq);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
"voiceN loaded".postln;
)

// Synth(\voiceN);
// Synth(\voiceN, [\freq, 330, \rel, 0.5]);
