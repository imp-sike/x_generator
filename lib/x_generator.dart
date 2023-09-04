library x_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'generators/x_api_generator.dart';

Builder generateAnnotation(BuilderOptions options) => SharedPartBuilder(
      [XApiGenerator()],
      'x',
    );
