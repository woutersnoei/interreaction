~inter = ~inter ? EM();

~inter.win = ~inter.win ? EM();

~inter.win.makeBasicWindow = { |evt|
	if( evt.basicWindow.notNil && { evt.basicWindow.isClosed.not } ) {
		evt.basicWindow.close;
	};
	evt.basicWindow = Window().front;
	evt.basicWindow.userCanClose_( false );
	evt.basicWindow.addFlowLayout;
	evt.openWindowButton = RoundButton( evt.basicWindow, 392 @ 392 )
		.label_( "Open window" )
		.font_( Font( Font.defaultSansFace, 30 ) )
		.resize_( 5 )
		.action_({ ~inter.win.makeWindow( true ) });
};

~inter.win.makeWindow = { |evt, fullScreen = true|
	var ctrl, w;
	evt.w = Window( "Interreaction", Rect( 120, 120, 900, 500 ), border: fullScreen != true ).front;
	evt.w.view.background = Color.black;
	if( fullScreen ) { evt.w.fullScreen; };
	w = evt.w;
	
	evt.nextView = StaticText( evt.w, 900@120 )
		.stringColor_( Color.white )
		.align_( \left )
		.font_( Font( Font.defaultSansFace, 100 ) )
		.resize_( 2 );
		
		
	evt.nowView = StaticText( evt.w, Rect( 0, 120, 900, 380 ) )
		.stringColor_( Color.white )
		.align_( \center )
		.font_( Font( Font.defaultSansFace, 220 ) )
		.resize_( 5 );
		
	SmoothButton( evt.w, Rect( evt.w.view.bounds.right - 30, 0, 30, 30 ) )
		.stringColor_( Color.gray(0.8) )
		.label_( 'x' )
		.canFocus_( false )
		.resize_( 3 )
		.action_( { w.close; ~inter.endScore; } )
		.onClose_( { ctrl.remove } );
		
	evt.transportView = CompositeView( evt.w, Rect( evt.w.view.bounds.right - 240, 0, 240, 60 ) )
		.resize_( 3 );
	
	evt.transportView.addFlowLayout;
	
	SmoothButton( evt.transportView, 60@60  )
		.stringColor_( Color.gray(0.7) )
		.label_( 'roundArrow' )
		.canFocus_( false )
		.resize_( 3 )
		.action_( { 
			~inter.endScore;
			~inter.makeScore;
		} );
	
	SmoothButton( evt.transportView, 60@60  )
		.stringColor_( Color.gray(0.7) )
		.label_( 'stop' )
		.canFocus_( false )
		.resize_( 3 )
		.action_( { 
			~inter.endScore;
		} );
		
	SmoothButton( evt.transportView, 60@60  )
		.stringColor_( Color.gray(0.7) )
		.label_( 'play' )
		.canFocus_( false )
		.resize_( 3 )
		.action_( { 
			~inter.startScore;
		} );
		
	evt.w.view.keyDownAction = { |vw, char, mod, ascii, unicode|
		switch ( ascii,
			32,  { // space bar
				~inter.startScore;
			},
			127, { // backspace
				~inter.endScore;
			}
		);
	};
		
	ctrl = SimpleController( ~inter )
		.put( \currentItem, { |obj|
			{ evt.nowView.string = "%  %".format( 
				(obj.currentItem ? ["-"])[0], SMPTE( obj.currentRemainingTime ? 0 ).format( "M:ss " ) 
			);
			}.defer;
		})
		.put( \currentRemainingTime, { |obj|
			{	
				//evt.timeView.string = SMPTE( obj.currentRemainingTime ? 0 ).format( "M:ss " );
				obj.changed( \currentItem );
				if( obj.currentRemainingTime.inclusivelyBetween(1,4) ) {
					evt.nowView.stringColor = Color.yellow;
					evt.nextView.stringColor = Color.yellow;
				} {
					evt.nowView.stringColor = Color.white;
					evt.nextView.stringColor = Color.white;
				};
			}.defer;
		})
		.put( \upcomingItem, {	 |obj|
			{	
				if( obj.upcomingItem.notNil ) {
					evt.nextView.string = " next: %  %".format( obj.upcomingItem[0], SMPTE( obj.upcomingItem[1] ).format("M:ss") );
				} {
					evt.nextView.string = " next: -";
				};
			}.defer;
		});

	~inter.changed( \currentItem );
	~inter.changed( \currentRemainingTime );
	~inter.changed( \upcomingItem );
	
	//evt.w.onClose_( { ctrl.remove } );
};

~inter.win.makeBasicWindow;

/*
~inter.playScore = { |evt, preRoll = 10, startAt = 0|
	evt.playTask = {
		var score;
		if( preRoll > 0 ) {
			score = [ [ 'ready?', preRoll ] ] ++ evt.score[ startAt .. ];
		} {
			score = evt.score[ startAt .. ];
		};
		score.size.do({ |i|
			evt.current = score[i];
			evt.current[1].do({ |item, ii|
				evt.win.set( 
					evt.current[0], 
					evt.current[1] - ii, 
					score[i+1] ? [\end,0]
				);
				1.wait;
			});
		});
		evt.win.set( "end", 0 );
	}.fork;
};
*/

/*
~inter.makeScore(); "";

~inter.startScore;
~inter.playScore();
*/