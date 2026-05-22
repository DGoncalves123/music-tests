SynthDef(\hat, { |out = 0, amp = 0.25, pan = 0, rel = 0.05, hp = 6000|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.001, rel), doneAction: 2);
    sig = HPF.ar(WhiteNoise.ar, hp);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
