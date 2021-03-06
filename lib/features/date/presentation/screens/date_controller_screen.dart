import 'package:date_bloc/core/process_date.dart';
import 'package:meta/meta.dart';
import 'package:date_bloc/features/date/presentation/bloc/date_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'custom_painter.dart';

class DateControllerScreen extends StatelessWidget {
  final String message;
  final DateTime date;
  final int index;

  const DateControllerScreen({
    Key key,
    @required this.message,
    @required this.date,
    @required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // should override in ThemeData instead
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(44.0),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit Event',
            style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: DateControllerBody(
        message: message,
        date: date,
        index: index,
      ),
    );
  }
}

class DateControllerBody extends StatefulWidget {
  final String message;
  final DateTime date;
  final int index;

  const DateControllerBody({
    Key key,
    @required this.message,
    @required this.date,
    @required this.index,
  }) : super(key: key);
  @override
  _DateControllerBodyState createState() => _DateControllerBodyState();
}

class _DateControllerBodyState extends State<DateControllerBody> {
  // controller for textfield
  final controller = TextEditingController();
  // a custom FocusNode for keyboard
  final node = FocusNode();
  DateTime dateTimeEntry;
  // display title and dateTime on screen
  String titleLabel;
  String dateAndTime;
  // these two controls the visibility of textfield and dateTimePicker
  bool isEditingTitle = false;
  bool isEditingDateAndTime = false;
  // determines whether creating a new event or updating an old event
  bool isCreateDateEvent;
  // this boolean value is used to contorl SAVE button
  bool get _tapCondtion {
    if ((titleLabel.isNotEmpty) & (dateTimeEntry != null)) {
      return true;
    } else {
      return false;
    }
  }

  @override

  // if we are CREATING a new event, all of [titleLabel], [controller.text],
  // [dateAndTime], [dateTimeEntry] will be set to empty.
  // if we are UPDATING an existing event, all of [titleLabel], [controller.text],
  // [dateAndTime], [dateTimeEntry] will be set to the value that is passed in.
  void didChangeDependencies() {
    isCreateDateEvent = widget.date == null ? true : false;
    if (isCreateDateEvent) {
      print('we are CREATING a new event');
    } else {
      print('we are UPDATING an old event');
    }
    titleLabel = isCreateDateEvent ? '' : widget.message;
    controller.text = titleLabel;
    dateAndTime = isCreateDateEvent ? '' : widget.date.toString();
    dateTimeEntry = isCreateDateEvent ? DateTime.now() : widget.date;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    controller.addListener(() {
      print('text controller: ${controller.text}');
    });

    node.addListener(() {
      print('node becomes ${node.hasFocus}');
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DateBloc, DateState>(
      builder: (context, state) {
        return Column(
          children: <Widget>[
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // event Textfield label, it is only visible when user taps Add Title
                    Visibility(
                      visible: isEditingTitle,
                      child: Container(
                        child: TextField(
                          focusNode: node,
                          controller: controller,
                          onSubmitted: (value) {
                            setState(() {
                              isEditingTitle = !isEditingTitle;
                              titleLabel = value;
                            });
                          },
                        ),
                      ),
                    ),

                    // event textLabel
                    Visibility(
                      visible: !isEditingTitle,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isEditingTitle = true;
                            // this line allows keyboard to pop up when user taps
                            // the label 'Add Title'
                            node.requestFocus();
                          });
                        },
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                titleLabel.isEmpty ? 'Add Title' : titleLabel,
                                style: TextStyle(
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 10,
                    ),

                    // date & time label
                    GestureDetector(
                      onTap: () {
                        print('dateTimeEntry: ${dateTimeEntry}');
                        print('dateAndTime: ${dateAndTime}');
                        setState(() {
                          print('controller text: ${controller.text}');
                          if (controller.text.isNotEmpty) {
                            titleLabel = controller.text;
                          }

                          isEditingTitle = false;
                          isEditingDateAndTime = !isEditingDateAndTime;
                        });
                      },
                      child: Container(
                        child: Text(
                          dateAndTime.isEmpty ? 'Date and Time' : dateAndTime,
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),

                    // dateTime picker imported
                    Visibility(
                      visible: isEditingDateAndTime,
                      child: SizedBox(
                        height: 150.0,
                        child: DatePickerWidget(
                          dateFormat: 'dd-MMMM-yyyy',
                          initialDateTime: dateTimeEntry,
                          onMonthChangeStartWithFirstDate: false,
                          pickerTheme: DateTimePickerTheme(
                            showTitle: false,
                            backgroundColor: Colors.black,
                            itemTextStyle: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onChange: (dateTime, selectedIndex) {
                            var _month = parseDate(dateTime.month);
                            final _day = parseDate(dateTime.day);
                            final _year = dateTime.year;
                            dateTimeEntry =
                                DateTime.parse('${_year}${_month}${_day}');
                            setState(() {
                              _month = getMonth(dateTime.month);
                              dateAndTime = '${_day}-${_month}-${_year}';
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: 30,
                    ),

                    Row(
                      children: <Widget>[
                        Icon(Icons.photo_camera),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Edit Photo'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // TODO: animate the effects when a button is tapped

            GestureDetector(
              // the button is disabled when [dateTimeEntry] or [titleLabel] is null
              onTap: _tapCondtion
                  ? () {
                      if (isCreateDateEvent) {
                        BlocProvider.of<DateBloc>(context).add(
                          CreateDate(
                            message: controller.text,
                            date: dateTimeEntry,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        print('${widget}: ${widget.index}');
                        BlocProvider.of<DateBloc>(context).add(
                          UpdateDate(
                            message: controller.text,
                            date: dateTimeEntry,
                            index: widget.index,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    }
                  : null,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 100,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: MyPainter(Colors.black),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
