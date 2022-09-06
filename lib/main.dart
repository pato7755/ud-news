import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: Webpage());
  }
}

class Webpage extends StatefulWidget {
  @override
  _WebpageState createState() {
    return _WebpageState();
  }
}

class _WebpageState extends State<Webpage> {
  late WebViewController _controller;
  bool isLoading = true;

  GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
            key: _globalKey,
            appBar: AppBar(
              title: const Text('UD News'),
              bottom: _createProgressIndicator(),
            ),
            body: Builder(builder: (BuildContext context) {
              return Stack(children: <Widget>[
                // isLoading
                //     ? _createProgressIndicator()
                //     : Stack(),
                WebView(
                  initialUrl: 'https://udnews.org',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (webViewController) {
                    _controller = webViewController;
                  },
                  onProgress: (int progress) {
                    print("WebView is loading (progress : $progress%)");
                  },
                  navigationDelegate: (NavigationRequest request) {
                    print('allowing navigation to $request');
                    setState(() {
                      isLoading = true;
                    });
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (String url) {
                    print('Page started loading: $url');
                  },
                  onPageFinished: (String url) {
                    print('Page finished loading: $url');
                    setState(() {
                      isLoading = false;
                    });
                  },
                  gestureNavigationEnabled: true,
                ),
              ]);
            })));
  }

  PreferredSize _createProgressIndicator() => isLoading
      ? const PreferredSize(
          preferredSize: Size(double.infinity, 4.0),
          child: SizedBox(height: 4.0, child: LinearProgressIndicator()))
      : const PreferredSize(
          preferredSize: Size(double.infinity, 0.0),
          child: SizedBox(height: 0.0, child: LinearProgressIndicator()));

  Future<bool> _exitApp(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false;
    } else {
      return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Container(
                    height: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Do you want to exit?"),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  print('yes selected');
                                  // exit(0);
                                  Navigator.of(context).pop(true);
                                },
                                child: Text("Yes"),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.red.shade800),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                                child: ElevatedButton(
                              onPressed: () {
                                print('no selected');
                                Navigator.of(context).pop();
                              },
                              child: Text("No",
                                  style: TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                              ),
                            ))
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }) ??
          false;
    }
  }

  // JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
  //   return JavascriptChannel(
  //       name: 'Toaster',
  //       onMessageReceived: (JavascriptMessage message) {
  //         Scaffold.of(context).showSnackBar(
  //           SnackBar(content: Text(message.message)),
  //         );
  //       });
  // }
}
