abstract class RenameConfigException implements Exception {
  final String message;
  const RenameConfigException(this.message);

  @override
  String toString() => '❌ Rename Configuration Error: $message';
}

class RenameYamlNotFoundException extends RenameConfigException {
  RenameYamlNotFoundException(String path)
      : super('Configuration file not found at "$path".\n'
            '   Run "dart run flutter_archkit:rename --init" or "archkit rename --init" to create one.');
}

class RenameYamlEmptyException extends RenameConfigException {
  RenameYamlEmptyException(String path)
      : super('"$path" is empty or missing required configuration.\n'
            '   It must specify at least:\n'
            '     app_name: "My App"\n'
            '     package_name: "com.example.myapp"');
}

class RenameYamlParseException extends RenameConfigException {
  RenameYamlParseException(super.details);
}
