// ─────────────────────────────────────────────────────────────────────────────
// MIDDLE PANEL — UTILITIES / CONTROL
// Operate on the running network. Put cursor on any line, Cmd+Enter to fire it.
// Nothing here defines patterns or instruments — only controls the system.
// ─────────────────────────────────────────────────────────────────────────────

// ════════════════════════════════════════════════════════════════════════════
// TEMPO
// ════════════════════════════════════════════════════════════════════════════

(TempoClock.default.tempo = 120/60;)   // 120 BPM
(TempoClock.default.tempo = 140/60;)   // 140 BPM
(TempoClock.default.tempo = 90/60;)    //  90 BPM
// Custom — change the number and Cmd+Enter:
(TempoClock.default.tempo = 120/60;)


// ════════════════════════════════════════════════════════════════════════════
// FREEZE / THAW
// Freeze captures the last ~8 steps and loops them, quantised to the next bar.
// You'll see "freeze scheduled" then "FROZEN" in the post window.
// ════════════════════════════════════════════════════════════════════════════

// -- Snap grid (bars). Change and re-evaluate startup.scd block [0] to apply.
(~freezeQuant = 1;)    // next bar  ← default
(~freezeQuant = 2;)    // next 2-bar phrase
(~freezeQuant = 0.5;)  // next half-bar

// -- Freeze individual voices:
~freeze.(\thump);
~freeze.(\blip);
~freeze.(\kick);
~freeze.(\hat);
~freeze.(\ping);

// -- Freeze everything at once:
~freezeAll.();

// -- Thaw individual voices (back to evolving):
~thaw.(\thump);
~thaw.(\blip);
~thaw.(\kick);
~thaw.(\hat);
~thaw.(\ping);

// -- Thaw everything:
~thawAll.();


// ════════════════════════════════════════════════════════════════════════════
// MUTE / UNMUTE
// ════════════════════════════════════════════════════════════════════════════

~mute.(\thump);    ~unmute.(\thump);
~mute.(\blip);     ~unmute.(\blip);
~mute.(\kick);     ~unmute.(\kick);
~mute.(\hat);      ~unmute.(\hat);
~mute.(\ping);     ~unmute.(\ping);


// ════════════════════════════════════════════════════════════════════════════
// SOLO
// ════════════════════════════════════════════════════════════════════════════

~solo.(\thump);
~solo.(\blip);
~solo.(\kick);
~solo.(\hat);
~solo.(\ping);

// Back to all voices:
~unsolo.();


// ════════════════════════════════════════════════════════════════════════════
// KICK PROBABILITY  (0.0 = never fires  →  1.0 = always fires)
// Change the number and Cmd+Enter on that line. Thaw kick first if frozen.
// ════════════════════════════════════════════════════════════════════════════

(~kickProb = 0.7;)   // default
(~kickProb = 0.3;)   // sparse
(~kickProb = 1.0;)   // locked on
(~kickProb = 0.0;)   // muted via probability


// ════════════════════════════════════════════════════════════════════════════
// STOP / RESTART
// ════════════════════════════════════════════════════════════════════════════

// Stop one voice:
Pdef(\thump).stop;
Pdef(\blip).stop;
Pdef(\kick).stop;
Pdef(\hat).stop;
Pdef(\ping).stop;

// Stop everything:
(~voices.do({ |v| Pdef(v).stop });)

// Restart everything (voices must be defined in network.scd first):
(~voices.do({ |v| Pdef(v).play });)

// Full panic — stops all synths on the server immediately:
CmdPeriod.run;
