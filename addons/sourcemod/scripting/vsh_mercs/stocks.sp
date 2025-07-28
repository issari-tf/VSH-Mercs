// Helper functions.
stock bool CheckDownload(const char[] file)
{
	if (FileExists(file, true)) {
		AddFileToDownloadsTable(file);
		return true;
	}
	return false;
}

stock void DownloadMaterialList(const char[][] file_list, int size)
{
	char s[PLATFORM_MAX_PATH];
	for(int i; i < size; i++) {
		strcopy(s, sizeof(s), file_list[i]);
		CheckDownload(s);
	}
}

/// For custom models, do NOT omit .MDL extension
stock int PrepareModel(const char[] model_path, bool model_only=false)
{
	char extensions[][] = { ".mdl", ".dx80.vtx", ".dx90.vtx", ".sw.vtx", ".vvd", ".phy" };
	char model_base[PLATFORM_MAX_PATH];
	char path[PLATFORM_MAX_PATH];
	
	strcopy(model_base, sizeof(model_base), model_path);
	SplitString(model_base, ".mdl", model_base, sizeof(model_base)); /// Kind of redundant, but eh.
	if( !model_only ) {
		for( int i; i<sizeof(extensions); i++ ) {
			Format(path, PLATFORM_MAX_PATH, "%s%s", model_base, extensions[i]);
			CheckDownload(path);
		}
	} else {
		CheckDownload(model_path);
	}
	return PrecacheModel(model_path, true);
}
