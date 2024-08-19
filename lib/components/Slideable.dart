/*
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import 'package:MediansSchoolDriver/controllers/Helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:MediansSchoolDriver/methods.dart';

class Slideable extends StatelessWidget {
  const Slideable(
      {super.key,
      this.model,
      required this.hasLeft,
      required this.hasRight,
      required this.widget,
      this.finishCallback});

  final model;
  final Widget widget;
  final bool hasLeft;
  final bool hasRight;

  final Function? finishCallback;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(0),

      // The start action pane is the one at the left or the top side.
      startActionPane: !hasRight
          ? null
          : ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const ScrollMotion(),

              dragDismissible: false,

              // A pane can dismiss the Slidable.
              dismissible: DismissiblePane(onDismissed: () {}),

              // All actions are defined in the children parameter.
              children: [
                finishCallback == null
                    ? SlidableAction(
                        // An action can be bigger than the others.
                        onPressed: ((context) => doNothing('WhatsApp')),
                        backgroundColor: const Color(0xFF7BC043),
                        foregroundColor: Colors.white,
                        icon: Icons.maps_ugc_outlined,
                        label: lang.translate('WhatsApp'),
                      )
                    // A SlidableAction can have an icon and/or a label.
                    : SlidableAction(
                        onPressed: ((context) => doNothing('finish')),
                        backgroundColor: const Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.edit_location_sharp,
                        label: lang.translate('Pickup done'),
                      ),
              ],
            ),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: !hasLeft
          ? null
          : ActionPane(
              motion: ScrollMotion(),
              children: [
                SlidableAction(
                  // An action can be bigger than the others.
                  onPressed: ((context) => doNothing('WhatsApp')),
                  backgroundColor: const Color(0xFF7BC043),
                  foregroundColor: Colors.white,
                  icon: Icons.maps_ugc_outlined,
                  label: lang.translate('WhatsApp'),
                ),
                SlidableAction(
                  onPressed: ((context) => doNothing('call')),
                  backgroundColor: const Color(0xFF0392CF),
                  foregroundColor: Colors.white,
                  icon: Icons.call,
                  label: lang.translate('Call'),
                ),
              ],
            ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: widget,
    );
  }

  doNothing(dynamic val) {
    switch (val) {
      case 'call':
        model.contact_number.isNotEmpty ? launchCall(model.contact_number) : '';
        break;
      case 'WhatsApp':
        model.contact_number.isNotEmpty ? launchWP(model.contact_number) : '';
        break;
      case 'finish':
        finishCallback!(model);
        break;
      default:
    }
    return null;
  }
}
