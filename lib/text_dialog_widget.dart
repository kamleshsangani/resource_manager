import 'package:flutter/material.dart';

Future<T?> showTextInputDialog<T>(
  BuildContext context, {
  required String value,
}) =>
showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.all(
              Radius.circular(10.0))),
      content: Builder(
        builder: (context) {
          var width = MediaQuery.of(context).size.width;
          return SizedBox(
            height: 400,
            width: width - 400,
            child: TextDialogWidget(
              value: value,
            ),
          );
        },
      ),
    )
);

class TextDialogWidget extends StatefulWidget {
  final String value;

  const TextDialogWidget({
    Key? key,
    required this.value,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 20,),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        )
      ],
    );
  }
}
