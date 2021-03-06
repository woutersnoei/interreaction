// inter Part G

~inter = ~inter ? EM();

~inter.start_G = { |evt, index|
	var duration, buffer, fork, recvReply, onsets = [];
	index = index ? evt.currentIndex;
	duration = evt.score[index][1];
	buffer = evt.bufferArray[index][0];
	fork = {	
		var time = 0, waitTime;
		0.25.wait;
		recvReply = ReceiveReply( evt.recSynths.last, { |value|
			onsets = onsets.add( value );
		}, '/onset' );
		evt.end_G = { recvReply.remove };
		while { time < (duration - 0.25) } {	 
			waitTime = 0.5 exprand: 1.5;
			waitTime.wait;
			if( onsets.size > 1 ) {
				Synth( "inter_reverse_G", [
					\buf, buffer,
					\startFrame, onsets.choose.postln,
				] );
			};
			time = time + waitTime;
		};
		recvReply.remove;
		evt.forks_G.remove( fork );
	}.fork;
	evt.forks_G = evt.forks_G.add( fork );
};

(
SynthDef( "inter_reverse_G", { |amp = 0.5, buf = 0, startFrame = 22050, dur = 0.2|
	var sig, env, rate;
	rate = (IRand(1,4) * IRand(0,1).linlin(0,1,-1,1)).midiratio * -0.5;
	sig = PlayBuf.ar( 2, buf, rate, 1, startFrame + (dur * SampleRate.ir) ).sum;
	sig = BLowCut.ar( sig, 100 );
	env = Env([0,0.5,1,0],[0.1,0.9,0.1] * (dur / rate.abs), \lin ).ar(2);
	sig = RoundPan.ar( 2, sig * env, Rand(-1,1), speakerRadius: 1 );
	Out.ar(0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 1 );
~inter.start_G( 1 );
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