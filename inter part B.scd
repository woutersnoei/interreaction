// inter Part B

~inter = ~inter ? EM();

~inter.start_B = { |evt, index|
	var duration, buffer, forks;
	index = index ? evt.currentIndex;
	duration = evt.score[ index ][1];
	buffer = evt.bufferArray[index][0];
	forks = [	
		{
			var time = 0, waitTime;
			while { time < (duration - 5) } {	 
				Synth( "inter_tremolo_B", [
					\useInputLevel, 1, // turn level following on/off
					\freqs, (80..120).scramble[..9].sort.midicps 
				] );
				waitTime = 2.0 rrand: 8.0;
				waitTime.wait;
				time = time + waitTime;
			};
			evt.forks_B.remove( forks[0] );
		}.fork,
		{	
			var time = 0, waitTime;
			while { time < duration } {	 
				waitTime = 0.05 exprand: 4.0;
				waitTime.wait;
				Synth( "inter_staccato_B", [
					\buf, buffer,
					\endFrame, evt.bufferArray[index][1].postln,
				] );
				time = time + waitTime;
			};
			evt.forks_B.remove( forks[1] );
		}.fork
	];
	evt.forks_B = evt.forks_B.addAll( forks );
};

(
SynthDef( "inter_tremolo_B", { |amp = 0.1, useInputLevel = 1, sustain = 8|
	var sig, inAmp = 0.5;
	inAmp = PrivateIn.ar( 0, 2 );
	inAmp = Peak.kr( 
		Gate.kr( 
			Amplitude.kr(inAmp), 
			Line.kr( 1, 0, 0.1 ) > 0 
		) 
	).clip( 0.01, 0.5 );
	inAmp = if( useInputLevel, inAmp, 0.5 );
	sig = Klank.ar( `[
		\freqs.kr( ( 80..120 ).scramble[..9].sort.midicps ),
		(..9).linexp( 0,9, 0.25, 1 ) / 10,
		Rand( 0.05.dup(10), 0.5 )
	], PinkNoise.ar(1.dup) );
	sig = sig * SinOsc.kr( LFDNoise1.kr( 0.2.dup ).linexp( -1, 1, 10, 20 ) ).range(0,1);
	sig = sig * Pan2.kr(DC.kr(1),Rand(-1,1));
	sig = sig * Env([0,1,0],[0.5,0.5] * sustain, [2,-2] ).kr(2);
	Out.ar(0, sig * amp * inAmp);
}).load(s);

SynthDef( "inter_staccato_B", { |amp = 0.2, buf = 0, endFrame = 22050, dur = 0.1|
	var sig, env, rate;
	rate = (IRand(1,4) * IRand(0,1).linlin(0,1,-1,1)).midiratio;
	sig = PlayBuf.ar( 2, buf, rate, 1, 
		Rand(0, endFrame - ((dur/rate.abs) * SampleRate.ir) ) ).sum;
	env = Env([0,1,0,0],[0.01, dur, 0.05], -4).ar(2);
	sig = RoundPan.ar( 2, sig * env, Rand(-1,1), speakerRadius: 1 );
	Out.ar(0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 10 );
~inter.start_B( 10 );
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