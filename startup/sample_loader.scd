(
~root = "~/Music/supercollider/_samples/*";

~recursive = { |folder|
	var path, folders, is_folder;

	folder.inspect;
	path = PathName(folder);
	is_folder = path.isFolder;
	folders = path.pathMatch;
	if(is_folder == true,
		{
			folders.do { | i | ~recursive.value(i)} },
		{ i.postln; }
	)
};

~recursive.value("~/Music/supercollider/_samples/*");
)