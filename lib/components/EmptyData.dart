import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eta_school_app/API/client.dart';
import 'package:eta_school_app/controllers/Helpers.dart';

class EmptyData extends StatefulWidget {
  const EmptyData({super.key, this.title, this.text});

  final title;
  final text;

  @override
  State<EmptyData> createState() => _EmptyDataState();
}

class _EmptyDataState extends State<EmptyData> with MediansTheme {
  HttpService httpService = HttpService();

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Container(
            width: double.infinity,
            color: activeTheme.main_bg,
            child: Column(children: [
              Container(
                  width: MediaQuery.of(context).size.width - 100,
                  decoration: ShapeDecoration(
                    color: activeTheme.main_color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  margin: const EdgeInsets.only(top: 100),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      child: SvgPicture.asset('assets/svg/map_locations.svg'),
                    ),
                    const SizedBox(height: 20),
                    Text(widget.title,
                        style: TextStyle(
                            color: activeTheme.main_color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text(widget.text,
                        style: TextStyle(
                            color: activeTheme.main_color, fontSize: 16)),
                    const SizedBox(height: 20),
                  ])),
              const SizedBox(height: 20),
              //  buttonText(openPage, 0, lang.translate('Back'))
            ])));
  }

  openPage(index) {
    setState(() {
      Get.back();
    });
  }
}
