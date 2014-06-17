~inter = ~inter ? EM();

~inter.ctrl.remove;
~inter.ctrl = SimpleController( ~inter )
	.put( \currentIndex, { |obj|
		if( obj.active == true && { obj.currentIndex.notNil } ) {
			obj.recordBufferForIndex( obj.currentIndex );
			obj.startIndex( obj.currentIndex );
		};
	})
	.put( \score, { |obj|
		obj.makeBuffers;
	});


~inter.startIndex = { |evt, index|
	var which;
	which = evt.score[ index ][ 0 ];
	evt.perform( ("start_" ++ which).asSymbol, index );
};

~inter.stopAll = { |evt|
	[\A, \B, \C, \D, \E, \F, \G, \H, \I, \J].do({ |item|
		evt[ ("synths_" ++ item).asSymbol ].do(_.release);
		evt[ ("forks_" ++ item).asSymbol ].do(_.stop);
		evt.perform( ("end_" ++ item).asSymbol );
	});
	evt.stopBuffers;
	
};