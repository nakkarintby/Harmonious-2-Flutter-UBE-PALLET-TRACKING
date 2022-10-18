class PostPallet {
  String? iTRNo;
  String? rFID;
  String? rFIDHEX;
  String? scanBy;
  String? createdTime;

  PostPallet(
      {this.iTRNo, this.rFID, this.rFIDHEX, this.scanBy, this.createdTime});

  PostPallet.fromJson(Map<String, dynamic> json) {
    iTRNo = json['ITRNo'];
    rFID = json['RFID'];
    rFIDHEX = json['RFIDHEX'];
    scanBy = json['ScanBy'];
    createdTime = json['CreatedTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ITRNo'] = this.iTRNo;
    data['RFID'] = this.rFID;
    data['RFIDHEX'] = this.rFIDHEX;
    data['ScanBy'] = this.scanBy;
    data['CreatedTime'] = this.createdTime;
    return data;
  }
}
