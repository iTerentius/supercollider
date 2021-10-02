(
f = { |folder|
	var path, folders, is_folder;
	"running".postln;
	// folder.inspect;
	path = PathName(folder);
	// path.postln;
	is_folder = path.isFolder;
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
