~inter = ~inter ? EM();

~inter.scoreSpecs = [
	// key, times,    weights matrix (chance to next)
	//			   #[ A, B, C, D, E, F, G, H, I, J ]
	[ \A, [ 30, 60 ], [ 0, 1, 1, 0, 1, 2, 4, 4, 1, 0 ] ],
	[ \B, [ 20, 40 ], [ 1, 0, 1, 1, 1, 4, 3, 4, 1, 1 ] ],
	[ \C, [ 20, 70 ], [ 1, 1, 0, 1, 1, 4, 1, 4, 2, 1 ] ],
	[ \D, [ 30, 60 ], [ 0, 1, 1, 0, 2, 2, 4, 4, 2, 0 ] ],
	[ \E, [ 10, 30 ], [ 1, 1, 2, 1, 0, 3, 4, 2, 2, 1 ] ],
	[ \F, [  4, 10 ], [ 3, 2, 4, 3, 3, 0, 1, 1, 3, 3 ] ],
	[ \G, [  5, 15 ], [ 3, 4, 1, 3, 3, 1, 0, 1, 2, 3 ] ],
	[ \H, [  5, 25 ], [ 4, 3, 3, 3, 2, 1, 1, 0, 2, 4 ] ],
	[ \I, [ 10, 30 ], [ 2, 2, 3, 3, 2, 1, 2, 1, 0, 4 ] ],
	[ \J, [ 30, 90 ], [ 0, 2, 2, 0, 2, 3, 4, 4, 2, 0 ] ],
	//			   #[ A, B, C, D, E, F, G, H, I, J ]
];

~inter.makeScore = { |evt, dur = 6.25, seed|
	seed = seed ?? { ((2**30)).asInt.rand; };
	evt.seed = seed;
	evt.score = {
		var time = 0, nextTime, getTime, timePerPart, score, last, index;
		thisThread.randSeed = seed;
		getTime = { |item| item[0] rrand: item[1] };
		
		timePerPart = 0!10;
		index = 0;
		last = evt.scoreSpecs[ index ];
		
		while { time < (60 * dur) } {
			nextTime = getTime.( last[1] );
			time = time + nextTime;
			timePerPart.put( index, timePerPart[ index ] + nextTime );
			score = score ++ [ [ last[0], nextTime ] ];
			last = evt.scoreSpecs.wchoose( ( last[2] * (30/((timePerPart+1)))).normalizeSum );
			index = evt.scoreSpecs.indexOf( last );
		};
		"\ngenerated new score\nseed: %\nduration: %".postf( seed, SMPTE( score.flop[1].sum ).format("M:ss") );
		score.do({ |item, i|
			if( (i % 4) == 0 ) { "\n".post };
			"% % | ".postf( item[0], SMPTE( item[1] ).format("M:ss") );
		}); "".postln;
		score.yield;
	}.r.next;
};

~inter.makeScore;


/*
~inter.makeScore; "";

(
~inter.scoreSpecs.do({ |item| "% : %-%s, %\n".postf( 
	item[0], 
	item[1][0].asString.reverse.extend(2,$ ).reverse, 
	item[1][1],
	item[2]
	)
}); "";
)

(
~inter.score.do({ |item, i|
	if( (i % 4) == 0 ) { "".postln };
	"% % | ".postf( item[0], SMPTE( item[1] ).format("M:ss") );
}); "";
"\ntotal duration: %\n".postf( SMPTE( ~inter.score.flop[1].sum ).format("M:ss") ); "";
)
*/
