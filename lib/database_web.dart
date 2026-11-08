import 'package:sembast_web/sembast_web.dart';

Future<Database> openBillDatabase() =>
    databaseFactoryWeb.openDatabase('share_bill_v1');
