// inter Part C

~inter = ~inter ? EM();

~inter.start_C = { |evt, index|
	var duration, buffer, fork;
	index = index ? evt.currentIndex;
	duration = evt.score[ index ][1];
	buffer = evt.bufferArray[index][0];
	fork = {	
		var time = 0, waitTime;
		while { time < (duration - 5) } {	 
			Synth( "inter_pulsenoise_C" );
			waitTime = 2.0 rrand: 8.0;
			waitTime.wait;
			time = time + waitTime;
		};
		evt.forks_C.remove( fork );
	}.fork;
	evt.forks_C = evt.forks_C.add( fork );
};

(
SynthDef( "inter_pulsenoise_C", { |amp = 0.1, sustain = 8|
	var sig;
	sig = PinkNoise.ar(1.0.dup);
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.1).exprange( 100, 5000 ), 3 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.1).exprange( 500, 20000 ), 3 );
	sig = sig * LFPulse.kr( 
		LFDNoise1.kr( 0.2.dup ).linexp( -1, 1, 10, 20 ),
		Rand(0,1),
		LFDNoise1.kr( 0.2.dup ).linlin( -1, 1, 0.2, 0.8 ),
	).range(0,1);
	sig = sig * Pan2.kr(DC.kr(1),Rand(-1,1));
	sig = sig * Env([0,1,0],[0.5,0.5] * sustain, [2,-2] ).kr(2);
	Out.ar( 0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 14 );
~inter.start_C( 14 );
)

(
{
	loop {
		Synth( "inter_tremolo_B", [
			\useInputLevel, 0, // turn level following on/off
			\freqs, (80..120).scramble[..9].sort.midicps 
		] );
		(2.0 rrand: 8.0).wait;
	};	
}.fork;
)
*/