SynthDef(\thump, { |out = 0, amp = 0.4, pan = 0, freq = 70, rel = 0.2|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.005, rel), doneAction: 2);
    sig = SinOsc.ar(freq) + (LFTri.ar(freq * 2) * 0.2);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
