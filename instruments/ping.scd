SynthDef(\ping, { |out = 0, amp = 0.3, pan = 0, freq = 440, rel = 0.3|
    var env, sig;
    env = EnvGen.kr(Env.perc(0.002, rel), doneAction: 2);
    sig = SinOsc.ar(freq) + (SinOsc.ar(freq * 2) * 0.3);
    sig = sig * env * amp;
    Out.ar(out, Pan2.ar(sig, pan));
}).add;
