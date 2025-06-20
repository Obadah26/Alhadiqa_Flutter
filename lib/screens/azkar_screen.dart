import 'package:alhadiqa/const.dart';
import 'package:alhadiqa/screens/home_screen.dart';
import 'package:alhadiqa/widgets/green_contatiner.dart';
import 'package:alhadiqa/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:alhadiqa/lists.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});
  static String id = 'azkar_screen';
  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  int _currentIndex = 0;
  bool _isMorning = true;
  int _currentCount = 0;

  Map<String, Map<String, dynamic>> get currentAzkar =>
      _isMorning ? azkarAsbah : azkarAlmasa;
  List<String> get currentTitles => currentAzkar.keys.toList();

  void _resetCount() {
    final repeats =
        currentAzkar[currentTitles[_currentIndex]]?['عدد التكرار'] ?? 1;
    setState(() {
      _currentCount = repeats;
    });
  }

  void _nextZikr() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % currentTitles.length;
      _resetCount();
    });
  }

  void _previousZikr() {
    setState(() {
      _currentIndex = (_currentIndex - 1) % currentTitles.length;
      _resetCount();
    });
  }

  void _toggleAzkarType() {
    setState(() {
      _isMorning = !_isMorning;
      _currentIndex = 0;
      _resetCount();
    });
  }

  void _decrementCount() {
    setState(() {
      if (_currentCount > 0) {
        _currentCount--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = currentTitles[_currentIndex];
    final text = currentAzkar[title]?['النص'] ?? '';
    final repeats = currentAzkar[title]?['عدد التكرار'] ?? 1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: () => Navigator.popAndPushNamed(context, HomeScreen.id),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 35,
              color: kDarkPrimaryColor,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kLightPrimaryColor, width: 2),
              ),
              child: IconButton(
                onPressed: _previousZikr,
                icon: Icon(Icons.arrow_back, color: kLightPrimaryColor),
              ),
            ),
            SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kLightPrimaryColor, width: 2),
              ),
              child: IconButton(
                onPressed: _nextZikr,
                icon: Icon(Icons.arrow_forward, color: kLightPrimaryColor),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 600;
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RoundedButton(
                        width: 150,
                        onPressed: _isMorning ? null : _toggleAzkarType,
                        buttonText: 'أذكار الصباح',
                        isPrimary: _isMorning ? true : false,
                      ),
                      const SizedBox(width: 16),
                      RoundedButton(
                        width: 150,
                        onPressed: _isMorning ? _toggleAzkarType : null,
                        buttonText: 'أذكار المساء',
                        isPrimary: _isMorning ? false : true,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _isMorning ? 'أذكار الصباح' : 'أذكار المساء',
                    style: GoogleFonts.elMessiri(
                      textStyle: kHeading1Text.copyWith(
                        color: kDarkPrimaryColor,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Center(
                      child: GreenContatiner(
                        width: isWeb ? 800 : double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.cairo(
                                  textStyle: kHeading2Text.copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Divider(color: kLightPrimaryColor),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  text,
                                  style:
                                      title.startsWith('سورة') ||
                                              title.startsWith('آية')
                                          ? GoogleFonts.notoKufiArabic(
                                            textStyle: kBodyLargeText.copyWith(
                                              fontSize: 22,
                                              height: 1.7,
                                            ),
                                          )
                                          : GoogleFonts.cairo(
                                            textStyle: kBodyLargeText.copyWith(
                                              fontSize: 22,
                                              height: 1.7,
                                            ),
                                          ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                'عدد التكرار المتبقي: $_currentCount من $repeats',
                                style: GoogleFonts.cairo(
                                  textStyle: kBodyRegularText.copyWith(
                                    color: kLightPrimaryColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              RoundedButton(
                                onPressed: _decrementCount,
                                buttonText: 'تم',
                                width: 100,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
