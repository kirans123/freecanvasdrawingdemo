import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:login_demo/features/canvas_painter/strokewidth_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<DrawingPoint> points = [];
  List<DrawingPoint> undonePoints = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 3.0;

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      points.add(DrawingPoint(
          offset,
          Paint()
            ..color = selectedColor
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round));
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final renderBox = context.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      points.add(DrawingPoint(
          offset,
          Paint()
            ..color = selectedColor
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round));
    });
  }

  void _undo() {
    setState(() {
      if (points.isNotEmpty) {
        undonePoints.add(points.removeLast());
      }
    });
  }

  void _redo() {
    setState(() {
      if (undonePoints.isNotEmpty) {
        points.add(undonePoints.removeLast());
      }
    });
  }

  void _clearCanvas() {
    setState(() {
      points.clear();
      undonePoints.clear();
    });
  }

  Future<void> _saveImage() async {
    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final size = MediaQuery.of(context).size;
    final customPainter = DrawingPainter(points);
    customPainter.paint(canvas, size);
    final picture = pictureRecorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    if (Platform.isAndroid || Platform.isIOS) {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final result = await ImageGallerySaver.saveImage(pngBytes,
            quality: 100,
            name: 'drawing_${DateTime.now().millisecondsSinceEpoch}');
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image saved to gallery')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final imagePath =
            '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(imagePath);
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to $imagePath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redo,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: GestureDetector(
        onPanStart: _handlePanStart,
        onPanUpdate: _handlePanUpdate,
        child: CustomPaint(
          painter: DrawingPainter(points),
          size: Size.infinite,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.color_lens),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Select Color'),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          onColorChanged: (color) {
                            setState(() {
                              selectedColor = color;
                            });
                            Navigator.of(context).pop();
                          },
                          selectedColor: selectedColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.line_weight),
              onPressed: () {
                showDialogForStrokeWidth(context, strokeWidth, (value) {
                  setState(() {
                    strokeWidth = value;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i].offset, points[i + 1].offset, points[i].paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint(this.offset, this.paint);
}

class ColorPicker extends StatefulWidget {
  final Function(Color) onColorChanged;
  final Color selectedColor;

  const ColorPicker(
      {super.key, required this.onColorChanged, required this.selectedColor});

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: Colors.primaries.map((color) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedColor = color;
            });
            widget.onColorChanged(selectedColor);
          },
          child: Container(
            margin: const EdgeInsets.all(8.0),
            width: 30.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: selectedColor == color
                  ? Border.all(color: Colors.black, width: 2.0)
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
