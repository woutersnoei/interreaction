// inter Part J

~inter = ~inter ? EM();

~inter.start_J = { |evt, index|
	var duration, buffers, fork;
	index = index ? evt.currentIndex;
	duration = evt.score[ index ][1];
	buffers = evt.bufferArray.select({ |item, i|
		(i != index) && {
			item[1] > 0
		};
	}).collect(_[0]);
	if( buffers.size > 0 ) {
		fork = {	
			var time = 0, waitTime;
			while { time < (duration - 8) } {	 
				Synth( "inter_otherpart_J", [ 
					\buf, buffers.choose,
					\sustain, 10 rrand: 14
				]);
				waitTime = 1.0 exprand: 5.0;
				waitTime.wait;
				time = time + waitTime;
			};
			evt.forks_J.remove( fork );
		}.fork;
		evt.forks_J = evt.forks_J.add( fork );
	};
};

(
SynthDef( "inter_otherpart_J", { |amp = 0.5, buf = 0, sustain = 12|
	var sig;
	var rate;
	//rate = (IRand(1,4) * IRand(0,1).linlin(0,1,-1,1)).midiratio;
	//rate = 2 ** IRand(-1,1);
	rate = 2 ** LFDNoise1.kr( 0.1 );
	sig = PlayBufCF.ar( 2, buf, rate, Dwhite(3, 10), 
		Dwhite( 0, BufFrames.kr( buf ) ), 1, 1 );
	sig = XFade2.ar( sig[0], sig[1], LFDNoise1.kr(0.1) ); 
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.3).exprange( 100, 10000 ), 3 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.3).exprange( 200, 20000 ), 3 );
	sig = sig * LFDNoise3.kr(0.3).exprange(0.25,1);
	sig = FreeVerb.ar( sig, LFDNoise1.kr(0.1).clip(0,1), 0.7 );
	sig = RoundPan.ar( 2, sig, LFDNoise1.kr(0.3), speakerRadius: 1 );
	sig = sig * Env( [0,1,0], [0.5,0.5] * sustain, [2,-2] ).kr(2);
	Out.ar( 0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 5 );
~inter.start_J( 5 );
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