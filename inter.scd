// SuperCollider code for Interreaction, Wouter Snoei
// 5 Peatzold recorders and live electronics

// master file; execute code below to start program
(

~inter = ~inter ? EM();

~inter.path = thisProcess.nowExecutingPath.dirname;

~inter.names = [ 
	\bufrec, \parts, \ir, \controls,
	\score, \startScore, \gui 
];

~inter.names.do({ |item|
	(~inter.path +/+ "inter" + item ++ ".scd").load;
});

/*
 ~inter.win.makeWindow( false );
*/
)

