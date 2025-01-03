// Generative evolving drone soundscape

~tuning = [0, 2.251, 4.680, 7.221, 9.29];
Server.default.options.memSize_(2.pow(16));

Server.default.waitForBoot{

	// function to reload SynthDef with different array size
	~reloadSynth = {
		| size = 10 |
		~size = size;
		SynthDef(\string, {
			var freq = \freq.ir(440);
			var ratio = \ratio.ir(2);
			var depth = \depth.ir(0.2);
			var env = Env([0.0, 1.0, 0.0], [\atk.ir(0.001), \rel.ir(2)], -10).kr(2);
			var sig =
			Array.fill(~size, {
				arg i; Saw.ar(freq * (i+1/3)
					+ (SinOsc.kr(ExpRand(100, 1000)).range(
						freq * ratio * -1, freq * ratio) * depth)) * (1/~size).rand});

			sig = LPF.ar(sig,\filterFreq.ir(400) + env.range(\minFilterFreqEnv.ir(-100), \maxFilterFreqEnv.ir(100)));
			sig = sig * env;
			sig = Limiter.ar(sig, 0.8);
			sig = Splay.ar(sig, 1, 1, \panpos.ir(0)) * \amp.ir(1);
			Out.ar(\out.ir(0), sig);
		}).add;
	};

	Server.default.sync;

	~reloadSynth.value;

	Server.default.sync;

	Tdef(\seq, {
		var i = 0;
		var transpose = 0;
		var lpf = 300;
		var octave = 5;
		var waittime = 1;
		var filterFreq = 100;
		loop{
			case
			{i % 1000 < 100}
			{
				~tuning = [0];
				transpose = 7; octave = 0;
				lpf = 5000; waittime = 0.25;
				~reloadSynth.(10);
			}
			{i % 1000 >= 100 && i % 1000 < 200}
			{
				~tuning = [ 0, 2.251, 4.680, 7.221, 9.29];
				transpose = 0;
				octave = 5; lpf = 300;
				~reloadSynth.(5)
			}
			{i % 1000 >= 200 && i % 1000 < 300}
			{
				transpose = 7;
				octave = 2;
				~reloadSynth.(10); lpf = 1000;
				~tuning = [2.251];
			};

			filterFreq = {exprand(100, lpf)}.value;

			Synth.new(\string, [\freq, (~tuning+(12*rrand(octave, 8))+transpose).choose.midicps,
				\atk, 15,
				\rel, 15,
				\amp, {exprand(0.1, 1.0)}.value,
				\minFilterFreqEnv, {exprand(filterFreq/10, filterFreq) * -1},
				\maxFilterFreqEnv, {exprand(filterFreq/10, filterFreq)},
				\ratio, {exprand(0.001, 2)}.value,
				\filterFreq, filterFreq,
				\panpos, {rrand(-1.0, 1.0)}.value]);

			i = i + 1;

			waittime.wait;
		}
	}).play;
}
