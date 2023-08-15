import 'dart:io';
import 'package:face_detection/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:face_detection/image_data.dart';

class GalleryView extends StatefulWidget {
  GalleryView(
      {Key? key,
      required this.title,
      this.text,
      required this.onImage,
      required this.onDetectorViewModeChanged,
      required this.imageData})
      : super(key: key);

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;
  final List<ImageData> imageData;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  List<Container> getImagesData() {
    List<Container> images = [];
    for (var i = 0; i < widget.imageData.length; i++) {
      images.add(
        Container(
          margin: EdgeInsets.all(10),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey,
          ),
          child: Text('${widget.imageData[i].faceID}'),
        ),
      );
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: widget.onDetectorViewModeChanged,
                child: Icon(
                  Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
                ),
              ),
            ),
          ],
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Container(
              padding: EdgeInsets.all(5),
              child: SizedBox(
                height: 400,
                width: 400,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.file(_image!),
                  ],
                ),
              ),
            )
          : Icon(
              Icons.image,
              size: 200,
              color: Colors.blueGrey,
            ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text(
            'From Gallery',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
          ),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text(
            'Take a picture',
            style: GoogleFonts.lato(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
          ),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
              child: widget.imageData.length > 0
                  ? Text(
                      '${widget.imageData.length} Face(s) Detected! Click to view info')
                  : const Text('No Faces Detected'),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        color: Color(0xFF737373),
                        child: Container(
                            padding: EdgeInsets.all(10),
                            height: 500,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  // width: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SizedBox(
                                    height: 7,
                                    width: 100,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    // the number of items in the list
                                    itemCount: widget.imageData.length,

                                    // display each item of the product list
                                    itemBuilder: (context, index) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 15),
                                        padding: EdgeInsets.all(5),
                                        child: ImageDataTable(
                                          faceID: widget.imageData[index].faceID
                                              .toString(),
                                          smileProbability: widget
                                              .imageData[index]
                                              .smilingProbability
                                              .toString(),
                                          leftEyeOpenProbability: widget
                                              .imageData[index]
                                              .leftEyeOpenProbability
                                              .toString(),
                                          rightEyeOpenProbability: widget
                                              .imageData[index]
                                              .rightEyeOpenProbability
                                              .toString(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   mainAxisSize: MainAxisSize.min,
                            //   crossAxisAlignment: CrossAxisAlignment.stretch,
                            //   children: getImagesData(),
                            // ),
                            ),
                      );
                    });
              }),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _processFile(String path) async {
    setState(() {
      _image = File(path);
    });
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}

class ImageDataTable extends StatelessWidget {
  ImageDataTable(
      {super.key,
      required this.faceID,
      required this.smileProbability,
      required this.leftEyeOpenProbability,
      required this.rightEyeOpenProbability});

  final String faceID;
  final String smileProbability;
  final String leftEyeOpenProbability;
  final String rightEyeOpenProbability;

  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.black,
        style: BorderStyle.solid,
        width: 2,
      ),
      children: [
        TableRow(children: [
          RowValue(value: 'Face ID'),
          RowValue(value: faceID),
        ]),
        TableRow(children: [
          RowValue(value: 'Smile Probability'),
          RowValue(value: smileProbability),
        ]),
        TableRow(children: [
          RowValue(value: 'Left Eye Open Probability'),
          RowValue(value: leftEyeOpenProbability),
        ]),
        TableRow(children: [
          RowValue(value: 'Right Eye Open Probability'),
          RowValue(value: rightEyeOpenProbability),
        ]),
      ],
    );
  }
}

class RowValue extends StatelessWidget {
  RowValue({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          Text(
            value,
            style: rowTextStyle,
          ),
        ],
      ),
    );
  }
}

// Padding(
// padding: const EdgeInsets.all(16.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// '${_path == null ? '' : 'Image path: $_path'}\n\n',
// style: GoogleFonts.lato(
// textStyle: const TextStyle(
// fontWeight: FontWeight.bold,
// color: Colors.black,
// ),
// ),
// ),
// Text(widget.text ?? '')
// ],
// ),
// ),
