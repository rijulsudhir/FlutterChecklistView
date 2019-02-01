library checklist;

import 'package:checklist/checklist.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


typedef void OnDropItem(int oldListIndex,int oldItemIndex,int listIndex, int itemIndex, ChecklistItemViewState state);
typedef void OnTapItem(int listIndex, int itemIndex, ChecklistItemViewState state);
typedef void OnChanged(int listIndex, int itemIndex,bool val);
typedef void OnStartDragItem(
    int listIndex, int itemIndex, ChecklistItemViewState state);

class ChecklistItemView extends StatefulWidget{

  final ChecklistViewState checklist;
  final Widget title;
  final int index;
  final bool value;
  final OnDropItem onDropItem;
  final OnTapItem onTapItem;
  final OnChanged onChanged;
  final OnStartDragItem onStartDragItem;
  final Color backgroundColor;

  const ChecklistItemView({Key key, this.title,this.value, this.index, this.checklist, this.onDropItem, this.onTapItem, this.onStartDragItem,this.onChanged, this.backgroundColor}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChecklistItemViewState();
  }

}

class ChecklistItemViewState extends State<ChecklistItemView>{
  bool value = false;
  double height;
  double width;

  @override
  void initState() {
    super.initState();
    value = widget.value;
  }

  void onDropItem(int listIndex, int itemIndex) {
    if(listIndex != null && itemIndex != null && widget.checklist != null && widget.checklist.widget.checklistState.checklistStates != null && widget.checklist.widget.checklistState.checklistStates.length > listIndex) {
      widget.checklist.widget.checklistState.checklistStates[listIndex]
          .setState(() {
        if (widget.onDropItem != null) {
          widget.onDropItem(widget.checklist.widget.checklistState.oldListIndex,widget.checklist.widget.checklistState.oldItemIndex,listIndex, itemIndex, this);
        }
        widget.checklist.widget.checklistState.draggedItemIndex = null;
        widget.checklist.widget.checklistState.draggedListIndex = null;
      });
    }
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.checklist.widget.checklistState != null) {
      print("Item:${widget.index};List:${widget.checklist.widget.index}");
      widget.checklist.setState(() {
        widget.checklist.widget.checklistState.draggedItemIndex = widget.index;
        widget.checklist.widget.checklistState.height = context.size.height;
        widget.checklist.widget.checklistState.draggedListIndex =
            widget.checklist.widget.index;
        widget.checklist.widget.checklistState.draggedItem = item;
        widget.checklist.setState(() {
          widget.checklist.widget.checklistState.onDropItem = onDropItem;
        });
        if (widget.onStartDragItem != null) {
          widget.onStartDragItem(
              widget.checklist.widget.index, widget.index, this);
        }
        widget.checklist.widget.checklistState.oldListIndex = widget.checklist.widget.index;
        widget.checklist.widget.checklistState.oldItemIndex = widget.index;
      });
    }
  }

  void afterFirstLayout(BuildContext context) {
    height = context.size.height;
    width = context.size.width;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
    if (widget.checklist.itemStates.length > widget.index) {
      widget.checklist.itemStates.removeAt(widget.index);
    }
    widget.checklist.itemStates.insert(widget.index, this);

    return GestureDetector(
        onTap: (){
          if (widget.onTapItem != null) {
            widget.onTapItem(widget.checklist.widget.index, widget.index, this);
          }
        },
        onTapDown: (otd) {
          RenderBox object = context.findRenderObject();
          Offset pos = object.localToGlobal(Offset.zero);
          RenderBox box = widget.checklist.context.findRenderObject();
          Offset listPos = box.localToGlobal(Offset.zero);
          widget.checklist.widget.checklistState.topListY = listPos.dy;
          widget.checklist.widget.checklistState.topItemY = pos.dy;
          widget.checklist.widget.checklistState.bottomItemY =
              pos.dy + object.size.height;
          widget.checklist.widget.checklistState.bottomListY =
              listPos.dy + box.size.height;

          widget.checklist.widget.checklistState.initialX = pos.dx;
          widget.checklist.widget.checklistState.initialY = pos.dy;
        },
        onLongPress: () {
          _startDrag(widget, context);
        },
        child:Container(
            color: (widget.backgroundColor != null)?widget.backgroundColor:Colors.white,
            child:Row(children: <Widget>[
       Expanded(child:widget.title),
      Checkbox(value: value,onChanged: (val){
        setState(() {
          if(widget.onChanged != null){
            widget.onChanged(widget.checklist.widget.index,widget.index,val);
          }
          value = val;
        });
      },)
    ],)));
  }

}