// inter Part E

~inter = ~inter ? EM();

~inter.start_E = { |evt, index|
	var duration, buffer, fork;
	index = index ? evt.currentIndex;
	duration = evt.score[ index ][1];
	buffer = evt.bufferArray[index][0];
	fork = {	
		0.25.wait;
		3.do({ |i|
			evt.synths_E = evt.synths_E.addAll(
				2.collect({
					Synth( "inter_slow_fwd_A", [ 
						\buf, buffer, 
						\startFrame, evt.bufferArray[index][1],
						\sustain, duration - 0.25 - (3 * i),
					] ).onFree({ |synth| evt.synths_E.remove( synth ) })
				})
			);
			3.wait;
		});
		evt.forks_E.remove( fork );
	}.fork;
	evt.forks_E = evt.forks_E.add( fork );
};

(
SynthDef( "inter_slow_fwd_E", { |buf = 0, startFrame = 0, fadeTime = 15, amp = 0.5, sustain = 1, gate = 1|
	var sig;
	var pos;
	var env;
	var env2;
	pos = Sweep.ar( 0, SampleRate.ir ) + startFrame;
	sig = PlayBufCF.ar( 2, buf, 
		Drand( (9..1) / (10..2), inf ), // rate
		Dwhite( 3, 10 ), // trigger
		Dwhite( 0, pos ),
		0, 3
	);
	sig = XFade2.ar( sig[0], sig[1], LFDNoise1.kr(0.1) ); 
	sig = BLowCut.ar( sig, XLine.kr( 10000, 150, fadeTime ), 3 );
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.2).exprange( 100, 10000 ), 3 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.2).exprange( 200, 20000 ), 3 );
	sig = RoundPan.ar( 2, sig, LFDNoise1.kr(0.2), speakerRadius: 1 );
	env = Env.asr(0.1,1,0.1).kr(2, gate);
	env2 = Env([1,1,0],[sustain, 4],\lin).kr(2);
	sig = BHiCut.ar( sig, env2.linexp(0,1,20,20000), 3 ) * env2;
	Out.ar( 0, sig * amp * env );
}).load(s);
);

/*
(
~inter.recordBufferForIndex( 2 );
~inter.start_E( 2 );
)

~inter.synths_A

(
{ 
	var index = 0;
	~inter.recordBufferForIndex( index );
	d = 2.collect({
		Synth( "inter_slow_fwd_A", [ 
			\buf, ~inter.bufferArray[index][0], 
			\startFrame, ~inter.bufferArray[index][1],
			\sustain, ~inter.score[index][1]
		] );
	});
	5.wait;
	e =  Synth( "inter_slow_bwd_A", [ 
		\buf, ~inter.bufferArray[index][0], 
		\startFrame, ~inter.bufferArray[index][1],
		\sustain, ~inter.score[index][1] - 5
	] );
}.fork;
)
*/

