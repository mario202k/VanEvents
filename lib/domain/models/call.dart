class Call {
  String callerId;
  String callerName;
  String callerPic;
  String receiverId;
  String receiverName;
  String receiverPic;
  String channelId;
  bool hasDialled;

  Call({this.callerId, this.callerName, this.callerPic, this.receiverId,
      this.receiverName, this.receiverPic, this.channelId, this.hasDialled});

  Map<String, dynamic> toMap() {
    return {
      'callerId': this.callerId,
      'callerName': this.callerName,
      'callerPic': this.callerPic,
      'receiverId': this.receiverId,
      'receiverName': this.receiverName,
      'receiverPic': this.receiverPic,
      'channelId': this.channelId,
      'hasDialled': this.hasDialled,
    };
  }

  factory Call.fromMap(Map<String, dynamic> map) {
    return new Call(
      callerId: map['callerId'] as String,
      callerName: map['callerName'] as String,
      callerPic: map['callerPic'] as String,
      receiverId: map['receiverId'] as String,
      receiverName: map['receiverName'] as String,
      receiverPic: map['receiverPic'] as String,
      channelId: map['channelId'] as String,
      hasDialled: map['hasDialled'] as bool,
    );
  }
}