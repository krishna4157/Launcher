import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:battery_info/battery_info_plugin.dart';
import 'package:battery_info/enums/charging_status.dart';
import 'package:battery_info/model/android_battery_info.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_power_launcher/SettingsMenu.dart';
import 'package:smart_power_launcher/Charging.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchable_opacity/touchable_opacity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:focus_detector/focus_detector.dart';
import 'alphabetListView.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'dart:ui' as ui;

var onLoaded = false;

var isNotPresent = false;
var isVisible = false;
var batteryPercentage;
var switchState = 'on';
GlobalKey _globalKey = GlobalKey();
// List<CellData> matrixValues =
//     List<CellData>.generate(20, (index) => CellData(0.0, index));
// StreamSubscription _volumeButtonSubscription;
var onChangeIcon = false;

var i = 0;
List strList = [];

class CellData {
  double value;
  final int index;
  TextEditingController controller;

  CellData(this.value, this.index);
}

void main() {
  // GestureBinding.instance.resamplingEnabled = true;
  // final VoidCallback callback =() =>{};

  runApp(Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child:
          MaterialApp(home: HomeLauncherPage(), // becomes the route named '/'
              routes: <String, WidgetBuilder>{
            '/appsDrawer': (BuildContext context) => AppsDrawer(),
            '/charging': (BuildContext context) => Charging(),
            '/settings': (BuildContext context) => SettingsMenu(),
          })));
}

_launchCaller(val) async {
  var url = "tel:$val";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

_textMe() async {
  // Android
  // const uri = 'sms:+39 348 060 888?body=hello%20there';
  const uri = 'sms:';

  if (await canLaunch(uri)) {
    await launch(uri);
  } else {
    // iOS
    const uri = 'sms:';
    if (await canLaunch(uri)) {
      await launch(uri);
    } else {
      throw 'Could not launch $uri';
    }
  }
}

class HomeLauncherPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StartPage();
  }
}

class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int Z = 0;
  String z = 's';
  int batteryPercentage = 0;
  var hideCharging = false;

  var isCharging = false;
  Animation<double> animation;
  AnimationController controller;
  Animation<double> animation2;
  int counter = 0;
  var animcolor = Colors.black;
  String formattedDate = '';
  int timeColor = Colors.white.value;
  int accentColor = Colors.white.value;
  var batteryImage = false;

  var timeStyle = 'Horizontal';

  int timeSize = 58;
  String isAmPm = '';
  var wallpaper;
  var hideWallpaper = true;
  var buttonColor = Colors.transparent;
  Timer checkGlobalKey;
  var showTime = false;


  @override
  void didUpdateWidget(StartPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  setOnLoaded(val) {
    print('trigger');
    setStateIfMounted(() {
      onLoaded = val;
    });
  }

  checkBatteryLevel() {
    BatteryInfoPlugin()
        .androidBatteryInfoStream
        .listen((AndroidBatteryInfo batteryInfo) {
      setState(() {
        z = batteryInfo.chargingStatus.toString();
        Z = Z + 1;
        batteryPercentage = batteryInfo.batteryLevel;
      });
      if (batteryInfo.chargingStatus == ChargingStatus.Charging) {
        if (z == 'ChargingStatus.Charging' && hideCharging != true) {
          Future.delayed(Duration(seconds: 10), () {
            setState(() {
              hideCharging = true;
            });
          });
        }
      } else {
        setState(() {
          hideCharging = false;
          Z = 0;
        });
      }
    });
  }

  void _submit({int counter}) {
    _navigateToNewPage(counter);
  }

  void _navigateToNewPage(counter) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SecondPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    setBatteryPercentage();
    setState(() {
      onChangeIcon = false;
    });
  }

  void setBatteryPercentage() async {
    var bl = (await BatteryInfoPlugin().iosBatteryInfo).batteryLevel;
    print('battery Percentage' + bl.toString());
    setStateIfMounted(() {
      batteryPercentage = bl;
    });
  }

  void checkWallPaper() {
    requestFilePermission().then((permissionGranted) {
      if (permissionGranted) {
        LauncherAssist.getWallpaper().then((imageData) {
          if (imageData.toString() != wallpaper.toString()) {
            setState(() {
              wallpaper = imageData;
            });
          }
        });

          Future.delayed(Duration(seconds: 2),(){

            print('VALUE : '+_globalKey.currentContext.toString());
            if(batteryImage && wallpaper!=null) {
            if(batteryImage && wallpaper != null && !hideWallpaper && _globalKey.currentContext != null) {
              setStateIfMounted(() {
                showTime = true;
              });
            }
            }
          });
        // }
      } else {
        print("inside of the else part ");
      }
    });
  }

  Future<bool> requestFilePermission() async {
    PermissionStatus result;
    // In Android we need to request the storage permission,
    // while in iOS is the photos permission
    // if (Platform.isAndroid) {
    result = await Permission.storage.request();
    // } else {
    //   result = await Permission.photos.request();
    // }

    if (result.isGranted) {
      // imageSection = ImageSection.browseFiles;
      return true;
    } else {
      // imageSection = ImageSection.noStoragePermission;
    }
    return false;
  }

  getWallPaperStat() async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getInt('WallPaperStat');
    int t = prefs.getInt('timeColor');
    int ts = prefs.getInt('timeSize');
    int ac = prefs.getInt('accentColor');
    int wb = prefs.getInt('BatteryStat');
    if (wb != null) {
      if (wb == 0) {
        print('called');
        batteryImage = true;
      } else {
        print('called123');
        batteryImage = false;
      }
    }
    if (ac != null) {
      accentColor = ac;
    }
    var tst = prefs.getString('timeStyle');

    int wallAccentColor = prefs.getInt('wallAccentColor');
    if (wallAccentColor != null) {
      setState(() {
        animcolor = Color(wallAccentColor);
      });
    }
    if (tst != null) {
      timeStyle = tst;
    }
    if (t != null) {
      timeColor = t;
    }
    if (ts != null) {
      timeSize = ts;
    }
    if (s != null) {
      if (s == 1) {
        hideWallpaper = true;
      } else {
        hideWallpaper = false;
      }
      setState(() {
        hideWallpaper = hideWallpaper;
      });
      if (hideWallpaper == false) {
        checkWallPaper();
      }
    }
  }

  Future<bool> handleStoragePermissions() async {
    PermissionStatus storagePermissionStatus = await _getPermissionStatus();

    if (storagePermissionStatus == PermissionStatus.granted) {
      //which means that we have been given the permission to access device storage,
      return true;
    } else {
      // _handleInvalidPermissions(storagePermissionStatus);
      return false;
    }
  }

  Future _getPermissionStatus() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {});
      return PermissionStatus.granted;
    }
  }

  changeColor() async {
    Future.delayed(Duration(seconds: 1), () async {
      var colorsList = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
        Colors.teal,
        Color.fromRGBO(230, 230, 250, 1.0),
        Color.fromRGBO(57, 255, 20, 1.0),
        Color.fromRGBO(128, 0, 32, 1.0),
      ];
      var _randomColor = new Random();

      var element = colorsList[_randomColor.nextInt(colorsList.length)];
      if (animcolor.toString() != element.toString()) {
        final prefs = await SharedPreferences.getInstance();
        int hex = element.value;
        prefs.setInt('wallAccentColor', hex);
        setStateIfMounted(() {
          animcolor = element;
        });
      } else {
        changeColor();
      }
    });
  }

  changeColorOnTap() async {
    Future.delayed(Duration(seconds: 1), () async {
      var colorsList = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.yellow,
        Colors.teal,
        Color.fromRGBO(230, 230, 250, 1.0),
        Color.fromRGBO(57, 255, 20, 1.0),
        Color.fromRGBO(128, 0, 32, 1.0),
      ];
      var _randomColor = new Random();

      var element = colorsList[_randomColor.nextInt(colorsList.length)];
      if (animcolor.toString() != element.toString()) {
        final prefs = await SharedPreferences.getInstance();
        int hex = element.value;
        prefs.setInt('wallAccentColor', hex);
        prefs.setInt('timeColor', hex);
        setStateIfMounted(() {
          animcolor = element;
          timeColor = element.value;
        });
      } else {
        changeColor();
      }
    });
  }

  resetColorAndChange() {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });

    changeColor();
  }

  resetColorAndChangeOnTap() {
    setStateIfMounted(() {
      animcolor = Colors.black;
    });

    changeColorOnTap();
  }

  setToDefault() async {
    // final prefs = await SharedPreferences.getInstance();
    // prefs.setString('prevChargeState', 'disCharge');
  }

  Future<List> getUserInfo(menus) async {
    List<dynamic> userMap;

    final String userStr = menus;
    if (userStr != null) {
      userMap = jsonDecode(userStr) as List<dynamic>;
    }
    if (userMap != null) {
      final List<dynamic> usersList = userMap;

      return usersList;
    }
    return null;
  }

  @override
  void dispose() {
    controller.dispose();
    // _volumeButtonSubscription?.cancel();
    super.dispose();
  }

  remainSamePage() async {
    return false;
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  navigateToCharging() async {
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.fade,
            duration: Duration(seconds: 2),
            child: Charging()));
  }

  checkColorPresent() async {
    final prefs = await SharedPreferences.getInstance();
    int clr = prefs.getInt('wallAccentColor');
    if (clr != null) {
      setStateIfMounted(() {
        animcolor = Color(clr);
      });
    } else {
      resetColorAndChange();
    }
  }

  checkUntilGlobalKey() {
      Future.delayed(Duration(seconds: 2),(){
        print('VALUE : '+_globalKey.currentContext.toString());
        if(batteryImage && wallpaper != null && !hideWallpaper && _globalKey.currentContext != null){
          setStateIfMounted((){
            showTime = true;
          });
        }

      });
      // print('VALUE : '+_globalKey.currentContext.toString());
  }

  @override
  Widget build(BuildContext context) {
    // MediaQueryData queryData;
    // queryData = MediaQuery.of(context);
    return WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          return remainSamePage();
        },
        child: FocusDetector(
            onFocusLost: () {
              print(
                'Focus Lost.'
                '\nTriggered when either [onVisibilityLost] or [onForegroundLost] '
                'is called.'
                '\nEquivalent to onPause() on Android or viewDidDisappear() on '
                'iOS.',
              );
              if (timer != null) {
                timer.cancel();
              }
            },
            onFocusGained: () {

              // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
              getWallPaperStat();
              checkBatteryLevel();
              checkColorPresent();
              checkUntilGlobalKey();
            },
            onVisibilityLost: () {
              print(
                'Visibility Lost.'
                '\nIt means the widget is no longer visible within your app.',
              );
            },
            onForegroundLost: () {
              print(
                'Foreground Lost.'
                '\nIt means, for example, that the user sent your app to the '
                'background by opening another app or turned off the device\'s '
                'screen while your widget was visible.',
              );
            },
            child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  int sensitivity = 10;
                  if (details.delta.dy > sensitivity) {
                    // Down Swipe
                    print('down swipe');

                  } else if(details.delta.dy < -sensitivity){
                    print('up swipe');
                    _submit(counter: _counter);
                    setStateIfMounted(() {
                      buttonColor = Colors.transparent;
                    });
                    // Up Swipe
                  }
                },
            child : TouchableOpacity(
                activeOpacity: 1.0,
                onTap: () {},
                onDoubleTap: () {
                  resetColorAndChangeOnTap();
                },
                onLongPress: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.fade,
                          duration: Duration(milliseconds: 300),
                          child: SettingsMenu()));
                },
                child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: Colors.black,
                    body: Stack(children: [
                      Center(
                          child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.darken,
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    child: AnimatedContainer(
                                        curve: Curves.decelerate,
                                        decoration: BoxDecoration(
                                            image: (!hideWallpaper &&
                                                        wallpaper != null) &&
                                                    !batteryImage
                                                ? DecorationImage(
                                                    image:
                                                        MemoryImage(wallpaper),
                                                    // : Image.memory(Uint8List(0)),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                            gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                stops: [
                                                  0.74,
                                                  0.75,
                                                  0.79,
                                                  0.95,
                                                  1
                                                ],
                                                colors: [
                                                  Colors.black,
                                                  Colors.black,
                                                  Colors.black,
                                                  batteryImage
                                                      ? Colors.black
                                                      : animcolor,
                                                  batteryImage
                                                      ? Colors.black
                                                      : animcolor,
                                                ])),
                                        duration: Duration(milliseconds: 899),
                                        child: Stack(children: [
                                          Center(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 16, 0, 10),
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    if (!batteryImage)
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  20, 60, 0, 0),
                                                          child: RenderWidget(
                                                            timeColor:
                                                                timeColor,
                                                            timeSize: timeSize,
                                                            timeStyle:
                                                                timeStyle,
                                                            fontFamily:
                                                                'Montserrat',
                                                          )),
                                                    Container(),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              ConstrainedBox(
                                                                constraints: BoxConstraints
                                                                    .tightFor(
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            60),
                                                                child:
                                                                    ElevatedButton(
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <
                                                                          Widget>[
                                                                        Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Icon(
                                                                                Icons.phone,
                                                                                size: 25,
                                                                                color: animcolor,
                                                                              ),
                                                                            ]),
                                                                      ]),
                                                                  onPressed:
                                                                      () {
                                                                    _launchCaller(
                                                                        "");
                                                                  },
                                                                  onLongPress:
                                                                      () {
                                                                    getDailFavNumberIfStored();
                                                                    // _launchCaller('');
                                                                  },
                                                                  style:
                                                                      ButtonStyle(
                                                                    shape: MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    )),
                                                                    backgroundColor:
                                                                        MaterialStateProperty.resolveWith(
                                                                            (states) {
                                                                      if (states.contains(MaterialState.hovered) ||
                                                                          states.contains(MaterialState
                                                                              .pressed) ||
                                                                          states.contains(MaterialState
                                                                              .focused) ||
                                                                          states
                                                                              .contains(MaterialState.selected)) {
                                                                        return Colors
                                                                            .blueAccent;
                                                                      } else {
                                                                        return Colors
                                                                            .transparent;
                                                                      }
                                                                    }),
                                                                  ),
                                                                ),
                                                              ),

                                                              //menu button
                                                              Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    ConstrainedBox(
                                                                      constraints: BoxConstraints.tightFor(
                                                                          width: onChangeIcon
                                                                              ? 50
                                                                              : 50,
                                                                          height: onChangeIcon
                                                                              ? 50
                                                                              : 50),
                                                                      child: TouchableOpacity(
                                                                          activeOpacity: 1.0,
                                                                          child: Container(
                                                                              // color: buttonColor,
                                                                              decoration: BoxDecoration(
                                                                                color: buttonColor,
                                                                                borderRadius: BorderRadius.circular(35), // Adjust the radius as needed
                                                                              ),
                                                                              child: onChangeIcon == true
                                                                                  ? Image.asset(
                                                                                      'assets/images/ga1.png',
                                                                                      height: 10,
                                                                                      width: 10,
                                                                                      fit: BoxFit.contain,
                                                                                    )
                                                                                  : AppDrawerIcon()),
                                                                          onLongPress: () => {
                                                                                setState(() {
                                                                                  onChangeIcon = true;
                                                                                }),
                                                                                Future.delayed(Duration(seconds: 1), () {
                                                                                  DeviceApps.openApp("com.google.android.apps.googleassistant");
                                                                                  setState(() {
                                                                                    onChangeIcon = false;
                                                                                  });
                                                                                })
                                                                              },
                                                                          onTap: () => {
                                                                                setStateIfMounted(() {
                                                                                  buttonColor = Color(accentColor);
                                                                                }),
                                                                                Future.delayed(Duration(milliseconds: 15), () {
                                                                                  _submit(counter: _counter);
                                                                                  setStateIfMounted(() {
                                                                                    buttonColor = Colors.transparent;
                                                                                  });
                                                                                })
                                                                              }),
                                                                    ),
                                                                  ]),
                                                              //
                                                              ConstrainedBox(
                                                                constraints: BoxConstraints
                                                                    .tightFor(
                                                                        width:
                                                                            60,
                                                                        height:
                                                                            60),
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    _textMe();
                                                                  },
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Icon(
                                                                        Icons
                                                                            .message,
                                                                        color:
                                                                            animcolor,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  style:
                                                                      ButtonStyle(
                                                                    shape: MaterialStateProperty.all<
                                                                            RoundedRectangleBorder>(
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30.0),
                                                                    )),
                                                                    backgroundColor:
                                                                        MaterialStateProperty.resolveWith<
                                                                            Color>(
                                                                      (Set<MaterialState>
                                                                          states) {
                                                                        if (states
                                                                            .contains(MaterialState.pressed))
                                                                          return Colors
                                                                              .orange;
                                                                        return Colors
                                                                            .black; // Use the component's default.
                                                                      },
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ]),
                                            ),
                                          ),
                                          if (wallpaper != null && batteryImage)
                                            Positioned(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 80),
                                                    child: RepaintBoundary(
                                                        key: _globalKey,
                                                        child: Container(
                                                            width: MediaQuery
                                                                    .of(context)
                                                                .size
                                                                .width,
                                                            height:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                            // height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                                    // border: Border.all(color: Colors.black,width: 2.0,style: BorderStyle.solid),
                                                                    image: DecorationImage(
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        image: MemoryImage(
                                                                            wallpaper))))))),
                                          // Container(
                                          //   width: MediaQuery.of(context).size.width,
                                          //   height: MediaQuery.of(context).size.height,
                                          //   color: Colors.green,
                                          //   child: ,
                                          // ))),
                                          if (wallpaper != null && batteryImage)
                                            Positioned(
                                                child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 0, 80),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      height:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height,
                                                      color: Colors.black,
                                                    ))),
                                          if (wallpaper != null && batteryImage && showTime)
                                            Positioned(


                                                child: Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        0,
                                                        0,
                                                        0,
                                                        80),
                                                    child: MaskedImage(
                                                      setOnLoaded: setOnLoaded,
                                                      child: Center(
    child : RenderWidget(
        timeColor: timeColor,
        timeSize: 199,
        timeStyle: 'Vertical',
        fontFamily:
        'WorkSans-Black',
        fontWeight:
        FontWeight.w900,
        renderImage: true),
    ),
                                                      // RenderWidget(
                                                      //     timeColor: timeColor,
                                                      //     timeSize: 199,
                                                      //     timeStyle: 'Vertical',
                                                      //     fontFamily:
                                                      //     'WorkSans-Black',
                                                      //     fontWeight:
                                                      //     FontWeight.w900,
                                                      //     renderImage: true),
                                                      // ),

                                                      // if(batteryPercentage < 20)  Text('please charge your phone', textAlign: TextAlign.center,style : TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w900)),
                                                      // Text('${batteryPercentage}', textAlign: TextAlign.center,style : TextStyle( fontSize: batteryPercentage > 99 ? 200 : 300, fontWeight: FontWeight.w900)),
                                                      // ],
                                                      // ),
                                                      image: () {},
                                                      keyName: _globalKey,
                                                    ))
                                                ),
                                        ])),
                                  ),
                                  if (z == 'ChargingStatus.Charging' &&
                                      !hideCharging)
                                    Positioned(
                                        child: Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: Charging(),
                                    )),
                                ],
                              ))),
                      // wallpaper != null && batteryImage ? Positioned(
                      //     top:0,
                      //     left:0,
                      //     bottom: 0,
                      //     child: Container(
                      //       width: MediaQuery.of(context).size.width,
                      //     color: Colors.red,
                      //    child : MaskedImage(
                      //   setOnLoaded : setOnLoaded,
                      //   child :
                      //   Column(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     crossAxisAlignment: CrossAxisAlignment.center,
                      //     children: [
                      //       Padding(padding: EdgeInsets.fromLTRB(45, MediaQuery.of(context).size.height/5.4, 0, 0),
                      //         child : RenderWidget(timeColor: timeColor,timeSize: 199,timeStyle: 'Vertical', fontFamily : 'WorkSans-Black', fontWeight : FontWeight.w900, renderImage : true),
                      //       ),
                      //
                      //       // if(batteryPercentage < 20)  Text('please charge your phone', textAlign: TextAlign.center,style : TextStyle(fontFamily: 'Montserrat', fontSize: 20, fontWeight: FontWeight.w900)),
                      //       // Text('${batteryPercentage}', textAlign: TextAlign.center,style : TextStyle( fontSize: batteryPercentage > 99 ? 200 : 300, fontWeight: FontWeight.w900)),
                      //     ],
                      //   ),
                      //   image :
                      //   RepaintBoundary(
                      //     // key : _globalKey,
                      //       child: Container(
                      //           width: 120,
                      //           height: 100,
                      //           decoration: BoxDecoration(
                      //               border: Border.all(color: Colors.black,width: 2.0,style: BorderStyle.solid),
                      //               image: DecorationImage(
                      //
                      //                   image :MemoryImage(
                      //                       wallpaper
                      //                   ))
                      //           ))), keyName: _globalKey,))) : Container()
                    ]))))));
  }

  void getDailFavNumberIfStored() async {
    final prefs = await SharedPreferences.getInstance();
    var s = prefs.getString('favPhoneNumber');
    if (s != null) {
      _launchCaller(s);
    } else {
      _launchCaller('');
    }
  }
}

class MaskedImage extends StatelessWidget {
  final image;
  final setOnLoaded;
  final Widget child;
  final GlobalKey keyName;

  const MaskedImage({this.setOnLoaded, this.image, this.child, this.keyName});

  // Future<ui.Image> captureWidgetToImage(s) async {
  //   RenderRepaintBoundary boundary = s.currentContext.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage(pixelRatio: 3.0);
  //   print('called'+s.toString());
  //   ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List uint8list = byteData.buffer.asUint8List();
  //   return loadImage(uint8list);
  //
  // }

  Widget renderWidget() {
    return child;
  }

  Future<ui.Image> captureWidgetToImage(BuildContext context) async {
    print('succesws :');
    // setOnLoaded(false);
    onLoaded = false;

    RenderRepaintBoundary boundary =
        keyName.currentContext.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 0.83);
    print('succesws1 :' + image.toString());
    // setOnLoaded(true);
    onLoaded = true;
    return image;
  }

  Future<ui.Image> loadImage(dat) async {
    // Uint8List imageBytes = await captureWidgetToImage(key);
    // return ui.Image
    final ui.Image image1 =
        await decodeImageFromList(dat); // Convert Uint8List to ui.Image
    // print(image1.toString());
    return image1;
    // return s;
    // final completer = Completer<ui.Image>();
    // final stream  = image.resolve(ImageConfiguration());
    // stream.addListener(
    //   ImageStreamListener((info, _) =>  completer.complete(info.image)));
    //
    // return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return
        // image;
        //   Padding(padding: EdgeInsets.all(1.0),
        //     child:
        //   Container(
        //     width: 100,
        //     height: 80,
        //     decoration: BoxDecoration(
        //       // border: Border.all(color: Colors.black, width: 2.0,style: BorderStyle.solid),
        //     image:  DecorationImage(
        //       fit: BoxFit.cover,
        //         image:
        //     MemoryImage(image))))
        // );
        FutureBuilder<ui.Image>(
            future: captureWidgetToImage(keyName.currentContext),
            builder: (context, snap) => snap.hasData
                ? ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (data) => ImageShader(
                        snap.data,
                        TileMode.clamp,
                        TileMode.clamp,
                        Matrix4.identity().storage),
                    child: child,
                  )
                : Container());
    //   ShaderMask(
    //     blendMode: BlendMode.src,
    //     shaderCallback: (data) => ImageShader(snap.data,TileMode.clamp,TileMode.clamp,Matrix4.identity().storage), child:
    //   child,)
    // //   child
    // : Container());

    // image;
    // : Container()
    // );
  }
}

class RenderWidget extends StatefulWidget {
  final int timeColor;
  final int timeSize;
  final String timeStyle;
  final String fontFamily;
  final FontWeight fontWeight;
  final bool renderImage;

  RenderWidget(
      {this.timeColor,
      this.timeSize,
      this.timeStyle,
      this.fontFamily,
      this.fontWeight,
      this.renderImage = false});

  @override
  State<RenderWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<RenderWidget>
    with SingleTickerProviderStateMixin {
  // Timer timer;
  int counter = 0;
  String formattedDate = DateFormat('h:mm').format(DateTime.now());
  int timeColor = Colors.white.value;
  int accentColor = Colors.white.value;
  String isAmPm = DateFormat('aa').format(DateTime.now());
  Timer time;
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void didUpdateWidget(RenderWidget oldWidget) {
    if (oldWidget.timeColor != widget.timeColor) {
      _controller.reverse().then((value) => {
            _controller.forward(),
            super.didUpdateWidget(oldWidget)
          }); // Start the animation
    } else {
      super.didUpdateWidget(oldWidget);
    }
  }

  @override
  void dispose() {
    // if(timer)
    // timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Total duration for fade-in and fade-out
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Use an ease-in-out curve for smoother effect
    );

    // _controller.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     _controller.reverse(); // Reverse the animation when completed
    //   } else if (status == AnimationStatus.dismissed) {
    //     _controller.forward(); // Start the animation again
    //   }
    // });

    _controller.forward(); // Start the animation
  }

  setTimeOnFocus() {
    time = Timer.periodic(Duration(seconds: 2), (timer) {
      setTime();
    });
  }

  setTime() {
    DateTime now = DateTime.now();
    isAmPm = DateFormat('aa').format(now);
    var formattedMin = DateFormat('mm').format(now);
    var formattedHour = DateFormat('hh').format(now);

    var existingMin = DateFormat('h:mm').parse(formattedDate);
    if (formattedMin != DateFormat('mm').format(existingMin) ||
        formattedHour != DateFormat('hh').format(existingMin)) {
      // _controller.reverse().then((value) => {
      Future.delayed(Duration(milliseconds: 500), () {
        // _controller.forward();
        setStateIfMounted(() {
          formattedDate = DateFormat('h:mm').format(now);
          isAmPm = isAmPm;
        });
        // }),
      });
    }
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    if (widget.renderImage) {
      return FocusDetector(
          onFocusGained: () {
            setTimeOnFocus();
          },
          onFocusLost: () {
            if (timer != null) {
              timer.cancel();
            }
            if (time != null) {
              time.cancel();
            }
          },
          child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                            opacity: _animation.value,
                 child :
                Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Text('${DateFormat('hh').format(DateFormat('h:mm').parse(formattedDate))}',
                      style: TextStyle(
                        // color: Color(widget.timeColor),
                          letterSpacing: -25.0,
                          fontSize:  260,
                          fontFamily: widget.fontFamily,
                          fontWeight: widget.fontWeight),
                    ),
                        Container(
                          width: 100,
                            height: 100,
                        ),]),

                    Positioned(
                      top: MediaQuery.of(context).size.height/2.4,
                        child: Text('${DateFormat('mm').format(DateFormat('h:mm').parse(formattedDate))}',
                      style: TextStyle(
                        // color: Color(widget.timeColor),
                          letterSpacing: -25.0,
                          fontSize: 260,
                          fontFamily: widget.fontFamily,
                          fontWeight: widget.fontWeight),
                    )),
                    Positioned(
                        top: MediaQuery.of(context).size.height/2.4,
                        child: Text('${DateFormat('mm').format(DateFormat('h:mm').parse(formattedDate))}',
                          style: TextStyle(
                            // color: Color(widget.timeColor),
                              letterSpacing: -25.0,
                              fontSize: widget.renderImage
                                  ? 260
                                  : double.parse(widget.timeSize
                                  .toString()) >
                                  80
                                  ? 80
                                  : double.parse(
                                  widget.timeSize.toString()),
                              fontFamily: widget.fontFamily,
                              fontWeight: widget.fontWeight),
                        ))

                  ],
                )


                );})
       );
    } else {
      return FocusDetector(
          onFocusGained: () {
            setTimeOnFocus();
          },
          onFocusLost: () {
            if (timer != null) {
              timer.cancel();
            }
            if (time != null) {
              time.cancel();
            }
          },
          child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Opacity(
                    opacity: _animation.value,
                    child: widget.timeStyle == "Horizontal"
                        ? Column(children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: TextStyle(
                                      color: Color(widget.timeColor),
                                      fontSize: double.parse(
                                                  widget.timeSize.toString()) >
                                              80
                                          ? 80
                                          : double.parse(
                                              widget.timeSize.toString()),
                                      fontFamily: 'Montserrat'),
                                ),
                                Text(
                                  ' $isAmPm',
                                  style: TextStyle(
                                      color: Color(widget.timeColor),
                                      fontSize: double.parse(widget.timeSize
                                                      .toString()) -
                                                  28 >
                                              0
                                          ? double.parse(
                                                  widget.timeSize.toString()) -
                                              28
                                          : 0,
                                      fontFamily: 'Montserrat'),
                                )
                              ],
                            ),
                          ])
                        : widget.renderImage
                            ? Stack(
                                alignment: Alignment
                                    .center, // Alignment of the stacked children
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${DateFormat('hh').format(DateFormat('h:mm').parse(formattedDate))}',
                                            style: TextStyle(
                                                color: Color(widget.timeColor),
                                                fontSize: widget.renderImage
                                                    ? 260
                                                    : double.parse(widget
                                                                .timeSize
                                                                .toString()) >
                                                            80
                                                        ? 80
                                                        : double.parse(widget
                                                            .timeSize
                                                            .toString()),
                                                fontFamily: widget.fontFamily,
                                                fontWeight: widget.fontWeight),
                                          )
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            '',
                                            style: TextStyle(
                                                color: Color(widget.timeColor),
                                                fontSize: widget.renderImage
                                                    ? 260
                                                    : double.parse(widget
                                                                .timeSize
                                                                .toString()) >
                                                            80
                                                        ? 80
                                                        : double.parse(widget
                                                            .timeSize
                                                            .toString()),
                                                fontFamily: widget.fontFamily,
                                                fontWeight: widget.fontWeight),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    top: 170,
                                    left: 0, // Adjust the position as needed
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${DateFormat('mm').format(DateFormat('h:mm').parse(formattedDate))}',
                                          style: TextStyle(
                                              color: Color(widget.timeColor),
                                              fontSize: widget.renderImage
                                                  ? 260
                                                  : double.parse(widget.timeSize
                                                              .toString()) >
                                                          80
                                                      ? 80
                                                      : double.parse(widget
                                                          .timeSize
                                                          .toString()),
                                              fontFamily: widget.fontFamily,
                                              fontWeight: widget.fontWeight),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('hh').format(DateFormat('h:mm').parse(formattedDate))}',
                                      style: TextStyle(
                                          color: Color(widget.timeColor),
                                          fontSize: widget.renderImage
                                              ? 260
                                              : double.parse(widget.timeSize
                                                          .toString()) >
                                                      80
                                                  ? 80
                                                  : double.parse(widget.timeSize
                                                      .toString()),
                                          fontFamily: widget.fontFamily,
                                          fontWeight: widget.fontWeight),
                                    )
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('mm').format(DateFormat('h:mm').parse(formattedDate))}',
                                      style: TextStyle(
                                          color: Color(widget.timeColor),
                                          fontSize: widget.renderImage
                                              ? 260
                                              : double.parse(widget.timeSize
                                                          .toString()) >
                                                      80
                                                  ? 80
                                                  : double.parse(widget.timeSize
                                                      .toString()),
                                          fontFamily: widget.fontFamily,
                                          fontWeight: widget.fontWeight),
                                    ),
                                  ],
                                ),
                                if (!widget.renderImage)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$isAmPm',
                                        style: TextStyle(
                                            color: Color(widget.timeColor),
                                            fontSize: double.parse(widget
                                                            .timeSize
                                                            .toString()) -
                                                        25 >
                                                    0
                                                ? double.parse(widget.timeSize
                                                        .toString()) -
                                                    25
                                                : 0,
                                            fontFamily: widget.fontFamily,
                                            fontWeight: widget.fontWeight),
                                      ),
                                    ],
                                  ),
                              ]));
              }));
    }
  }
}

class AppDrawerIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.transparent,
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
              ]),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                  color: Colors.white,
                ),
              ]),
        ]);
  }
}

///
// 2.10.5 flutter
///
