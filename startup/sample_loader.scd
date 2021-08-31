(
~root = "~/Music/supercollider/_samples/*".pathMatch;

~recursive = do(~root, { |i|
	var path, is_folder;

	path = PathName(i);
	is_folder = path.isFolder;
	if(is_folder) ~recursive, {

});


)