import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:smart_power_launcher/AtoZSlider.dart';
import 'package:smart_power_launcher/main.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';

Timer timer;
List<String> appNames = [];

class SecondPage extends StatelessWidget {

  const SecondPage();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body :AppsDrawer());
  }
}



class AppsDrawer extends StatefulWidget {
  const AppsDrawer();



  @override
  State<AppsDrawer> createState() => _AppsDrawerState();
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

class _AppsDrawerState extends State<AppsDrawer> with TickerProviderStateMixin, WidgetsBindingObserver {
  var loading = true;
  var powerSavingMode = 'off';
  List<Widget> favouriteList = [];
  List<Widget> normalList = [];
  AnimationController _controller1;
  Animation<double> animation2;
  var v;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }



  getAppsList() async {
    final prefs = await SharedPreferences.getInstance();
    var menus = prefs.getString('menus');

    if (menus == null || menus == "null") {
      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);
      List<AppsList> futureList = [];
      var appsList = await apps;
      for (var i in appsList) {
        AppsList appsLists = AppsList(
            i.appName, i.packageName, i is ApplicationWithIcon ? i.icon : null);
        appsLists.icon = Uint8List.fromList(appsLists.icon.cast<int>());
        bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);

        if (isSystemApp == false || i.appName.toLowerCase() == "phone") {
          futureList.add(appsLists);
          appNames.add(i.appName.toString());
        }
      }

      futureList.sort((a, b) => a.appName
          .toString()
          .toLowerCase()
          .compareTo(b.appName.toString().toLowerCase()));

      var z =
          await prefs.setString('menus', jsonEncode(futureList)).then((value) {
        menus = prefs.getString('menus');
        return menus;
      });
      menus = z;
      v = getUserInfo(menus);

      var storedList = await v;

      storedList.forEach((element) {
        element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
      });
      setStateIfMounted(() {
        strList = storedList;
        // list = storedList;
        loading = false;
      });
    } else {
      if (strList.length == 0) {
        var menus = prefs.getString('menus');

        v = await getUserInfo(menus);
        if(v != null) {
          v.forEach((element) {
            element['icon'] = Uint8List.fromList(element['icon'].cast<int>());
          });

          setStateIfMounted(() {
            strList = v;
            loading = false;
          });
        } else {
          setStateIfMounted(() {
            strList = strList;
            loading = false;
          });
        }

      }
    }
  }


  newMethod() async {
    // strList
    final prefs = await SharedPreferences.getInstance();
    var futureList = strList.toList();
    var tempStr = [];
    print('NEW METHOD');
    if(appNames.isEmpty){
      for (var i in futureList) {
        appNames.add(i['appName']);
      }
    }
    if (strList.length != 0 && loading == false) {
      Future<List<Application>> apps = DeviceApps.getInstalledApplications(
          includeAppIcons: true, includeSystemApps: true);
      var futureList = [];


      var appsList = await apps;
      for (var i in appsList) {

          bool isSystemApp = await InstalledApps.isSystemApp(i.packageName);

        if(appNames.isNotEmpty){
          if(!isSystemApp && i.appName.length >0){
            tempStr.add(i.appName);
          }

          //Check for newly Installed Apps;
          if(!isSystemApp && i.appName.length >0 && !appNames.contains(i.appName)){

            setStateIfMounted((){
              loading= true;
            });
            Map<String, dynamic> data = {};
            data['appName'] = i.appName;
            data['packageName'] = i.packageName;
            data['icon'] = i is ApplicationWithIcon ? i.icon : null;
            data['icon'] = Uint8List.fromList(data['icon'].cast<int>());
            futureList.add(data);
            appNames.add(i.appName);
          }

        }

      }

      if(futureList.isNotEmpty){

        Fluttertoast.showToast(
          msg: 'Refrshing Apps',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        strList.addAll(futureList);

      }


      //Check for newly unInstalled Apps;
      // print('APP NAMES : '+appNames.toString());
      var t = appNames;
      var removedEle = [];
      for(var j in t){
        var index = tempStr.indexWhere((element) =>
        element.toLowerCase().toString() ==
            j.toLowerCase().toString());
        if(index == -1) {
          removedEle.add(j);
        }
      }

      // print("REMOVED ARRAY : "+removedEle.toString());
      if(removedEle.length > 0){
        Fluttertoast.showToast(
          msg: 'Refrshing Apps',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setStateIfMounted((){
          loading = true;
        });
        for(var k in removedEle) {
          strList.removeWhere((element) =>
          element['appName'] == k);
          appNames.removeWhere((element) => element == k);
        }

      }

      //setting local storage
      if(removedEle.isNotEmpty || futureList.isNotEmpty) {
        await prefs.setString('menus', jsonEncode(strList)).then((value) {
          print('End');

          strList.sort((a, b)  {
            return a['appName'].toString()
              .toLowerCase()
              .compareTo(b['appName'].toString().toLowerCase());
          });

          setStateIfMounted(() {
            strList = strList;
            loading = false;
          });
        });
      }

    }



  }

  @override
  void initState() {
    super.initState();
    if (strList.length == 0) {
      getAppsList();
    }

    _controller1 = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(_controller1)
      ..addListener(() {});
    setStateIfMounted(() {
      loading = false;
    });
  }



  @override
  void dispose() {
    print('DELETED');
    _controller1.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    if(state == AppLifecycleState.inactive && mounted){
      Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
    }
  }



  @override
  Widget build(BuildContext context) {
    if (strList.length != 0 && loading == false) {
      Future.delayed(Duration(milliseconds: 50), () {
        _controller1.forward();
      });
      return
        FocusDetector(
          onFocusGained: () {
            // startTimer();
            newMethod();
            WidgetsBinding.instance.addObserver(this);

          },
          onFocusLost: () {
          },
          child:
          Dismissible(
              background: Container(color: Colors.transparent),
              // Show a red background as the item is swiped away.
          // background: Container(
          //   color: Colors.black,
          // ),
          key: Key('drawer'),
              // direction: DismissDirection.endToStart,
              onDismissed: (direction) {
            // Navigator.pushReplacement(
            //     context,
            //     PageTransition(
            //         type: PageTransitionType.fade,
            //         duration: Duration(milliseconds: 100),
            //         child: CountingApp()));

            if(Navigator.canPop(context)) {
              Navigator.popUntil(context, ModalRoute.withName(Navigator.defaultRouteName));
            }
          },
          child: Scaffold(
              backgroundColor: Colors.black,
              body: FadeTransition(
                  opacity: animation2,
                  // opacity: animation2,
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(5, 30, 0, 0),
                      child: AtoZSliderPageMain(
                          strList,
                          ()=> {

                          },
                          (i) => {
                                debugPrint("Click on : (" +
                                    i.toString() +
                                    ") -> " +
                                    strList[i].appName)
                              },
                          ))))));
    } else {
      return Dismissible(

          dismissThresholds: {
            DismissDirection.horizontal: 0.8,
            DismissDirection.vertical: 0.8,
          },
          // Show a red background as the item is swiped away.
          // background: Container(
          //   color: Colors.red,
          // ),
          key: Key('drawer'),
          onDismissed: (direction) {
            Navigator.pop(context);
          },
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/dino.gif',
                height: 150,
                width: 150,
                fit: BoxFit.contain,
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Text(
                    'Please wait while we cache the Applications to save Battery',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        decorationStyle: TextDecorationStyle.dashed),
                  ),
                ),
              )

            ],
          )));
    }
  }
}

class AppsList {
  String appName;
  String packageName;
  Uint8List icon;

  AppsList(this.appName, this.packageName, this.icon);

  AppsList.fromJson(Map<String, dynamic> json) {
    appName = json['appName'];
    packageName = json['packageName'];
    icon = json['icon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['appName'] = this.appName;
    data['packageName'] = this.packageName;
    data['icon'] = this.icon;
    return data;
  }

  @override
  String toString() {
    return '{ "appName": $appName, "packageName": $packageName, "icon": $icon }';
  }
}
