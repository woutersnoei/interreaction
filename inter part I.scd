// inter Part I

~inter = ~inter ? EM();

~inter.start_I = { |evt, index|
	var duration, buffer, fork;
	index = index ? evt.currentIndex;
	duration = evt.score[ index ][1];
	buffer = evt.bufferArray[index][0];
	fork = {	
		0.25.wait;
		evt.synths_I = evt.synths_I.addAll(
			2.collect({
				Synth( "inter_slow_fwd_I", [ 
					\buf, buffer, 
					\startFrame, evt.bufferArray[index][1],
					\sustain, duration - 0.25,
				] ).onFree({ |synth| evt.synths_I.remove( synth ) })
			})
		);
		5.wait;
		evt.synths_I = evt.synths_I.add(
			Synth( "inter_slow_bwd_I", [ 
				\buf, buffer, 
				\startFrame, evt.bufferArray[index][1],
				\sustain, duration - 5.25,
			] ).onFree({ |synth| evt.synths_I.remove( synth ) })
		);
		evt.forks_I.remove( fork );
	}.fork;
	evt.forks_I = evt.forks_I.add( fork );
};

(
SynthDef( "inter_slow_fwd_I", { |buf = 0, startFrame = 0, fadeTime = 15, amp = 0.1, sustain = 1, gate = 1|
	var sig;
	var pos;
	var env;
	var env2;
	pos = Sweep.ar( 0, SampleRate.ir ) + startFrame;
	sig = PlayBufCF.ar( 2, buf, 
		Drand( [ 2/3, 0.5, 0.25 ], inf ), // rate
		Dwhite( 3, 10 ), // trigger
		Dwhite( 0, pos ),
		0, 3
	);
	sig = XFade2.ar( sig[0], sig[1], LFDNoise1.kr(0.1) ); 
	sig = BLowCut.ar( sig, 150, 3 );
	sig = sig * SinOsc.kr( LFDNoise1.kr( 0.2 ).linexp( -1, 1, 5, 20 ) ).range(0,1);
	sig = RoundPan.ar( 2, sig, LFDNoise1.kr(0.1), speakerRadius: 1 );
	env = Env.asr(0.1,1,0.1).kr(2, gate);
	env2 = Env([1,1,0],[sustain, 4],\lin).kr(2);
	sig = BHiCut.ar( sig, env2.linexp(0,1,20,20000), 3 ) * env2;
	Out.ar( 0, sig * amp * env );
}).load(s);

SynthDef( "inter_slow_bwd_I", { |buf = 0, startFrame = 220500, fadeTime = 15, amp = 0.1, sustain = 1, gate = 1|
	var sig;
	var pos;
	var env;
	var env2;
	pos = Sweep.ar( 0, SampleRate.ir ) + startFrame;
	sig = PlayBufCF.ar( 2, buf, 
		Drand( [ -2/3, -0.5, -0.25 ], inf ), // rate
		Dwhite( 3, ((pos / SampleRate.ir) - 1).clip(3,10) ), // trigger
		Dwhite( startFrame, pos ),
		0, 1
	);
	sig = XFade2.ar( sig[0], sig[1], LFDNoise1.kr(0.1) ); 
	sig = BLowCut.ar( sig, 150, 3 );
	sig = sig * SinOsc.kr( LFDNoise1.kr( 0.2 ).linexp( -1, 1, 5, 20 ) ).range(0,1);
	sig = RoundPan.ar( 2, sig, LFDNoise1.kr(0.1), speakerRadius: 1 );
	env = Env.asr(0.1,1,0.1).kr(2, gate);
	env2 = Env([1,1,0],[sustain, 4],\lin).kr(2);
	sig = BHiCut.ar( sig, env2.linexp(0,1,20,20000), 3 ) * env2;
	Out.ar( 0, sig * amp * env );
}).load(s);
);

/*
(
~inter.recordBufferForIndex( 0 );
~inter.start_I( 0 );
)

~inter.synths_I

(
{ 
	var index = 0;
	~inter.recordBufferForIndex( index );
	d = 2.collect({
		Synth( "inter_slow_fwd_I", [ 
			\buf, ~inter.bufferArray[index][0], 
			\startFrame, ~inter.bufferArray[index][1],
			\sustain, ~inter.score[index][1]
		] );
	});
	5.wait;
	e =  Synth( "inter_slow_bwd_I", [ 
		\buf, ~inter.bufferArray[index][0], 
		\startFrame, ~inter.bufferArray[index][1],
		\sustain, ~inter.score[index][1] - 5
	] );
}.fork;
)
*/

