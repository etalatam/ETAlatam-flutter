import 'package:flutter/material.dart';

Widget buttonText(callback, index, text)
{
  return Center(
        child:
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: 
              GestureDetector(
                onTap: (() {
                  callback(index);
                }),
                child: Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
        )
  );
}
