import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettings extends StatefulWidget {
  static const String routeName = '/device-android';

  const VoiceSettings({super.key});

  @override
  State<VoiceSettings> createState() => _VoiceSettingsState();
}

enum TtsState { playing, stopped, paused, continued }

class _VoiceSettingsState extends State<VoiceSettings> {
  late FlutterTts flutterTts;
  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  String? _newVoiceText;
  int? _inputLength;
  String _selectedVoiceType = 'Kadın Sesi';

  final double _minVolume = 0.2;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  @override
  void initState() {
    super.initState();
    initTts();
    _loadSettings();
  }

  dynamic initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _speak() async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (_newVoiceText != null) {
      if (_newVoiceText!.isNotEmpty) {
        await flutterTts.speak(_newVoiceText!);
      }
    }
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedVoiceType = prefs.getString('selectedVoiceType') ?? 'Kadın Sesi';
      volume = prefs.getDouble('volume') ?? 0.5;
      pitch = prefs.getDouble('pitch') ?? 1.0;
      rate = prefs.getDouble('rate') ?? 0.5;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    }
  }



  void changedEnginesDropDownItem(String? selectedEngine) async {
    await flutterTts.setEngine(selectedEngine!);
    language = null;
    setState(() {
      engine = selectedEngine;
    });
  }

  List<DropdownMenuItem<String>> getLanguageDropDownMenuItems(List<dynamic> languages) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in languages) {
      items.add(DropdownMenuItem(value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  void changedLanguageDropDownItem(String? selectedType) {
    setState(() {
      language = selectedType;
      flutterTts.setLanguage(language!);
      if (isAndroid) {
        flutterTts.isLanguageInstalled(language!).then((value) => isCurrentLanguageInstalled = (value as bool));
      }
    });
  }
  Future<dynamic> _getEngines() async => await flutterTts.getEngines;


  void _onChange(String text) {
    setState(() {
      _newVoiceText = text;
    });
  }
  Widget _engineSection() {
    if (isAndroid) {
      return FutureBuilder<dynamic>(
          future: _getEngines(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              return _enginesDropDownSection(snapshot.data as List<dynamic>);
            } else if (snapshot.hasError) {
              return const Text('Hata Oldu :(');
            } else
              return const Text('Motorlar Yükleniyor...');
          });
    } else
      return Container(width: 0, height: 0);
  }

  Widget _enginesDropDownSection(List<dynamic> engines) => Container(
    padding: const EdgeInsets.only(top: 50.0),
    child: DropdownButton(
      hint: Text('Ses Motoru'),
      value: engine,
      items: getEnginesDropDownMenuItems(engines),
      onChanged: changedEnginesDropDownItem,
    ),
  );
  
  List<DropdownMenuItem<String>> getEnginesDropDownMenuItems(
      List<dynamic> engines) {
    var items = <DropdownMenuItem<String>>[];
    for (dynamic type in engines) {
      items.add(DropdownMenuItem(
          value: type as String?, child: Text((type as String))));
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seslendirme Ayarları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
           Text('Ses Motorunu Seçin'),
            const Text('Bu ayarı zorunda olmadıkça değiştirmeyin.', style: TextStyle(color: Colors.grey)),

            Center(child: _engineSection()),

            const Divider(),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ses Seviyesi:'),
                  Slider(
                    value: volume,
                    min: _minVolume,
                    max: 1.0,
                    divisions: 10,
                    label: volume.toStringAsFixed(1),
                    onChanged: (double value) {
                      if (value >= _minVolume) {
                        setState(() {
                          volume = value;
                        });
                        _saveSetting('volume', value);
                        flutterTts.setVolume(value);
                      }
                    },
                  ),
                ],
              ),
            ),
            const Text('Ses seviyesini tamamen kapatamazsınız ama azaltabilirsiniz.', style: TextStyle(color: Colors.grey)),

            const Divider(),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ses Yüksekliği'),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    label: pitch.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        pitch = value;
                      });
                      _saveSetting('pitch', value);
                      flutterTts.setPitch(value);
                    },
                  ),
                ],
              ),
            ),

            const Divider(),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ses Hızı:'),
                  Slider(
                    value: rate,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: rate.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        rate = value;
                      });
                      _saveSetting('rate', value);
                      flutterTts.setSpeechRate(value);
                    },
                  ),
                ],
              ),
            ),

            const Divider(),




          ],
        ),
      ),
    );
  }
}
