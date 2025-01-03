// Generative kick experiment

Server.default.waitForBoot{

	SynthDef(\kick, {
		var ampEnv = Env([0, 1, 0], [\atk.ir(0.001), \rel.ir(0.1)], -10).kr(2);
		var pitchEnv = Env([\freqStart.ir(1000), \freqEnd.ir(0)], [\dur.ir(0.1)], \curve.ir(-10)).kr(0);
		var sig = SinOsc.ar(pitchEnv);
		sig = sig.tanh * \distGain.ir(1);
		sig = Normalizer.ar(sig, 1) * ampEnv;
		sig = Pan2.ar(sig, \panPos.ir(0));
		sig =  sig * \amp.ir(1.0);
		Out.ar(\out.ir(0), sig);
	}).add;

	Server.default.latency = 1024 * 6 / Server.default.sampleRate;

	Server.default.sync;

	Tdef(\seq,  {
		var interonset = 0.05;
		inf.do { arg i;

			Server.default.sendBundle( Server.default.latency,
				[
					's_new', \kick,
					-1,				// nodeID
					1,				// addAction
					1,				// targetID
					// synth args
					\panPos, {rrand(-1.0, 1.0)}.value,
					\distGain, {exprand(1.0, 10000)}.value,
					\freqStart, {exprand(100, 10000)}.value,
					\freqEnd, 0,
					\amp, {exprand(0.001, 0.8)}.value,
					\atk, {exprand(0.01, 10.0)}.value,
					\rel, {exprand(0.01, 1.0)}.value
				]
			);
			interonset.wait;
		}
	} ).play;
}