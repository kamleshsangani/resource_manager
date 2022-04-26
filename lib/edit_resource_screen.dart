import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resource_manager/resource_item.dart';
import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:resource_manager/text_dialog_widget.dart';

class EditResourceScreen extends StatefulWidget {
  const EditResourceScreen({Key? key,}) : super(key: key);

  @override
  State<EditResourceScreen> createState() => _EditResourceScreenState();
}

class _EditResourceScreenState extends State<EditResourceScreen> {

  static const String _tabEnglish = "English";
  static const String _tabArabicJO = "Arabic (JO)";
  static const String _tabArabicAE = "Arabic (AE)";
  static const String _tabArabicEG = "Arabic (EG)";
  static const String _tabArabicPL = "Arabic (PL)";
  static const String _tabArabicSE = "Arabic (SE)";

  final List<String> _supportedLanguages = [
    _tabEnglish,
    _tabArabicJO,
    _tabArabicAE,
    _tabArabicEG,
    _tabArabicPL,
    _tabArabicSE,
  ];

  final List<ResourceItem> _englishResources = List.empty(growable: true);
  static const double _verticalPadding = 20.0;
  static const double _horizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _supportedLanguages.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Arabi Next Text Resources"),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Export Json file',
              onPressed: () {
                _displayExportMenu();
              },
            ),
            const SizedBox(width: _horizontalPadding / 2 ,)
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.green,
            indicatorWeight: 5,
            labelPadding: const EdgeInsets.symmetric(horizontal: 30),
            tabs: _supportedLanguages.map((e) {
              return Tab(text: e,);
            }).toList(),
          ),
        ),
        body:  TabBarView(
          children: [
            _getResourceTable(context),
            _getResourceTable(context),
            _getResourceTable(context),
            _getResourceTable(context),
            _getResourceTable(context),
            _getResourceTable(context),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _importResourceFile,
          tooltip: 'Import Resource',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _getResourceTable(BuildContext context) {
    return  ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: _verticalPadding * 3),
        itemCount: _englishResources.length,
        itemBuilder: (BuildContext context, int index) {
          ResourceItem e = _englishResources[index];
          return Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: _verticalPadding,),
                  SizedBox(width: 250, child:  Text(e.resourceId),),
                  const SizedBox(width: _verticalPadding,),
                  Expanded(child: Text(e.resourceText),),
                  const SizedBox(width: _verticalPadding,),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit resource',
                    onPressed: () {
                      _editTextResource(e);
                    },
                  ),
                  const SizedBox(width: _verticalPadding,),
                ],
              ),
              const Divider(),
            ],
          );
        });
  }

  void _importResourceFile() async {
    List<PlatformFile>? selectedPaths;
    try {
      selectedPaths = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) {
          if (kDebugMode) {
            print(status);
          }
        },
        allowedExtensions: ["json"],
      ))?.files;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Unsupported operation' + e.toString());
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (!mounted) return;
    if(selectedPaths != null && selectedPaths.isNotEmpty) {
      setState(() {
        PlatformFile selectedPlatformFile = selectedPaths!.first;
        String fileData =  String.fromCharCodes(selectedPlatformFile.bytes!);
        Map<String, dynamic> resources = json.decode(fileData);
        resources.forEach((key, value) {
          _englishResources.add(ResourceItem(resourceId: key, resourceText: value));
        });
      });
    }
  }

  void _editTextResource(ResourceItem e) async {
    final resourceText = await showTextInputDialog<String>(
      context,
      value: e.resourceText,
    );

    if(resourceText != null) {
      setState(() {
        e.resourceText = resourceText;
      });
    }
  }

  void _displayExportMenu() async {
    _showBottomSheetMenuDialog(context);
  }

  void _showBottomSheetMenuDialog(BuildContext context){
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text("Select Platform"),
          content: const Text( "Select platform for which you want to download resource file"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text("Flutter"),
              onPressed: () {
                Navigator.of(context).pop();
                _exportResourceFile();
              },),
            CupertinoDialogAction(
              child: const Text("Android"),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorry, This platform is not supported yet')));
              },),
            CupertinoDialogAction(
              child: const Text("iOS"),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorry, This platform is not supported yet')));
              },),
          ],
        ));
  }

  void _exportResourceFile() async {
    Map<String, dynamic> resources = {};
    for (var element in _englishResources) {
      resources.putIfAbsent(element.resourceId, () => element.resourceText);
    }
    String exportString = json.encode(resources);
    _saveJsonFile(exportString);
  }

  void _saveJsonFile(String data) async {
    await FileSaver.instance.saveFile("en", Uint8List.fromList(data.codeUnits), "json", mimeType: MimeType.JSON);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File exported successfully')));
  }
}
