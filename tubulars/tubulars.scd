// Generative tubular bell experiment

~size = 100;

Server.default.waitForBoot{

	SynthDef(\tubularBell, {
		var centerFreq, fb, sig, env, sub;
		centerFreq = \freq.ir(440);

		fb = InFeedback.ar(\in.ir(0), 2);
		fb = AllpassC.ar(PitchShift.ar(fb[0], 0.1, LFNoise1.kr(0.05).range(-2.0, 2.0))
			* \feedback.ir(0), 0.2, LFNoise1.kr(0.05).range(0.001, 0.2));

		sig = Array.fill(~size, {
			| index |
			SinOsc.ar((index+1) * centerFreq + LFNoise1.kr(0.05).range(-100, 100))  * (1/(index+1));
		});
		sub = LFTri.ar(\freq.ir / 4).tanh;
		env = Env([0, 1, 0], [\atk.ir(0.001), \rel.ir(4)], \curve.ir(-10)).kr;

		sig = sig.sum + fb + sub;
		sig = LPF.ar(sig, \filterfreq.ir(1000));
		sig = Normalizer.ar(sig, 1.0);
		sig = sig * env * \amp.ir(1);
		sig = Pan2.ar(sig, \panpos.ir(0));
		DetectSilence.ar(sig, 0.00001, 0.3, 2);
		Out.ar(\out.ir(0), sig);
	}).add;

	Server.default.sync;

	Pbindef(\sequencer,
		\instrument, \tubularBell,
		\feedback, Pwhite(0.0, 50.0),
		\freq, Pxrand(([ 48, 55, 60 ]+12), inf).midicps,
		\filterfreq, Pkey(\freq, inf) * Pexprand(1.0, 4.0),
		\panpos, Pwhite(-0.2, 0.2),
		\amp, 0.2 + Pexprand(0.1, 0.7, inf),
		\rel, Pexprand(4, 10),
		\dur, 2.0 + {exprand(0.0001, 4)}.value
	).play
}
