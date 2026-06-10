

import "import_export.dart";

class ColorDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: Container(color: Colors.red)),
          Expanded(flex: 2, child: Container(color: Colors.blue)),
        ],
      ),
    );
  }
}
