import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:toggle_switch/toggle_switch.dart';

class UIPage extends StatefulWidget {
  const UIPage({super.key});

  @override
  State<UIPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<UIPage> {
  final List<DateTime> _dates = [DateTime.now()];
  String _selectedValue = 'Album';

  List<String> options = [
    'None',
    'Country Trend',
    'Album',
    'Stocks',
    'Country Clock'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: 1.sh),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 30.h,
                            child: Center(
                                child: Text(
                              'Full Screen',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 28.sp),
                            ))),
                        const Gap(8),
                        ToggleSwitch(
                          minHeight: 30.h,
                          minWidth: 40.w,
                          activeBgColor: const [Colors.green],
                          inactiveBgColor: Colors.grey,
                          activeFgColor: Colors.white,
                          initialLabelIndex: 0,
                          totalSwitches: 2,
                          labels: const [
                            'Yes',
                            'No',
                          ],
                          onToggle: (index) {
                            print('switched to: $index');
                          },
                        ),
                        const Gap(8),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                              height: 30.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8))),
                              child: const Center(
                                  child: Text(
                                'Start: Now',
                              ))),
                        ),
                        Gap(3),
                        Expanded(
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                var results =
                                    await showCalendarDatePicker2Dialog(
                                  context: context,
                                  config:
                                      CalendarDatePicker2WithActionButtonsConfig(),
                                  dialogSize: const Size(325, 400),
                                  value: _dates,
                                  borderRadius: BorderRadius.circular(15),
                                );
                              },
                              icon: Icon(Icons.calendar_month,
                                  color: Colors.white)),
                        )
                      ],
                    ),
                    const Gap(12),
                    Text(
                      'OtherScreen',
                      style: TextStyle(color: Colors.white, fontSize: 28.sp),
                    ),
                    Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            return RadioListTile<String>(
                              activeColor: Colors.tealAccent,
                              // Color for the selected radio button
                              value: options[index],
                              groupValue: _selectedValue,
                              title: Text(
                                options[index],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.sp),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedValue = value!;
                                });
                              },
                              dense: true,
                            );
                          },
                        )),
                    MyCustomForm(),
                  ],
                ),
              ),
            ),
          );
        }),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyCustomForm extends StatefulWidget {
  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm> {
  TimeOfDay selectedTime = TimeOfDay(hour: 7, minute: 15);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: <Widget>[
          ListTile(
            title: Text("Start Time: Now"),
            trailing: TimeInputField(
              initialTime: selectedTime,
              onTimeChanged: (newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
          ),
          ListTile(
            title: Text("End Time: NA"),
            trailing: TimeInputField(
              initialTime: selectedTime,
              onTimeChanged: (newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
          ),
          ListTile(
            title: Text("Photo Album"),
            trailing: IconButton(
              icon: Icon(Icons.add_circle),
              onPressed: () {
                // Handle photo album addition
              },
            ),
          ),
          Container(
            height: 150.h,
            child: PageView(
              children: <Widget>[
                Image.network(
                    'https://glamadelaide.com.au/wp-content/uploads/2021/12/weather.jpg'),
                // Replace with your image URL or asset
                Image.network(
                    'https://www.un.org/sites/un2.un.org/files/styles/large-article-image-style-16-9/public/field/image/2023/03/52196025795_06f077377a_c.jpg'),
                // Replace with your image URL or asset
                Image.network(
                    'https://live-production.wcms.abc-cdn.net.au/36d593f1ae0ba45f25975c952f58eb71?impolicy=wcms_crop_resize&cropH=1365&cropW=2048&xPos=0&yPos=1&width=862&height=575'),
                // Replace with your image URL or asset
              ],
            ),
          ),
          ListTile(
            title: Text("Play Time: Always"),
            trailing: TimeInputField(
              initialTime: selectedTime,
              onTimeChanged: (newTime) {
                setState(() {
                  selectedTime = newTime;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimeInputField extends StatelessWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeChanged;

  TimeInputField({required this.initialTime, required this.onTimeChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
        );
        if (picked != null && picked != initialTime) onTimeChanged(picked);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              '${initialTime.hour.toString().padLeft(2, '0')} : ${initialTime.minute.toString().padLeft(2, '0')}'),
          Icon(Icons.edit),
        ],
      ),
    );
  }
}
