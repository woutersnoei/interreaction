// inter Part C

~inter = ~inter ? EM();

~inter.start_C = { |evt, index, duration|
	var buffer, fork;
	if( duration.isNil ) {
		index = index ? evt.currentIndex;
		duration = evt.score[ index ][1];
	};
	fork = {	
		var time = 0, waitTime;
		while { time < (duration - 5) } {	 
			Synth( "inter_pulsenoise_C", [ \amp, evt.amp_C ] );
			waitTime = 2.0 rrand: 10.0;
			waitTime.wait;
			time = time + waitTime;
		};
		evt.forks_C.remove( fork );
	}.fork;
	evt.forks_C = evt.forks_C.add( fork );
};

~inter.end_C = { |evt|
	evt.forks_C.do(_.stop);
	RootNode(s).set( \global_gate, 0 );
	evt.forks_C = nil;
};

~inter.amp_C = 0.05;

(
SynthDef( "inter_pulsenoise_C", { |amp = 0.1, sustain = 8, global_gate = 1|
	var sig;
	sig = PinkNoise.ar(0.33.dup) + GrayNoise.ar(0.33.dup);
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.1).exprange( 100, 5000 ), 4 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.1).exprange( 500, 20000 ), 4 );
	sig = sig * LFPulse.kr( 
		LFDNoise1.kr( 0.2.dup ).linexp( -1, 1, 2.5, 20 ),
		Rand(0,1),
		LFDNoise1.kr( 0.2.dup ).linlin( -1, 1, 0.1, 0.9 ),
	) //.lag( *LFDNoise1.kr(0.1.dup).range(-0.2,0.05).max(0) )
		.range(0,1);
	sig = sig * Pan2.kr(DC.kr(1),Rand(-1,1));
	sig = sig * Env([0,1,0],[0.5,0.5] * sustain, [2,-2] ).kr(2);
	sig = sig * Env.cutoff.kr(2,global_gate);
	Out.ar( 0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 14 );
~inter.start_C( 14 );
)

~inter.start_C( 14, inf );

~inter.end_C();

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