import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SlideAction extends StatelessWidget {
  const SlideAction(this.actions, this.widget, {super.key});

  final Widget widget;
  final List<SlidableAction>? actions;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(10),
      closeOnScroll: true,

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: actions!,
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: widget,
    );
  }
}
