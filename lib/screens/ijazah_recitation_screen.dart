import 'package:alhadiqa/const.dart';
import 'package:alhadiqa/screens/home_screen.dart';
import 'package:alhadiqa/widgets/green_contatiner.dart';
import 'package:alhadiqa/widgets/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:alhadiqa/widgets/rounded_text_field.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IjazahRecitationScreen extends StatefulWidget {
  const IjazahRecitationScreen({super.key, this.userName});
  static String id = 'ijazah_recitation_screen';
  final String? userName;

  @override
  State<IjazahRecitationScreen> createState() => _IjazahRecitationScreenState();
}

class _IjazahRecitationScreenState extends State<IjazahRecitationScreen> {
  final TextEditingController _firstPageController = TextEditingController();
  final TextEditingController _secondPageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _firstPageController.dispose();
    _secondPageController.dispose();
    super.dispose();
  }

  void saveData() async {
    String? userName = widget.userName;
    String firstPage = _firstPageController.text;
    String secondPage = _secondPageController.text;

    if (userName == null || firstPage.isEmpty || secondPage.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('الرجاء ملء جميع الحقول')));
      return;
    }

    try {
      Map<String, dynamic> data = {
        'user': userName,
        'first_page': int.tryParse(firstPage) ?? 0,
        'second_page': int.tryParse(secondPage) ?? 0,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('ijazah_recitation')
          .add(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم حفظ البيانات بنجاح!')));

      _firstPageController.clear();
      _secondPageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في حفظ البيانات: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            'تسميع الاجازة',
            style: GoogleFonts.elMessiri(
              textStyle: kHeading2Text.copyWith(color: kPrimaryColor),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  FlutterIslamicIcons.muslim2,
                  size: 35,
                  color: kPrimaryColor,
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        toolbarHeight: 100,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                HomeScreen.id,
                (route) => false,
              );
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 35,
              color: kPrimaryColor,
            ),
          ),
        ),
      ),
      backgroundColor: kBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWeb = constraints.maxWidth > 600;
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: isWeb ? 50 : 100),
                  Center(
                    child: GreenContatiner(
                      width: isWeb ? 600 : double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  ': اضافة تسميع',
                                  style: GoogleFonts.cairo(
                                    textStyle: kBodyRegularText.copyWith(
                                      fontSize: isWeb ? 24 : 20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RoundedTextField(
                                    controller: _firstPageController,
                                    obscure: false,
                                    textColor: kPrimaryTextLight,
                                    textHint: '312',
                                    keyboardType: TextInputType.number,
                                    width: 150,
                                    height: 50,
                                    hintColor: kSecondaryTextLight.withValues(
                                      alpha: (0.199 * 255),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'من صفحة',
                                      style: GoogleFonts.cairo(
                                        textStyle: kBodyRegularText.copyWith(
                                          fontSize: isWeb ? 19 : 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RoundedTextField(
                                    controller: _secondPageController,
                                    obscure: false,
                                    textColor: kPrimaryTextLight,
                                    textHint: '330',
                                    keyboardType: TextInputType.number,
                                    width: 150,
                                    height: 50,
                                    hintColor: kSecondaryTextLight.withValues(
                                      alpha: (0.199 * 255),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      'الى صفحة',
                                      style: GoogleFonts.cairo(
                                        textStyle: kBodyRegularText.copyWith(
                                          fontSize: isWeb ? 19 : 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 50),
                              Center(
                                child: RoundedButton(
                                  buttonText: 'حفظ',
                                  isPrimary: false,
                                  onPressed: saveData,
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
