
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Flutter code sample for [Card].

// void main() => runApp( CardExampleApp());

class SettingsMenu extends StatelessWidget {
  // const CardExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Launcher Settings'), backgroundColor: Colors.black,),
        body:  CardExample(),
      ),
    );
  }
}

class CardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
      return CardExampleState();
  }
  
}

class CardExampleState extends StatefulWidget {
  // const CardExample({super.key});




  State<CardExampleState> createState() => _CardExampleState();

}

class _CardExampleState extends State<CardExampleState> {
   List<bool> _wallPaperStat = <bool>[false, true];
   List<bool> _iconStat = <bool>[true, false];
// create some values
  Color accentColor = Color(0xff443a49);
  Color currentColor;
  Color timeColor = Colors.white;
  Color currentTimerColor;
  int timeSize = 0;
  var timeStyle = 'Horizontal';
  var userPhoneNumberController = new TextEditingController();
  var timeSizeController = new TextEditingController();
  var items = [
    'Vertical',
    'Horizontal',
  ];

   @override
   void initState() {
     super.initState();
     getWallPaperStat();
     getIconStatAndColor();
   }
  static const List<Widget> Switch = <Widget>[
    Text('ON'),
    Text('OFF'),
  ];
  void changeColor(Color color,type) {
    if(type == "accent"){
      setState(() => accentColor = color);
    } else {
      setState(() => timeColor = color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
    child: ListView(

      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Container(
          height: 50,
          // color: Colors.black[600],
          child:  Row(

              children : [Text('Show Wallpaper',style: TextStyle(color: Colors.white),),
                Spacer(),
                ToggleButtons(
                  direction:  Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _wallPaperStat.length; i++) {
                        _wallPaperStat[i] = i == index;
                      }
                    });
                    var wallPaperStatusIndex = _wallPaperStat.indexOf(true);
                    storeStat('WallPaperStat',wallPaperStatusIndex,'int');
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Colors.grey[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  color: Colors.red[400],
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _wallPaperStat,
                  children: Switch,
                ),]
          ),
        ),
        Container(
          height: 50,
          // color: Colors.amber[500],
          child:  Row(

              children : [Text('Show Icons',style: TextStyle(color: Colors.white),),
                Spacer(),
                ToggleButtons(
                  direction:  Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _iconStat.length; i++) {
                        _iconStat[i] = i == index;
                      }
                    });
                    var iconStatusIndex = _iconStat.indexOf(true);
                    storeStat('IconStat',iconStatusIndex,'int');
                  },
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  selectedBorderColor: Colors.grey[700],
                  selectedColor: Colors.white,
                  fillColor: Colors.blue,
                  color: Colors.red[400],
                  constraints: const BoxConstraints(
                    minHeight: 40.0,
                    minWidth: 80.0,
                  ),
                  isSelected: _iconStat,
                  children: Switch,
                ),]
          ),
        ),
        Container(
          height: 50,
          // color: Colors.amber[100],
          child:  Row(

              children : [Text('Set Accent Color',style: TextStyle(color: Colors.white),),
                Spacer(),
                // Container(
                //   color: currentColor,
                //   child: SizedBox( height: 20,width: 20,),
                // )20,
               SizedBox(width: 10,),
               TouchableOpacity(
                   onTap: () {
                     return showDialog(
                       context: context,
                       builder: (BuildContext context) {
                       return AlertDialog(
                         title: const Text('Pick a color!'),
                         content: SingleChildScrollView(
                           child: ColorPicker(
                             pickerColor: accentColor,
                             onColorChanged: (v) {
                               changeColor(v, 'accent');
                             },
                           ),
                           // Use Material color picker:
                           //
                           // child: MaterialPicker(
                           //   pickerColor: pickerColor,
                           //   onColorChanged: changeColor,
                           //   showLabel: true, // only on portrait mode
                           // ),
                           //
                           // Use Block color picker:
                           //
                           // child: BlockPicker(
                           //   pickerColor: currentColor,
                           //   onColorChanged: changeColor,
                           // ),
                           //
                           // child: MultipleChoiceBlockPicker(
                           //   pickerColors: currentColors,
                           //   onColorsChanged: changeColors,
                           // ),
                         ),
                         actions: <Widget>[
                           ElevatedButton(
                             child: const Text('Set Accent Color'),
                             onPressed: () {
                               setState(() => currentColor = accentColor);
                               int hex = accentColor.value;
                               storeStat('accentColor',hex,'int');
                               Navigator.of(context).pop();
                             },
                           ),
                         ],
                       );},
                     );
                   },
                   child: Container(
                     decoration: BoxDecoration(color: currentColor,border: Border.all(color: Colors.black,width: 1.0,style: BorderStyle.solid)),
                     child: SizedBox( height: 30,width: 50,),
                   ) ),


              ]
          ),
        ),
        Container(
          height: 50,
          // color: Colors.amber[100],
          child:  Row(

              children : [Text('Set Timer Color',style: TextStyle(color: Colors.white),),
                Spacer(),
                // Container(
                //   color: currentColor,
                //   child: SizedBox( height: 20,width: 20,),
                // )20,
                SizedBox(width: 10,),
                TouchableOpacity(
                    onTap: () {
                      return showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Pick a color!'),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: accentColor,
                                onColorChanged: (v) {
                                  changeColor(v, 'timer');
                                },
                              ),
                              // Use Material color picker:
                              //
                              // child: MaterialPicker(
                              //   pickerColor: pickerColor,
                              //   onColorChanged: changeColor,
                              //   showLabel: true, // only on portrait mode
                              // ),
                              //
                              // Use Block color picker:
                              //
                              // child: BlockPicker(
                              //   pickerColor: currentColor,
                              //   onColorChanged: changeColor,
                              // ),
                              //
                              // child: MultipleChoiceBlockPicker(
                              //   pickerColors: currentColors,
                              //   onColorsChanged: changeColors,
                              // ),
                            ),
                            actions: <Widget>[
                              ElevatedButton(
                                child: const Text('Set Timer Color'),
                                onPressed: () {
                                  setState(() => currentTimerColor = timeColor);
                                  int hex = timeColor.value;
                                  storeStat('timeColor',hex,'int');
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );},
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(color: currentTimerColor,border: Border.all(color: Colors.black,width: 1.0,style: BorderStyle.solid)),
                      // color: currentColor,
                      child: SizedBox( height: 30,width: 50,),
                    ) ),


              ]
          ),
        ),
        Container(
          // height: 50,
          // color: Colors.amber[500],
          child:  Row(

            children : [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Set TimerSize',style: TextStyle(color: Colors.white),),
                  Text('PM text wont be visible when set to 28 or lower',style: TextStyle(height:2,fontSize: 10,color: Colors.white),)
                ],
              )
,
              Spacer(),
              Container(
                width: 100,
                // height: 50,// Adjust the width of the container
                // padding: EdgeInsets.fromLTRB(0,0,0,0),
                child: TextField(

                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlueAccent),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  onChanged: (s) {
                    print(s.toString()+" : "+s);
                    storeStat('timeSize', int.parse(s), 'int');
                  },
                  controller: timeSizeController,
                  keyboardType: TextInputType.number,
                  // inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                  maxLength: 2,
                  // decoration: InputDecoration(
                  //   // labelText: 'Enter Name',
                  //   border: OutlineInputBorder(),
                  // ),
                  style: TextStyle(fontSize: 23, color: Colors.white), // <-- SEE HERE
                ),
              ),

            ],
          ),
        ),
        Container(
          // height: 50,
          // color: Colors.amber[500],
          child:  Row(

            children : [
              Text('Set Timer Style',style: TextStyle(color: Colors.white),),
              Spacer(),
              Container(
                // height: 50,// Adjust the width of the container
                // padding: EdgeInsets.fromLTRB(0,0,0,0),
                child: DropdownButton(
                  dropdownColor: Colors.black, // Set the background color
                  // Initial Value
                  value: timeStyle,

                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),
                  // Array list of items
                  items: items.map((String items) {
                    return DropdownMenuItem(
                        value: items,
                        child: Container(
                          width: 100,
                          child: Text(items, style: TextStyle(color: Colors.white),),
                        )
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (newValue) {
                    setState(() {
                      timeStyle = newValue;
                    });
                    storeStat('timeStyle', newValue, 'string');
                  },
                ),
              ),

            ],
          ),
        ),
        Container(
          // height: 50,
          // color: Colors.amber[500],
          child:  Row(

              children : [
                Text('Set Default Dail Number',style: TextStyle(color: Colors.white),),
                Spacer(),
                Container(
                  width: 200,
                  // height: 50,// Adjust the width of the container
                  // padding: EdgeInsets.fromLTRB(0,0,0,0),
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.lightBlueAccent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    controller: userPhoneNumberController,
                    keyboardType: TextInputType.number,
                    // inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                    maxLength: 12,
                    // decoration: InputDecoration(
                    //   // labelText: 'Enter Name',
                    //   border: OutlineInputBorder(),
                    // ),
                    style: TextStyle(fontSize: 23, color: Colors.white), // <-- SEE HERE
                  ),
                ),

                    ],
                  ),
                ),

          // SizedBox(height: 20,width: 70,),
        Center(
          child: Container(
            // color: Colors.white,
            width: 200,
            height: 30,
            child: Center(

            child:
            ElevatedButton(
              onPressed: () {
                print("LENGTH : "+userPhoneNumberController.text.toString());
                if(userPhoneNumberController.text.toString().length >= 10){
                    storeStat("favPhoneNumber", userPhoneNumberController.text.toString(), "string");
                    Fluttertoast.showToast(
                      msg: 'Long Press Phone Icon to Fast Dail Now',
                      toastLength: Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
                      gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
                      timeInSecForIosWeb: 1, // Duration for iOS
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                } else {
                  Fluttertoast.showToast(
                    msg: 'Number should be greater than 9 digits',
                    toastLength: Toast.LENGTH_SHORT, // Duration for which the toast will be displayed
                    gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
                    timeInSecForIosWeb: 1, // Duration for iOS
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: Text('Set Phone Number'),
            ),
            )
          ),
        )
      ],
    ));
  }

   storeStat (key, value, type) async {
     final prefs = await SharedPreferences.getInstance();
     if(type =="int"){
       prefs.setInt(key, value);
     } else {
       prefs.setString(key,value);
     }
   }

  getWallPaperStat () async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getInt('WallPaperStat');
    if(s != null) {
      _wallPaperStat = [false,false];
      _wallPaperStat[s] = true;
      setState(() {
        _wallPaperStat = _wallPaperStat;
      });
    }
  }



  getIconStatAndColor () async {
     final prefs = await SharedPreferences.getInstance();
     var s = prefs.getInt('IconStat');
     var c = prefs.getInt('accentColor');
     var t = prefs.getInt('timeColor');
     var ts = prefs.getInt('timeSize');
     var tst = prefs.getString('timeStyle');
     if(ts!= null){
       // set State(() {
         timeSizeController.value = TextEditingValue( text : ts.toString());
       // });
     } else {
       // setState(() {
       timeSizeController.value = TextEditingValue( text : '58');
       // });
     }
     if(tst != null){
       timeStyle = tst;
     }
     if(t!= null){
        setState(() {
          currentTimerColor = Color(t);
        });
      } else {
        currentTimerColor = Colors.white;

      }
     if(c!= null){

       setState(() {
         currentColor = Color(c);
       });

     } else {
       // int c1 = c;
       int blue = Colors.blue.value;
       setState(() {
         currentColor = Color(blue);
       });

     }
     if(s != null) {
       _iconStat = [false,false];
       _iconStat[s] = true;
       setState(() {
         _iconStat = _iconStat;
       });
     }
   }




}


