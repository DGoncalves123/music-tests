// ─────────────────────────────────────────────────────────────────────────────
// MIDDLE PANEL — UTILITIES / CONTROL
// Operate on the running network. Put cursor on any line, Cmd+Enter to fire it.
// Nothing here defines patterns or instruments — only controls the system.
// Slots: voice1=kick  voice2=thump  voice3=blip  voice4=hat  voice5=ping
// ─────────────────────────────────────────────────────────────────────────────

// ════════════════════════════════════════════════════════════════════════════
// TEMPO
// ════════════════════════════════════════════════════════════════════════════

(TempoClock.default.tempo = 120/60;)   // 120 BPM
(TempoClock.default.tempo = 140/60;)   // 140 BPM
(TempoClock.default.tempo = 90/60;)    //  90 BPM
(TempoClock.default.tempo = 120/60;)   // custom — change number and Cmd+Enter


// ════════════════════════════════════════════════════════════════════════════
// FREEZE / THAW
// Freeze captures the last ~8 steps and loops them, quantised to the next bar.
// You'll see "freeze scheduled" then "FROZEN" in the post window.
// ════════════════════════════════════════════════════════════════════════════

(~freezeQuant = 1;)    // next bar  ← default
(~freezeQuant = 2;)    // next 2-bar phrase
(~freezeQuant = 0.5;)  // next half-bar

~freeze.(\kick);
~freeze.(\thump);
~freeze.(\blip);
~freeze.(\hat);
~freeze.(\ping);

~freezeAll.();

~thaw.(\kick);
~thaw.(\thump);
~thaw.(\blip);
~thaw.(\hat);
~thaw.(\ping);

~thawAll.();


// ════════════════════════════════════════════════════════════════════════════
// MUTE / UNMUTE
// ════════════════════════════════════════════════════════════════════════════

~mute.(\kick);     ~unmute.(\kick);
~mute.(\thump);    ~unmute.(\thump);
~mute.(\blip);     ~unmute.(\blip);
~mute.(\hat);      ~unmute.(\hat);
~mute.(\ping);     ~unmute.(\ping);


// ════════════════════════════════════════════════════════════════════════════
// SOLO
// ════════════════════════════════════════════════════════════════════════════

~solo.(\kick);
~solo.(\thump);
~solo.(\blip);
~solo.(\hat);
~solo.(\ping);

~unsolo.();


// ════════════════════════════════════════════════════════════════════════════
// KICK PROBABILITY  (0.0 = never fires  →  1.0 = always fires)
// ════════════════════════════════════════════════════════════════════════════

(~kickProb = 0.7;)   // default
(~kickProb = 0.3;)   // sparse
(~kickProb = 1.0;)   // locked on
(~kickProb = 0.0;)   // muted via probability


// ════════════════════════════════════════════════════════════════════════════
// STOP / RESTART
// ════════════════════════════════════════════════════════════════════════════

Pdef(\kick).stop;
Pdef(\thump).stop;
Pdef(\blip).stop;
Pdef(\hat).stop;
Pdef(\ping).stop;

(~voices.do({ |v| Pdef(v).stop });)
(~voices.do({ |v| Pdef(v).play });)

CmdPeriod.run;
