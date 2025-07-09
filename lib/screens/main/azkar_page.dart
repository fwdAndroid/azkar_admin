import 'package:azkar_admin/screens/view/view_azkar.dart';
import 'package:azkar_admin/widget/azkar_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';

class AzkarPage extends StatefulWidget {
  const AzkarPage({super.key});

  @override
  State<AzkarPage> createState() => _AzkarPageState();
}

class _AzkarPageState extends State<AzkarPage> {
  late HijriCalendar _hijriDate;

  @override
  void initState() {
    super.initState();
    _hijriDate = HijriCalendar.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hijri Date",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "${_hijriDate.toFormat("dd MMMM, yyyy")} AH",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            //Morning
            AzkarTitleWidget(
              image: "assets/star.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) =>
                      ViewAzkarPage(azkarType: 'morningazkaar'),
                ),
              ),
              text: "أذكار الصباح",
            ),
            //Evening
            AzkarTitleWidget(
              image: "assets/evening.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) =>
                      ViewAzkarPage(azkarType: 'eveningazkaar'),
                ),
              ),
              text: "أذكار المساء",
            ),
            //Night
            AzkarTitleWidget(
              image: "assets/night.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => ViewAzkarPage(azkarType: 'nightAzkar'),
                ),
              ),
              text: "أذكار النوم",
            ),
            //After the prayers
            AzkarTitleWidget(
              image: "assets/mosque.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => ViewAzkarPage(azkarType: 'afterPrayer'),
                ),
              ),
              text: "بعد الصلوات",
            ),
            //Confronting a metaphor
            AzkarTitleWidget(
              image: "assets/books.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) => ViewAzkarPage(azkarType: 'metaphor'),
                ),
              ),
              text: "مواجهة تشبيه",
            ),
            //Benefits
            AzkarTitleWidget(
              image: "assets/benefit.png",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (builder) =>
                      ViewAzkarPage(azkarType: 'azkarbenefits'),
                ),
              ),
              text: "فوائد الأذكار",
            ),
          ],
        ),
      ),
    );
  }
}
