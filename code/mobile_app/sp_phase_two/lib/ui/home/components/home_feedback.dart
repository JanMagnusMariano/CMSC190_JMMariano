import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../blocs/report_data/bloc.dart';
import '../../../utils/session_services.dart';
import 'weather_widgets.dart';
import '../../authenticate/components/auth_appbar.dart';

import '../../global_widgets.dart';

class HomeFeedback extends StatefulWidget {
  @override
  State<HomeFeedback> createState() => _HomeFeedbackState();
}

class _HomeFeedbackState extends State<HomeFeedback> {
  Future<File> _uploadImage;
  String base64Image;
  File tmpFile;

  selectImage() {
    setState(() {
       _uploadImage = ImagePicker.pickImage(source: ImageSource.gallery);
    });
  }

  submitImage() {
    if(tmpFile == null) {
      print('No file selected!');
      return;
    }

    BlocProvider.of<ReportDataBloc>(context).add(SubmitReport(
      imageFile: File(tmpFile.path),
      location: SessionServices().currCityRaw,
      description: 'Submission'
    ));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<ReportDataBloc, ReportDataState>(
        buildWhen: (ReportDataState prev, ReportDataState curr) {
          if (prev is ReportEmpty && curr is ReportLoading) {
            GlobalWidgets.loadingOverlay(context);
          } else if (prev is ReportLoading && curr is ReportEmpty) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              if (Navigator.of(context).canPop()) Navigator.pop(context, 'dialog');
              Navigator.pop(context);
            });
          }

          return true;
        },
        builder: (context, state) {
          return Column(
            children: <Widget>[
              WeatherWidgets.customButton(selectImage , 'Select Image'),
              showImage(),
              WeatherWidgets.customButton(submitImage , 'Submit Image'),
            ],
          );
        }
      ),
      // body: Column(
        // children: <Widget>[
        //   WeatherWidgets.customButton(selectImage , 'Select Image'),
        //   showImage(),
        //   WeatherWidgets.customButton(submitImage , 'Submit Image'),
        // ],
      // ),
    );
  }

  Widget showImage() {
    return FutureBuilder<File>(
      future: _uploadImage,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done && null != snapshot.data) {
          tmpFile = File(snapshot.data.path);
          base64Image = base64Encode(File(tmpFile.path).readAsBytesSync());
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Image.file(
                  File(snapshot.data.path),
                  fit: BoxFit.fill,
                ),
              ),
            ],
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else return Container();
      },
    );
  }
}
