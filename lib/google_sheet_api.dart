

import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi{
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "expensetracker-375804",
  "private_key_id": "",
  "private_key": "-----BEGIN PRIVATE KEY-----\\nKyDRxYw3FAYaagWD04gQDNgu3Q8uB3fl9D3HT8rDTecaT45HbXT9aWTYXxkDd+E7\nB8HDvx4a0+OXH8Wq7wI6EonzwNAQKq3NP/vPlcZrx+K4p+0fHPluF60ONJcNdm50\nHJU9GKM8DjyONtMP/D6eUINrJ17t5WM3lKgdEIABSfQ5Bm8WzOzlkM6ewSEFpiAa\n5gfpYvk4pNFc9xoNSxLwnqXf3KQH0qRe7Lqh0Me5yXtyotbiHL2RSmSqqF4mUU4O\nPs0ex1e3HlQoDaRX4dYyLLRkVG0yhHpeLMovWcJCxT+WeFI+zznUd0T1hqB8Qt2o\nYrYAF5LNAgMBAAECggEADaUVSE+gNKhGsBH69S5UT1Hyg83bxhYEimcLvSGQV4MM\n/+DEFTLRFZ8BKel8bpJmSAqRErY+vscT1/BNYh4UK9MYw0LCcLtX/cgvS7yG0Ea3\nQuKj14T9gw9laHknLBuK8ux/zKkIHUxVLSKfZXcxSjvzHZ/cZvIacdz0cgoCWKO1\nfFEswjVX0sZ6Zk8afsY8rAx4EWg6AnzhAlUh0aJfAOs5qVfz5qrHwWaQm8XkChHe\nueWc/1ldG+d+RZdu7R60bV2aYDUpIGwrDnOimQ1sTGiH06+P0yRnYLGGPHqNK7zX\nYpmeD+gHGO56RGFxpAJirm/wHPwoHLUT5h9ktzSkAQKBgQDyNa1E1aB9PvCEFiF3\n5MDcHU4fU49GPWH73yCWbXdfZvRY3dfMK9QQsN2O7CdbGJVlWWL/8b9p/X9Tkg4K\nWO9sCpzxwldX0yZcIZbhKAopH2V1hSGghW0gl7mA6p3q45KUDTTEyLb4IihZGwSN\nm9KASLMOT2g9qroFg5hwYcqljQKBgQDdc7VrO8uKT0mIUk80Q4SKhu60ODkWXF3X\n/BANB4uXs84RDgVRUox07B8FDqt1kB1J1Q2Dr+0cKPCIgIJLLt4M5z7b4tN2wTc2\nYscMjWkgkTHHHFxURlNy1p340EdTJVEz2Hdhrj+FNhyWp9sN93ByepMdpC7gAe2T\nkrfeDgYyQQKBgAHlW6rbRTtVv8o45iArITtX22GxZMC3AEpZb8bdqn6LrsP3UJYf\njbRnvgQ9Yv16jsjRT04TlVz+B/4eeY+pLI6a8qmNzOM6GuXDuYufpZy2yzOFTEMW\naElGBsS0kXHiQCZ6h/w2WgBNPCWeaYW2P4qThxtIkddRu80JP6s5iL2NAoGBAL16\nwrDFEev+2VDt9F0opCCPQXEsZhQu5hDm2Kj9WsBrlZbcI0qo0gs8+XGvUp+dtqG0\nzQJvJfchRGXXZySDLnVl60/jLcJ/oglDzUJ9QIUgFrJiHtHw9nfdEH+TXmPTGz68\nKbGHkUwet6lkaDb0D9+z52rGT2FV5PyO3gn+f+jBAoGBAMev7IrLIuJBmmeI160h\nepmCeI/2thM1Sv5nE60SBAKejDG8j1AI5da7PI6YLp3bQwgCKA+wdh5HceDabBdG\nu+fwcMqJE6/ICx9gS5JUaKMPxd+VWHEmZ5lD6jr4uRiHeGDpjjy7qCJIL7R3StqI\nEI2WPk6VhGJoctTotCkRXp5A\n-----END PRIVATE KEY-----\n",
  "client_email": "",
  "client_id": "",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/expensetracker%40expensetracker-375804.iam.gserviceaccount.com"
  }

  ''';

  static final _spreadsheetId = '';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  static int numberOfTransactions=0;
  static List<List<dynamic>> currentTransactions=[];
  static bool loading = true;

//initialise the spreadsheet
  Future init() async{
    final ss= await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Sheet1');
    countRows();
  }
//count the number of rows in the column
static Future countRows() async{
    while((await _worksheet!.values
    .value(column:1, row:numberOfTransactions+1))!=''){
      numberOfTransactions++;
    }
    loadTransactions();
}

static Future loadTransactions() async{
    if(_worksheet==null)return;
    for(int i=1;i<numberOfTransactions;i++){
      final String transactionName= await _worksheet!.values.value(column: 1, row: i+1);
      final String transactionAmount= await _worksheet!.values.value(column: 2, row: i+1);
      final String transactionType= await _worksheet!.values.value(column: 3, row: i+1);

      if(currentTransactions.length<numberOfTransactions){
        currentTransactions.add([transactionName,transactionAmount,transactionType]);
      }
    }
    loading=false;
}

static Future insert(String name,String amount,bool _isIncome) async{
    if(_worksheet==null) return;
    numberOfTransactions++;
    currentTransactions.add([name,amount,_isIncome==true?'income':'expense']);
    await _worksheet!.values.appendRow([name,amount,_isIncome==true?'income':'expense']);
}
static double calculateIncome(){
    double totalIncome = 0;
    for(int i=0;i<currentTransactions.length;i++){
      if(currentTransactions[i][2]=='income'){
        totalIncome+=double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
}
static double calculateExpense(){
    double totalExpense = 0;
    for(int i=0;i<currentTransactions.length;i++){
      if(currentTransactions[i][2]=='expense'){
        totalExpense+=double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }

}