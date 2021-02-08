import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:mdi/mdi.dart';
import 'dart:collection';
import 'Curve.dart';
import 'accordion.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() => runApp(Phoenix(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Home(),
      ),
    ));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ϵ-NFA to DFA Converter',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            padding: EdgeInsets.symmetric(horizontal: 10),
            icon: Icon(Icons.refresh),
            hoverColor: Colors.blue[400],
            tooltip: 'Refresh Converter',
            onPressed: () {
              Phoenix.rebirth(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            NFAtoDFASolver(),
          ],
        ),
      ),
    );
  }
}

class NFAtoDFASolver extends StatefulWidget {
  @override
  _NFAtoDFASolverState createState() => _NFAtoDFASolverState();
}

class _NFAtoDFASolverState extends State<NFAtoDFASolver> {
  // form validators
  var _formKey = GlobalKey<FormState>();
  var _formKey2 = GlobalKey<FormState>();

  // variables for UI and algorithm
  double _padding = 0.0;
  int noOfStates = 0, noOfAlphabets = 0, newStates = 0;
  int ns = 0, na = 0;
  Color _color = Colors.white;
  String info = "", info2 = "", cinfo = "";
  List<String> statesList = [], alphabetsList = [], newFinalStates = [];
  bool _visible = false, _visible2 = false;
  List<List<String>> inputTable = [];
  Map<String, String> closureMap = {};

  // variable for animation
  List<List<String>> outputTable = [];
  List<String> outputStates = [], outputAlphabets = [];
  List<Widget> stack = [];

  // function to get the info of DFA
  dfaInfo() {
    outputStates = [];
    outputAlphabets = [];
    info2 = "Q = { ";
    for (int i = 0; i < newStates; ++i) {
      info2 += String.fromCharCode(i + 65);
      statesList.add(String.fromCharCode(i + 65));
      outputStates.add(String.fromCharCode(i + 65));
      if (i != newStates - 1) info2 += ", ";
    }
    info2 += " }\nΣ = { ";
    for (int i = 0; i < noOfAlphabets; ++i) {
      info2 += String.fromCharCode(i + 97);
      alphabetsList.add(String.fromCharCode(i + 97));
      outputAlphabets.add(String.fromCharCode(i + 97));
      if (i != noOfAlphabets - 1) info2 += ", ";
    }
    info2 += " }\nq0 = { A }\nF = { ";
    for (int i = 0; i < newFinalStates.length; ++i) {
      info2 += newFinalStates[i];
      if (i != newFinalStates.length - 1) info2 += ", ";
    }
    info2 += " }";
  }

  // function to get the info of NFA
  nfaInfo() {
    info = "Q = { ";
    alphabetsList.add("");
    for (int i = 0; i < noOfStates; ++i) {
      info += String.fromCharCode(i + 65);
      statesList.add(String.fromCharCode(i + 65));
      if (i != noOfStates - 1) info += ", ";
    }
    info += " }\nΣ = { ";
    for (int i = 0; i < noOfAlphabets; ++i) {
      info += String.fromCharCode(i + 97);
      alphabetsList.add(String.fromCharCode(i + 97));
      info += ", ";
    }
    alphabetsList.add("ϵ");
    info += "ϵ }\nq0 = { A }\nF = { ";
    info += String.fromCharCode(65 + noOfStates);
    info += " }";
  }

  // function to get the info of Closures
  closureInfo() {
    cinfo = "";
    int temp = 0;
    closureMap.forEach((key, value) {
      cinfo += "ϵ-Closure for ";
      cinfo += key;
      cinfo += " is ";
      cinfo += value;
      cinfo += "\n[ New assigned state: ";
      cinfo += String.fromCharCode(temp + 65);
      cinfo += " ]\n";
      ++temp;
    });
  }

  // function to convert NFA to DFA
  void solve() {
    // list for states
    List<String> states = [];
    // list for alphabets
    List<String> alphabets = [];
    // Setting the set of States
    for (int i = 0; i < noOfStates; ++i)
      states.add(String.fromCharCode(i + 65));
    // Setting the set of Alphabets
    for (int i = 0; i < noOfAlphabets; ++i)
      alphabets.add(String.fromCharCode(i + 97));
    alphabets.add("ϵ");
    // map for State Transition Table
    Map<String, String> stateTransitionTable = {};
    // filling the State Transition Table
    for (int i = 0; i < noOfStates; ++i) {
      for (int j = 0; j < noOfAlphabets + 1; ++j) {
        stateTransitionTable[states[i] + alphabets[j]] = inputTable[i][j];
        //print(stateTransitionTable[states[i] + alphabets[j]]);
        print("-" + inputTable[i][j] + "-");
      }
      print("\n");
    }
    // map to maintain the closure table
    Map<String, String> closureTable = {};
    // map to maintain the new state transition table
    Map<String, String> newTable = {};
    // sets for new states coming
    Set<String> newStatesSet = {};
    // sets for list of all the closures
    Set<String> allClosures = {};
    // queue for the algorithm for maintaining the new coming state in execution
    Queue<String> newStatesQueue = new Queue<String>();
    // algorithm starts
    newStatesSet.add(states[0]);
    newStatesQueue.add(states[0]);
    while (newStatesQueue.isNotEmpty) {
      // set to store the unique list of curr state in the algo for single time insertion in queue
      Set<String> currStates = {};
      // queue for the algorithm for maintaining the curr state in execution
      Queue<String> currQueue = new Queue<String>();
      // geting the closure for current state
      String currStateIn = newStatesQueue.first;
      newStatesQueue.removeFirst();
      for (int i = 0; i < currStateIn.length; ++i) {
        String temp = "";
        temp += currStateIn[i];
        currQueue.add(temp);
      }
      while (currQueue.isNotEmpty) {
        String currState = currQueue.first;
        currQueue.removeFirst();
        currStates.add(currState);
        if (stateTransitionTable[currState + alphabets[noOfAlphabets]] != "-") {
          String temp =
              stateTransitionTable[currState + alphabets[noOfAlphabets]];
          if (temp == null) temp = "";
          for (int i = 0; i < temp.length; ++i) {
            String str = "";
            str += temp[i];
            if (!currStates.contains(str)) {
              currStates.add(str);
              currQueue.add(str);
            }
          }
        }
      }
      String closure = "";
      for (var it in currStates) closure += it;
      closureTable[currStateIn] = closure;
      closureMap[currStateIn] = closure;
      allClosures.add(closure);
      // for the curr state finding the transitions for all the alphabets
      for (int i = 0; i < noOfAlphabets; ++i) {
        Set<String> currClosure = {};
        for (int j = 0; j < closure.length; ++j) {
          String temp = "";
          temp += closure[j];
          if (stateTransitionTable[temp + alphabets[i]] != "-") {
            String temp2 = stateTransitionTable[temp + alphabets[i]];
            if (temp2 == null) temp2 = "";
            for (int k = 0; k < temp2.length; ++k) {
              String str = "";
              str += temp2[k];
              currClosure.add(str);
            }
          }
        }
        String newCurrState = "";
        for (var it in currClosure) newCurrState += it;
        if (newCurrState != "" && !newStatesSet.contains(newCurrState)) {
          newStatesSet.add(newCurrState);
          newStatesQueue.add(newCurrState);
        }
        if (newCurrState == "")
          newTable[closure + alphabets[i]] = "-";
        else
          newTable[closure + alphabets[i]] = newCurrState;
      }
    }
    Map<String, String> newStatesMap = {};
    int tmp = 0;
    for (var it in allClosures) {
      String temp = "";
      temp += String.fromCharCode(tmp + 65);
      ++tmp;
      newStatesMap[it] = temp;
      for (int i = 0; i < it.length; ++i) {
        String s = "";
        s += it[i];
        if (s == states[noOfStates - 1]) {
          newFinalStates.add(temp);
          break;
        }
      }
    }
    outputTable = [];
    for (int i = 0; i < allClosures.length; ++i) {
      List<String> ls = [];
      for (int j = 0; j < noOfAlphabets; ++j) ls.add("-");
      outputTable.add(ls);
    }
    // storing back the states
    for (var it in allClosures) {
      String newState = newStatesMap[it];
      ++newStates;
      for (int j = 0; j < noOfAlphabets; ++j) {
        outputTable[newState.codeUnitAt(0) - 65][j] =
            newStatesMap[closureTable[newTable[it + alphabets[j]]]];
      }
    }
    alphabetsList.remove("ϵ");
    _visible2 = true;
  }

  // function to display input fields
  Widget inputsDisplay() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      ns = int.parse(val);
                    });
                  },
                  validator: (String states) {
                    for (int i = 0; i < states.length; ++i)
                      if (!(states.codeUnitAt(i) > 48 &&
                          states.codeUnitAt(i) < 59))
                        return "Enter only integer values";
                    if (states == "") return "Enter an integer value";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Number of States",
                    labelText: "Number of States",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: false,
                    icon: Icon(Mdi.alphabeticalVariant),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  maxLength: 5,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: TextFormField(
                  onChanged: (val) {
                    setState(() {
                      na = int.parse(val);
                    });
                  },
                  validator: (String alphabets) {
                    for (int i = 0; i < alphabets.length; ++i)
                      if (!(alphabets.codeUnitAt(i) > 48 &&
                          alphabets.codeUnitAt(i) < 59))
                        return "Enter only integer values";
                    if (alphabets == "") return "Enter an integer value";
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Enter Number of Alphabets",
                    labelText: "Number of Alphabets",
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                    border: OutlineInputBorder(),
                    fillColor: Colors.white,
                    filled: false,
                    icon: Icon(Mdi.alphabetical),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  maxLength: 5,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      child: Text('Next'),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          if (_formKey.currentState.validate()) {
                            _padding = 10.0;
                            _visible = true;
                            _visible2 = false;
                            _color = Colors.grey[300];
                            noOfAlphabets = na;
                            noOfStates = ns;
                            nfaInfo();
                            for (int i = 0; i < noOfStates; ++i) {
                              List<String> temp = [];
                              for (int j = 0; j < noOfAlphabets + 1; ++j)
                                temp.add("-");
                              inputTable.add(temp);
                            }
                          }
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // function to display NFA related info
  Widget nfaDisplay() {
    return Column(
      children: [
        Visibility(
          visible: _visible,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 10.0),
                child: Text(
                  'Details for ϵ-NFA',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.0),
                child: Container(
                  color: _color,
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  padding: EdgeInsets.symmetric(
                      vertical: _padding, horizontal: 20.0),
                  child: Text(
                    info,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 1.0),
                child: Text(
                  'State Transition Table for ϵ-NFA',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: 25.0),
                child: Form(
                  key: _formKey2,
                  child: DataTable(
                    showBottomBorder: false,
                    columns: [
                      DataColumn(label: Text("")),
                      for (int i = 0; i < noOfAlphabets; ++i)
                        DataColumn(
                          label: Text(String.fromCharCode(i + 97)),
                        ),
                      DataColumn(label: Text("ϵ")),
                    ],
                    rows: [
                      for (int j = 0; j < noOfStates; ++j)
                        DataRow(
                          cells: [
                            DataCell(Text(String.fromCharCode(j + 65))),
                            for (int i = 0; i < noOfAlphabets + 1; ++i)
                              DataCell(
                                TextFormField(
                                  onChanged: (val) {
                                    setState(() {
                                      int ii = i, jj = j;
                                      inputTable[jj][ii] = val;
                                      if (val == "") inputTable[jj][ii] = "-";
                                      print(inputTable);
                                    });
                                  },
                                  validator: (String val) {
                                    if (val == "") return ".";
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    border: UnderlineInputBorder(),
                                    fillColor: Colors.white,
                                    filled: false,
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: false,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      child: Text('Convert to DFA'),
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          newStates = 0;
                          info2 = "";
                          cinfo = "";
                          newFinalStates = [];
                          closureMap = {};
                          stack = [];
                          solve();
                          dfaInfo();
                          closureInfo();
                        });
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // function to display DFA related info
  Widget dfaDisplay() {
    return Column(
      children: [
        Visibility(
          visible: _visible2,
          child: Column(
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 10.0),
                child: Text(
                  'Closures',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.0),
                child: Container(
                  color: _color,
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  padding: EdgeInsets.symmetric(
                      vertical: _padding, horizontal: 20.0),
                  child: Text(
                    cinfo,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 10.0),
                child: Text(
                  'Details for DFA',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1.0),
                child: Container(
                  color: _color,
                  margin:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  padding: EdgeInsets.symmetric(
                      vertical: _padding, horizontal: 20.0),
                  child: Text(
                    info2,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(20.0, 20.0, 10.0, 1.0),
                child: Text(
                  'State Transition Table for DFA',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(vertical: 25.0),
                child: DataTable(showBottomBorder: false, columns: [
                  DataColumn(
                    label: Text(""),
                  ),
                  for (int i = 0; i < noOfAlphabets; ++i)
                    DataColumn(
                      label: Text(String.fromCharCode(i + 97)),
                    ),
                ], rows: [
                  for (int j = 0; j < newStates; ++j)
                    DataRow(
                      cells: [
                        DataCell(Text(String.fromCharCode(j + 65))),
                        for (int i = 0; i < noOfAlphabets; ++i)
                          DataCell(Text((outputTable[j][i] != null)
                              ? outputTable[j][i]
                              : "-")),
                      ],
                    )
                ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double diff = 25.0;
  void curve(double start, double end, String c) {
    bool right;
    double _top, _top2;
    IconData icon;
    double dist;
    int cnt = 0;
    for (int i = 0; i < (c.codeUnitAt(0) - 97); ++i) {
      if (outputTable[start.toInt()][i] ==
          outputTable[start.toInt()][c.codeUnitAt(0) - 97]) ++cnt;
    }
    print('$start to $end on $c with count $cnt');
    right = start < end ? true : false;
    dist = right ? -150 : 150;
    icon =
        right ? Icons.arrow_forward_ios_rounded : Icons.arrow_back_ios_rounded;
    _top = right
        ? 46 + newStates * diff - (end - start - 1) * diff
        : 144 + newStates * diff + (start - end - 1) * diff;
    _top2 = right
        ? 60 + newStates * diff - (end - start - 1) * diff
        : 132 + newStates * diff + (start - end - 1) * diff;
    double left = 48 + 150 * start;
    if (start != end) {
      stack.add(
        Positioned(
          top: 107 + newStates * diff,
          left: left,
          child: CustomPaint(
            painter: CurvePainter(distance: end - start, right: right),
          ),
        ),
      );
      stack.add(
        Positioned(
          top: _top,
          left: 48 + 150 * (start + end) / 2,
          child: Icon(icon),
        ),
      );
      stack.add(
        Positioned(
          top: _top2,
          left: 48 + 150 * (start + end) / 2 + cnt * 12,
          child: Text(
            (cnt > 0) ? ", $c" : "$c",
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      );
    } else {
      stack.add(
        Positioned(
          top: right ? 56 + newStates * diff : 134 + newStates * diff,
          left: 38 + 150 * (start + end) / 2,
          child: RotationTransition(
            turns: right
                ? AlwaysStoppedAnimation(270 / 360)
                : AlwaysStoppedAnimation(90 / 360),
            child: Icon(Icons.replay),
          ),
        ),
      );
      stack.add(
        Positioned(
          top: right ? 55 + newStates * diff : 135 + newStates * diff,
          left: 28 + 150 * (start + end) / 2,
          child: Text(
            c,
            style: TextStyle(
              fontSize: 18.0,
            ),
          ),
        ),
      );
    }
  }

  void calculate() {
    for (int i = 0; i < newStates; ++i) {
      for (int j = 0; j < noOfAlphabets; ++j) {
        if (outputTable[i][j] != null) {
          curve(
              double.parse(i.toString()),
              double.parse((outputTable[i][j].codeUnitAt(0) - 65).toString()),
              String.fromCharCode(j + 97));
        }
      }
    }
    stack.add(
      Positioned(
        top: 75 + newStates * (diff) + 28,
        left: 1,
        child: Icon(
          Icons.arrow_forward,
        ),
      ),
    );

    for (int i = 0; i < newStates; ++i)
      stack.add(
        Positioned(
          top: 75 + newStates * (diff),
          left: 20 + 150 * double.parse(i.toString()),
          child: Container(
            decoration: BoxDecoration(
              color: (newFinalStates.contains(String.fromCharCode(i + 65)))
                  ? Colors.green
                  : Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Text(
              String.fromCharCode(i + 65),
              style: TextStyle(fontSize: 25),
            ),
          ),
        ),
      );
  }

  Widget draw() {
    calculate();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 200 + newStates * diff * 2,
        width: double.parse((150 * (newStates - 1) + 100).toString()),
        child: Stack(
          children: stack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableTheme(
      data: const ExpandableThemeData(
        iconColor: Colors.blue,
        useInkWell: true,
      ),
      child: Column(
        children: <Widget>[
          inputsDisplay(),
          _visible ? Accordion(nfaDisplay(), "ϵ-NFA Information") : Container(),
          _visible2 ? Accordion(dfaDisplay(), "DFA Information") : Container(),
          _visible2
              ? Accordion(
                  outputTable.length == 0 ? Container() : draw(), "DFA Diagram")
              : Container(),
        ],
      ),
    );
  }
}
