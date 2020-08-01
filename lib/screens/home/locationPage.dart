import 'package:flutter/material.dart';
import 'package:getflutter/getflutter.dart';
import 'package:multilocationGroceryApp/service/auth-service.dart';
import 'package:multilocationGroceryApp/service/sentry-service.dart';
import 'package:multilocationGroceryApp/service/common.dart';
import 'package:multilocationGroceryApp/style/style.dart';
import 'package:multilocationGroceryApp/service/localizations.dart';
import 'package:multilocationGroceryApp/screens/home/home.dart';
import 'package:multilocationGroceryApp/widgets/loader.dart';

SentryError sentryError = new SentryError();

class Locations extends StatefulWidget {
  final Map localizedValues;
  final String locale;
  Locations({Key key, this.locale, this.localizedValues}) : super(key: key);
  @override
  _LocationsState createState() => _LocationsState();
}

class _LocationsState extends State<Locations> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int groupValue = 0;
  List locationList;
  bool locationListLoading = false;
  @override
  void initState() {
    getLocationList();
    super.initState();
  }

  getLocationList() {
    if (mounted) {
      setState(() {
        locationListLoading = true;
      });
    }

    Common.getLocation().then((locationDataDetails) async {
      await LoginService.getlocationslist().then((onValue) {
        try {
          if (mounted) {
            setState(() {
              locationListLoading = false;
            });
          }
          if (onValue['response_code'] == 200) {
            if (mounted) {
              setState(() {
                locationList = onValue['response_data'];
                if (locationDataDetails != null) {
                  for (int i = 0; i < locationList.length; i++) {
                    if (locationDataDetails['_id'] == locationList[i]['_id']) {
                      groupValue = i;
                    }
                  }
                }
              });
            }
          } else {
            if (mounted) {
              setState(() {
                locationList = [];
              });
            }
          }
        } catch (error, stackTrace) {
          if (mounted) {
            setState(() {
              locationListLoading = false;
              locationList = [];
            });
          }
          sentryError.reportError(error, stackTrace);
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            locationListLoading = false;
            locationList = [];
          });
        }
        sentryError.reportError(error, null);
      });
    });
  }

  handleRadioValueChanged(int value) async {
    if (mounted) {
      setState(() {
        groupValue = value;
      });
    }
    return value;
  }

  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(milliseconds: 1000),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GFAppBar(
        title: Text(
          MyLocalizations.of(context).selectlocation ?? "",
          style: textbarlowSemiBoldBlack(),
        ),
        centerTitle: true,
        backgroundColor: primary,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: locationListLoading
          ? SquareLoader()
          : locationList.length == 0
              ? Center(
                  child: Image.asset('lib/assets/images/no-orders.png'),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    new Expanded(
                      child: new ListView.builder(
                        itemCount: locationList.length,
                        padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black12),
                            margin: EdgeInsets.all(8),
                            child: RadioListTile(
                              controlAffinity: ListTileControlAffinity.trailing,
                              activeColor: primary,
                              value: index,
                              groupValue: groupValue,
                              onChanged: handleRadioValueChanged,
                              title: Text(locationList[index]['locationName']),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
      bottomNavigationBar: locationListLoading || locationList.length == 0
          ? Container(height: 1)
          : Container(
              height: 46,
              margin: EdgeInsets.all(16),
              child: GFButton(
                onPressed: () async {
                  await Common.setLocation(locationList[groupValue]);
                  await Common.setAllData(null);
                  await Common.setBanner(null);
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => Home(
                          locale: widget.locale,
                          localizedValues: widget.localizedValues,
                          currentIndex: 0,
                        ),
                      ),
                      (Route<dynamic> route) => false);
                },
                color: primary,
                blockButton: true,
                text: MyLocalizations.of(context).proceed,
                textStyle: textBarlowRegularrBlack(),
              ),
            ),
    );
  }
}
