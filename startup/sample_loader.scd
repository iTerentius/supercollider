(
d = Dictionary.new;

~recursive = { |folder|
	var path, folders, is_folder;

	folder.inspect;
	path = PathName(folder);
	is_folder = path.isFolder;
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

