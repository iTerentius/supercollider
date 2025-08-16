(
<<<<<<< HEAD
d = Dictionary.new;

~recursive = { |folder|
=======
f = { |folder|
>>>>>>> fd5757e5aa556dc643c81fc99f64ea0af0a3db26
	var path, folders, is_folder;
	"running".postln;
	// folder.inspect;
	path = PathName(folder);
	// path.postln;
	is_folder = path.isFolder;
<<<<<<< HEAD
	// folder = folder ++ "*";
	folder.postln;
	folders = folder.pathMatch;
	path = path.pathOnly ++ "*";
	if(is_folder == true,
		{
			folders.do { | i | ~recursive.value(i ++ "*")} },
		{ ~samples.add(SoundFile.new(path)); }
		)
};
)

~recursive.value("~/Music/supercollider/_samples/");

~root = "~/Music/supercollider/_samples/*";

~samples.postln;

(
~k = Pbind(\instrument,\bplay,\buf,d["k"][0],\dur,1);
~k.play;
)

=======
	// is_folder.postln;
	folders = path ++ "/*".pathMatch;
	folder.postln;
	if(is_folder == true,
		{
			// folders.postln;
			folders.do { | i | f.value(i)}; },
		{ "file".postln; }
	)
};
)
f.value("~/Music/supercollider/_samples/*");

~f.value;
>>>>>>> fd5757e5aa556dc643c81fc99f64ea0af0a3db26
