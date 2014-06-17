// parts master;
(

~inter = ~inter ? EM();

~inter.path = thisProcess.nowExecutingPath.dirname;

[\A, \B, \C, \D, \E, \F, \G, \H, \I, \J ].do({ |item|
	(~inter.path +/+ "inter part" + item ++ ".scd").load;
});
)

