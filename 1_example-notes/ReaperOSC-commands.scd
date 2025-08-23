b.sendMsg("/tempo/raw", 60);
b.sendMsg("/track/1/recarm", 1).postln;
b.sendMsg("/track/2/recarm", 1);
b.sendMsg("/track/3/recarm", 1);
b.sendMsg("/track/4/recarm", 1);
b.sendMsg("/time", 0);
r.link.sendMsg("/action/40042"); //Restart
b.sendMsg("/record", 1);
b.sendMsg("/stop", 1);

b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
b.sendMsg("/action/40001"); //Insert Track
b.sendMsg("/track/1/name", "test");
b.sendMsg("/track/1/select", 1);

b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");

r = Reaper.new("127.0.0.1", 7772);

(
b.sendMsg("/action/40035"); //Select all
b.sendMsg("/action/40697"); //Delete all
["lead", "dust", "hh", "b"].do { | i, c |
	var name, num, cmdName, cmdArm;
	name = i;
	name.postln;
	num = c + 1;
	num.postln;
	cmdName = "/track/"++num++"/name";
	cmdArm = "/track/"++num++"/recarm";
	cmdArm.postln;
	b.sendMsg("/action/40001"); //Insert Track
	b.sendMsg(cmdName, i); //Insert Track
	b.sendMsg(cmdArm, 1);
	b.sendMsg("/action/_RSfea88ffe51bc35b05e3feb7250d4ca5850fc0c2b");
};
)