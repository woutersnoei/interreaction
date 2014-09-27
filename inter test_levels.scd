~inter = ~inter ? EM();

~inter.test_amp = 0.5;
~inter.test_amp_ = { |evt, amp = 0.5| 
	evt[ \test_amp ] = amp;
	evt.test_synths.do(_.set( \amp, amp ) );
};
~inter.test_index = 0;

(
SynthDef( "inter_testbuf", { |play = 0, amp = 0.5, buf = 0|
	var in, sig, rec;
	in = PrivateIn.ar( 0, 2 );
	rec = Slew.kr( 1-play, 10, 10 );
	play = Slew.kr( (1-rec) > 0, 10, 10 );
	RecordBuf.ar( in, buf, 0, rec, 1-rec, 1, 1 );
	sig = PlayBuf.ar( 2, buf, 1, 1, 0, 1 ) * play * amp;
	Out.ar( 0, sig );
}).load(s);
);

~inter.make_test_buffers = { |evt|
	evt.test_buffers = 2.collect({ Buffer.alloc( s, 44100 * 3, 2 ); });
	"test buffers created";
};

~inter.start_test = { |evt|
	evt.test_synths = evt.test_buffers.collect({ |item|
		Synth( "inter_testbuf", [ \buf, item, \amp, evt.test_amp ] );
	});
};

~inter.end_test = { |evt|
	evt.test_synths.do(_.free);
	evt.test_buffers.do(_.zero);
};

~inter.test_on = { |evt|
	evt.test_off;
	evt.test_synths[ evt.test_index ].set( \play, 1 );
	evt.test_index = (evt.test_index + 1).wrap( 0, evt.test_buffers.size - 1 ).postln;
};

~inter.test_off = { |evt|
	evt.test_synths.do(_.set( \play, 0 ) );
};

~inter.make_test_window = { |evt|
	evt.test_window = Window( "test", Rect(703, 365, 339, 113) ).front;
	evt.test_window.addFlowLayout;
	StaticText(  evt.test_window, 120 @ 30 ).string_( "Test input levels" );
	evt.test_button = RoundButton( evt.test_window, 30 @ 30 )
		.label_( [ \power, \power ] )
		.hiliteColor_( Color.red )
		.action_({ |bt|
			switch( bt.value,
				1, { evt.test_on },
				0, { evt.test_off }
			);
		});
	evt.test_window.view.decorator.nextLine;
	StaticText(  evt.test_window, 120 @ 30 ).string_( "Part C level" );
	evt.part_C_button = RoundButton( evt.test_window, 30 @ 30 )
		.label_( [ \power, \power ] )
		.hiliteColor_( Color.red )
		.action_({ |bt|
			switch( bt.value,
				1, { evt.start_C( 0, inf ) },
				0, { evt.end_C }
			);
		});
	evt.part_C_level = SmoothSlider( evt.test_window, 150 @ 30 )
		.value_( \amp.asSpec.unmap( evt.amp_C ) )
		.action_({ |sl|
			evt.amp_C = \amp.asSpec.map( sl.value );
		});
};

s.waitForBoot({
	~inter.make_test_buffers;
	s.sync;
	~inter.start_test;
	{ ~inter.make_test_window }.defer;
});


/*
~inter.start_test;
~inter.end_test;

~inter.test_on;
~inter.test_off;
*/