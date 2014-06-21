// inter Part F

~inter = ~inter ? EM();

~inter.start_F = { |evt, index|
	var duration, buffer, fork, recvReply, onsets = [];
	index = index ? evt.currentIndex;
	duration = evt.score[index][1];
	buffer = evt.bufferArray[index][0];
	recvReply = ReceiveReply( evt.recSynths.last, { |value|
		onsets = onsets.add( value );
	}, '/onset' );
	evt.end_F = { recvReply.remove };
	fork = {	
		var time = 0, waitTime;
		while { time < duration } {	 
			waitTime = 0.05 exprand: 1.5;
			waitTime.wait;
			if( onsets.size > 0 ) {
				Synth( "inter_staccato_F", [
					\buf, buffer,
					\startFrame, onsets.choose,
				] );
			};
			time = time + waitTime;
		};
		recvReply.remove;
		evt.forks_F.remove( fork );
	}.fork;
	evt.forks_F = evt.forks_F.add( fork );
};

(
SynthDef( "inter_staccato_F", { |amp = 0.5, buf = 0, startFrame = 22050, dur = 0.2|
	var sig, env, rate;
	rate = (IRand(1,4) * IRand(0,1).linlin(0,1,-1,1)).midiratio;
	sig = PlayBuf.ar( 2, buf, rate, 1, startFrame + 319 ).sum;
	env = Env([0,1,0,0],[0.01, dur/rate.abs, 0.05], 0).ar(2);
	sig = RoundPan.ar( 2, sig * env, Rand(-1,1), speakerRadius: 1 );
	Out.ar(0, sig * amp );
}).load(s);
);

/*

~inter.active = true;

(
~inter.recordBufferForIndex( 7 );
~inter.start_F( 7 );
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