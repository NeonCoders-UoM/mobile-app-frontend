import 'package:flutter/widgets.dart';
import 'presentation/components/atoms/custom_text_field.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomTextField(),
    );
  }
}
