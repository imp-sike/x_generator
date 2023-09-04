import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:x_generator/annotations/x_api.dart';
import 'package:x_generator/annotations/x_get.dart';

const _coreChecker = TypeChecker.fromRuntime(XGet);

class XApiGenerator extends GeneratorForAnnotation<XApi> {
  @override
  String? generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    if (element is ClassElement) {
      // get file path of the abstract class
      final inputId = buildStep.inputId;

      String output =
          'import "${inputId.uri.toString()}";\nimport "dart:convert";\n';

      output += generateClassImplementation(element, annotation);
      output += generateMethodsImplementation(element, annotation);

      return "${output.trim()}}";
    }
    return null;
  }

  String generateClassImplementation(
      Element element, ConstantReader annotation) {
    String? className = element.name;
    String baseUrl = annotation.read("baseUrl").stringValue;

    String output = '''import "package:http/http.dart" as http;
    import "package:x_generator/helper/json_converter.dart";\n
    class ${className}Impl implements $className {
        \nString baseUrl = "$baseUrl";\n\n''';

    return output;
  }

  String generateMethodsImplementation(
      ClassElement element, ConstantReader annotation) {
    String output = "";

    for (var method in element.methods) {
      final hasXApiAnnotation = method.metadata.any((meta) =>
          meta
              .computeConstantValue()
              ?.type
              ?.getDisplayString(withNullability: false) ==
          'XGet');

      if (hasXApiAnnotation) {
        String functionName = method.name;
        String functionType = method.type.returnType.toString();

        String? functionEndpoint = _coreChecker
            .firstAnnotationOfExact(method)!
            .getField("endpoint")
            ?.toStringValue();

        output += '''
        @override
        $functionType $functionName() async {
            http.Response response = await http.get(Uri.parse("\$baseUrl/$functionEndpoint"));
            return await jsonDecode(response.body);
        }
        
        ''';
      }
    }

    return output;
  }
}
