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
