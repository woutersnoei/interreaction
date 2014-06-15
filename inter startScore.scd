~inter = ~inter ? EM();

~inter.currentIndex = nil;
~inter.currentItem = nil;
~inter.currentRemainingTime = 0;
~inter.upcomingItem = nil;

~inter.startScore = { |evt, preRoll = 15, startAt = 0|
	evt.endScore;
	evt.playTask = Task({
		if( preRoll > 0 ) {
			evt.currentItem = ['ready?', preRoll];
			evt.upcomingItem = evt.score[startAt] ? [\end,0];
			preRoll.do({ |ii|
				evt.currentRemainingTime = preRoll - ii;
				1.wait;
			});
		};
		(evt.score.size - startAt).do({ |i|
			i = i + startAt;
			evt.active = true;
			evt.currentIndex = i;
			evt.currentItem = evt.score[i];
			evt.upcomingItem = evt.score[i+1] ? [\end,0];
			evt.currentItem[1].do({ |ii|
				evt.currentRemainingTime = evt.currentItem[1] - ii;
				1.wait;
			});
		});
		evt.active = false;
		evt.currentIndex = nil;
		evt.currentItem = [\end, 0];
		evt.upcomingItem = nil;
		evt.currentRemainingTime = 0;
	}).start;
};

~inter.pauseScore = { |evt|
	
	if( evt.playTask.notNil && { evt.playTask.isPlaying }) {
		evt.playTask.pause;
	};
};

~inter.resumeScore = { |evt|
	if( evt.playTask.notNil && { evt.playTask.isPlaying.not }) {
		evt.playTask.resume;
	};
};

~inter.togglePause = { |evt|
	if( evt.playTask.notNil ) {
		if( evt.playTask.isPlaying ) {
			evt.playTask.pause;
		} {
			evt.playTask.resume;
		};
	};
};

~inter.endScore = { |evt|
	if( evt.playTask.isPlaying ) {
		evt.playTask.stop;
		evt.playTask = nil;
		evt.active = false;
	};
	evt.currentIndex = nil;
	evt.currentItem = nil;
	evt.currentRemainingTime = 0;
	evt.upcomingItem = nil;
};

/*
~inter.makeScore; "";

~inter.startScore;
~inter.endScore;
~inter.pauseScore;
~inter.resumeScore;
*/