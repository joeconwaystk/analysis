import 'dart:io';

import 'package:test/test.dart';
import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';

void main() {
  test('Project directory', () {
    final projectUri = Directory.current.absolute.uri.resolve("test/").resolve("test_project/");
    final dir = Directory.fromUri(projectUri);
    final path = PhysicalResourceProvider.INSTANCE.pathContext.normalize(dir.absolute.uri.toFilePath(windows: Platform.isWindows));
    final contexts = AnalysisContextCollection(includedPaths: [path]);
    expect(contexts.contexts.isNotEmpty, true);


    final unit = _getFileAstRoot(contexts, projectUri.resolve("bin/").resolve("main.dart").toFilePath(windows: Platform.isWindows));
    final decls = unit.declarations.whereType<FunctionDeclaration>().toList();
    expect(decls.first.name.name, "main");
  });

  test('Project sub-directory', () {
    final projectUri = Directory.current.absolute.uri.resolve("test/").resolve("test_project/").resolve("bin/");
    final dir = Directory.fromUri(projectUri);
    final path = PhysicalResourceProvider.INSTANCE.pathContext.normalize(dir.absolute.uri.toFilePath(windows: Platform.isWindows));
    final contexts = AnalysisContextCollection(includedPaths: [path]);
    expect(contexts.contexts.isNotEmpty, true);


    final unit = _getFileAstRoot(contexts, projectUri.resolve("main.dart").toFilePath(windows: Platform.isWindows));
    final decls = unit.declarations.whereType<FunctionDeclaration>().toList();
    expect(decls.first.name.name, "main");
  });

  test('Individual file', () {
    final fileUri = Directory.current.absolute.uri.resolve("test/").resolve("test_project/").resolve("bin/").resolve("main.dart");
    final dir = Directory.fromUri(fileUri);
    final path = PhysicalResourceProvider.INSTANCE.pathContext.normalize(dir.absolute.uri.toFilePath(windows: Platform.isWindows));
    final contexts = AnalysisContextCollection(includedPaths: [path]);
    expect(contexts.contexts.isNotEmpty, true);


    final unit = _getFileAstRoot(contexts, fileUri.toFilePath(windows: Platform.isWindows));
    final decls = unit.declarations.whereType<FunctionDeclaration>().toList();
    expect(decls.first.name.name, "main");
  });
}


CompilationUnit _getFileAstRoot(AnalysisContextCollection contexts, String absolutePath) {
  final path = PhysicalResourceProvider.INSTANCE.pathContext.normalize(absolutePath);
  final unit = contexts.contextFor(path).currentSession.getParsedUnit(path);

  if (unit.errors.isNotEmpty) {
    throw StateError(
      "Project file '${path}' could not be analysed for the following reasons:\n\t${unit.errors.join("\n\t")}");
  }

  return unit.unit;
}