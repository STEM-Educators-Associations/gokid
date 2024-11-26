import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class AgePickerScreen extends StatefulWidget {
  final int initialAge;
  final ValueChanged<int> onAgeChanged;

  const AgePickerScreen({
    Key? key,
    required this.initialAge,
    required this.onAgeChanged,
  }) : super(key: key);

  @override
  _AgePickerScreenState createState() => _AgePickerScreenState();
}

class _AgePickerScreenState extends State<AgePickerScreen> {
  late int _age;

  @override
  void initState() {
    super.initState();
    _age = widget.initialAge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bir Yaş Seçin'),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const SizedBox(height: 20),
            NumberPicker(
              minValue: 1,
              maxValue: 120,
              value: _age,

              axis: Axis.horizontal,
              onChanged: (value) {
                setState(() {
                  _age = value;
                });
              },
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onAgeChanged(_age);
          Navigator.pop(context);
        },

        child: const Icon(Icons.check,color: Colors.white,),

        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
