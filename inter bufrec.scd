~inter = ~inter ? EM();

(
~inter.makeBuffers = { |evt, action|
	evt.clearBuffers;
	{	
		evt.bufferArray = evt.score.collect({ |item|
			[ Buffer.alloc( s, 44100 * item[1], 2 ), 0 ];
		});
		s.sync;
		action.value;
		"created buffers".postln;
	}.fork;
};

~inter.clearBuffers = { |evt|
	if( evt.bufferArray.notNil ) {
		evt.bufferArray.do({ |item|
			item[0].free;
		});
		evt.bufferArray = nil;
	};
};

~inter.getBuffersFor = { |evt, which|
	var indices;
	if( evt.bufferArray.notNil ) {
		indices = [];
		evt.score.do({ |item, i|
			if( item[0] == which ) {
				indices = indices.add( i );
			};
		});
		evt.bufferArray[ indices ].select({ |item| item[1] != 0 }).collect(_[0]);
	} {
		nil;
	};
};

~inter.recordBufferForIndex = { |evt, index|
	var synth, bufname;
	if( evt.score.notNil && { evt.score[ index ].notNil }) {
		bufname = "buffer #% for % %".format( 
			index,  evt.score[ index ][0], SMPTE( evt.score[ index ][1] ).format("M:ss")
		);
		evt.recSynths = evt.recSynths ? Order();
		if( evt.recSynths[ index ].isNil ) {	
			"starting recording %\n".postf( bufname );
			synth = Synth( "inter_bufrec", [ \buf, evt.bufferArray[ index ][0] ] ).onFree({ |synth|
				"done recording %\n".postf( bufname );
				evt.recSynths.remove( synth );
			});
			evt.recSynths[ index ] = synth;
			ReceiveReply( synth, { |pos| evt.bufferArray[ index ][1] = pos }, '/pos' );
		} {
			"already recording %\n".postf( bufname );
		};
	} {
		"can't record buffer; no score or non-existing index".postln;
	};
};
);

(
SynthDef( "inter_bufrec", { |buf = 0, in = 0, updateRate = 10|
	var sig, env, pos;
	var chain, onsets;
	sig = PrivateIn.ar( in, 2 );
	env = Env([0.5pi,0.5pi,0],[BufDur.kr( buf ), 0.125], \lin ).ar(2);
	pos = Line.ar(0, BufFrames.kr( buf ), BufDur.kr( buf ) );
	SendReply.kr( Impulse.kr( updateRate ), '/pos', pos );
	chain = FFT( LocalBuf(512).clear, sig.sum );
	onsets = Onsets.kr( chain, 0.5 );
	SendReply.kr( onsets, '/onset', pos - 512 );
	RecordBuf.ar( sig, buf, 0, env.sin, (0.5pi - env).sin );
}).load(s);
);


~inter.recSynths = nil;

~inter.ctrl.remove;
~inter.ctrl = SimpleController( ~inter )
	.put( \currentIndex, { |obj|
		if( obj.active == true && { obj.currentIndex.notNil } ) {
			obj.recordBufferForIndex( obj.currentIndex );
		};
	});

/*
(
~inter.makeScore;
~inter.makeBuffers; "";
)


~inter.bufferDict.sortedKeysValuesDo({ |key, value| [ key, value.buffers.size ].postln }); "";

~inter.ir = InputRouter.unique( s, "interreaction", [ \l, \r ]);

~inter.ir.gui;

~inter.ir.start;
*/