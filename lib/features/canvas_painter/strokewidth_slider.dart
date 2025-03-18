import 'package:flutter/material.dart';
showDialogForStrokeWidth(BuildContext context, double strokeWidth, Function(double) onChanged, ) {
 showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Select Stroke Width'),
                      content: StrokeWidthSlider(
                        strokeWidth: strokeWidth,
                        onChanged: (value) {
                          onChanged(value);
                          
                         
                          Navigator.of(context).pop();
                        },
                      ),
                      
                    );
                  },
                );
}
class StrokeWidthSlider extends StatefulWidget {
  final double strokeWidth;
  final Function(double) onChanged;
  const StrokeWidthSlider({super.key, required this.strokeWidth, required this.onChanged});

  @override
  State<StrokeWidthSlider> createState() => _StrokeWidthSliderState();
}

class _StrokeWidthSliderState extends State<StrokeWidthSlider> {
  double _strokeWidth = 0.0;
  @override
  void initState() {
    super.initState();
    _strokeWidth = widget.strokeWidth;
  }
  @override
  void didUpdateWidget(covariant StrokeWidthSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    _strokeWidth = widget.strokeWidth;
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
                                value: _strokeWidth,
                                min: 1.0,
                                max: 10.0,
                                onChanged: (value) {
                                  setState(() {
                                    _strokeWidth = value;
                                  });
                                  // widget.onChanged(value);
                                },
                              ),
                             const SizedBox(height: 10),
                              TextButton(
                          onPressed: () {
                            widget.onChanged(_strokeWidth);
                          },
                          child: const Text('OK'),
                        ),
          ],
        ),
      ),
    );
  }
}