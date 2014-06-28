// inter Part H

~inter = ~inter ? EM();

~inter.start_H = { |evt, index|
	var duration, buffer, fork, recvReply, onsets = [];
	index = index ? evt.currentIndex;
	duration = evt.score[index][1];
	buffer = evt.bufferArray[0][0];
	
	evt.synths_H = evt.synths_H.addAll(
		4.collect({
			Synth( "inter_otherpart_H", [ 
				\buf, buffer, 
				\sustain, duration - 0.25,
			] ).onFree({ |synth| evt.synths_H.remove( synth ) })
		})
	);
};

(
SynthDef( "inter_otherpart_H", { |amp = 0.5, in = 0, buf = 0, sustain = 1, gate = 1|
	var sig;
	var env;
	var env2;
	var input;
	//rate = (IRand(1,4) * IRand(0,1).linlin(0,1,-1,1)).midiratio;
	/*
	sig = PlayBufCF.ar( 2, buf, 1, Dwhite(3, 10), 
		Dwhite( 0, BufFrames.kr( buf ) ), 1, 1 );
	sig = Normalizer.ar( sig, 1, 0.01 );
	*/
	sig = GrayNoise.ar(1);
	/*
	sig = CombC.ar( sig, 1/100, 
		1/LFDNoise0.kr( LFDNoise1.kr(0.5.dup(4)).exprange(0.5,1) ).exprange(100,1000),
		0.1
	).sum / 3;
	*/
	input = PrivateIn.ar( in, 2 );
	//sig = (sig ring1: GrayNoise.ar);
	sig = sig	 * (Amplitude.kr( DelayC.ar( input, 1, LFDNoise3.kr(0.2).range(0.01,1) ) ) - 0.01).clip(0,0.5);
	sig = XFade2.ar( sig[0], sig[1], LFDNoise1.kr(0.1) ); 
	sig = BLowCut.ar( sig, LFDNoise1.kr(0.6).exprange( 100, 5000 ), 3 );
	sig = BHiCut.ar( sig, LFDNoise1.kr(0.6).exprange( 500, 20000 ), 3 );
	sig = sig * LFDNoise3.kr(0.3).exprange(0.5,1);
	sig = RoundPan.ar( 2, sig, LFDNoise1.kr(0.3), speakerRadius: 1 );
	sig = sig * Env( [0,1,1,0], [0.5,0.5] * sustain, [2,-2] ).kr(2);
	Out.ar( 0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 3 );
~inter.start_H( 3 );
)

Synth( "inter_reverse_G", [ \buf, ~inter.bufferArray[1][0], \startFrame, 3265 ] );

~inter.bufferArray[1][0].plot

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