import 'package:eta_school_app/Models/HelpMessageModel.dart';
import 'package:flutter/material.dart';
import 'package:eta_school_app/controllers/helpers.dart';

class CommentBlock extends StatelessWidget {
  const CommentBlock(this.comment, {super.key});

  final CommentModel comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        Container(
          width: double.infinity,
          // height: 446.03,
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.all(10),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(
                    width: 1, color: activeTheme.main_color.withOpacity(.2))),
            color: activeTheme.main_bg,
            shadows: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                // height: 235,
                padding: const EdgeInsets.all(20),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Container(
                                constraints: const BoxConstraints(
                                    minWidth: 100, maxWidth: 290),
                                child: GestureDetector(
                                    onTap: (() => {}),
                                    child: Row(
                                      children: [
                                        // Container(
                                        //   width: 40,
                                        //   height: 40,
                                        //   decoration: ShapeDecoration(
                                        //     image: DecorationImage(
                                        //       image: NetworkImage(loadImage(
                                        //           "${comment.user!.photo}")),
                                        //       fit: BoxFit.fill,
                                        //     ),
                                        //     shape: RoundedRectangleBorder(
                                        //       borderRadius:
                                        //           BorderRadius.circular(50),
                                        //     ),
                                        //   ),
                                        // ),
                                        // const SizedBox(width: 10),
                                        Text(
                                          "${comment.user!.name}",
                                          style: activeTheme.normalText,
                                        ),
                                      ],
                                    )))),
                        Text(
                          "${comment.short_date}",
                          style: activeTheme.smallText,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        comment.comment!,
                        style: activeTheme.h5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
      ]),
    );
  }
}
