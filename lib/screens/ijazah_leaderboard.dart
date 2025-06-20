import 'package:alhadiqa/const.dart';
import 'package:alhadiqa/screens/home_screen.dart';
import 'package:alhadiqa/widgets/green_contatiner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:alhadiqa/lists.dart';

class IjazahLeaderboardScreen extends StatefulWidget {
  const IjazahLeaderboardScreen({super.key, this.userName});
  static String id = 'ijazah_leaderboard_screen';
  final String? userName;

  @override
  State<IjazahLeaderboardScreen> createState() =>
      _IjazahLeaderboardScreenState();
}

class _IjazahLeaderboardScreenState extends State<IjazahLeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Center(
          child: Text(
            'نتائج الإجازة',
            style: GoogleFonts.elMessiri(
              textStyle: kHeading2Text.copyWith(color: kPrimaryColor),
            ),
            textAlign: TextAlign.right,
          ),
        ),
        actions: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                FlutterIslamicIcons.muslim2,
                size: 35,
                color: kPrimaryColor,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: Center(
                    child: GreenContatiner(
                      width: isWeb ? 600 : double.infinity,
                      child: StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('ijazah_recitation')
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('حدث خطأ: ${snapshot.error}'),
                            );
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد تسميعات مسجلة بعد',
                                style: GoogleFonts.cairo(
                                  textStyle: kBodyRegularText,
                                ),
                              ),
                            );
                          }

                          Map<String, int> pagesPerName = {};
                          Map<String, DateTime?> completionDates = {};

                          for (var name in ijazahStudents) {
                            pagesPerName[name] = 0;
                            completionDates[name] = null;
                          }

                          for (var doc in snapshot.data!.docs) {
                            int firstPage =
                                doc['first_page'] is String
                                    ? int.tryParse(doc['first_page']) ?? 0
                                    : (doc['first_page'] as int? ?? 0);
                            int secondPage =
                                doc['second_page'] is String
                                    ? int.tryParse(doc['second_page']) ?? 0
                                    : (doc['second_page'] as int? ?? 0);
                            int pages = (secondPage - firstPage) + 1;

                            if (pages > 0) {
                              String? user = doc['user'];
                              if (user != null &&
                                  ijazahStudents.contains(user)) {
                                pagesPerName[user] =
                                    (pagesPerName[user] ?? 0) + pages;

                                if (pagesPerName[user]! >= 604 &&
                                    completionDates[user] == null) {
                                  Timestamp? timestamp =
                                      doc['timestamp'] as Timestamp?;
                                  if (timestamp != null) {
                                    completionDates[user] = timestamp.toDate();
                                  }
                                }
                              }
                            }
                          }

                          ijazahStudents.sort(
                            (a, b) => (pagesPerName[b] ?? 0).compareTo(
                              pagesPerName[a] ?? 0,
                            ),
                          );

                          return ListView.builder(
                            itemCount: ijazahStudents.length,
                            itemBuilder: (context, index) {
                              String name = ijazahStudents[index];
                              int totalPages = pagesPerName[name] ?? 0;
                              double progressPercentage =
                                  (totalPages / 604 * 100)
                                      .clamp(0, 100)
                                      .toDouble();
                              bool completed = totalPages >= 604;
                              DateTime? completionDate = completionDates[name];

                              return Card(
                                elevation: 2,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: kSecondaryBorderColor,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  title: Text(
                                    name,
                                    style: GoogleFonts.cairo(
                                      textStyle: kBodyRegularText.copyWith(
                                        fontSize: isWeb ? 22 : 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  subtitle:
                                      completed && completionDate != null
                                          ? Text(
                                            textAlign: TextAlign.right,
                                            DateFormat(
                                              'EEEE، d MMMM y',
                                              'ar',
                                            ).format(completionDate),
                                            style: GoogleFonts.cairo(
                                              textStyle: kBodySmallTextDark
                                                  .copyWith(
                                                    fontSize: isWeb ? 17 : 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: kLightPrimaryColor,
                                                  ),
                                            ),
                                          )
                                          : totalPages == 0
                                          ? Text(
                                            'لم يبدأ بعد',
                                            style: GoogleFonts.cairo(
                                              textStyle: kBodySmallTextDark
                                                  .copyWith(
                                                    fontSize: isWeb ? 17 : 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: kLightPrimaryColor,
                                                  ),
                                            ),
                                            textAlign: TextAlign.right,
                                          )
                                          : Text(
                                            'صفحة $totalPages',
                                            style: GoogleFonts.cairo(
                                              textStyle: kBodySmallTextDark
                                                  .copyWith(
                                                    fontSize: isWeb ? 17 : 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: kLightPrimaryColor,
                                                  ),
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                  leading: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child:
                                        completed
                                            ? Icon(
                                              Icons.check_circle,
                                              color: kSecondaryColor,
                                              size: isWeb ? 48 : 40,
                                            )
                                            : SimpleCircularProgressBar(
                                              size: isWeb ? 60 : 50,
                                              valueNotifier: ValueNotifier(
                                                progressPercentage,
                                              ),
                                              progressStrokeWidth:
                                                  isWeb ? 6 : 5,
                                              backStrokeWidth: isWeb ? 6 : 5,
                                              mergeMode: true,
                                              onGetText: (value) {
                                                return Text(
                                                  '${value.toInt()}%',
                                                  style: GoogleFonts.cairo(
                                                    textStyle: TextStyle(
                                                      fontSize:
                                                          isWeb ? 14.5 : 12,
                                                      color: kSecondaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              },
                                              progressColors: const [
                                                kSecondaryColor,
                                              ],
                                              backColor: Color.fromRGBO(
                                                158,
                                                158,
                                                158,
                                                0.3,
                                              ),
                                            ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
