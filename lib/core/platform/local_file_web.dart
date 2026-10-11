Future<bool> localFileExists(String path) async => false;

bool localFileExistsSync(String path) => false;

Future<bool> revealLocalFileInExplorer(String path) async => false;

Future<bool> openLocalFileExternally(String path) async => false;

bool get canRevealLocalFileInExplorer => false;

bool get canOpenLocalFileExternally => false;

String? localFileParentPath(String path) => null;
