class KraRaceResultResponse {
  final KraHeader header;
  final KraBody body;

  KraRaceResultResponse({
    required this.header,
    required this.body,
  });

  factory KraRaceResultResponse.fromJson(Map<String, dynamic> json) {
    return KraRaceResultResponse(
      header: KraHeader.fromJson(json['response']['header']),
      body: KraBody.fromJson(json['response']['body']),
    );
  }

  factory KraRaceResultResponse.fromXml(String xmlString) {
    // XML 파싱은 xml 패키지 사용
    // 현재는 JSON만 사용하므로 나중에 구현
    throw UnimplementedError('XML parsing not implemented');
  }
}

class KraHeader {
  final String resultCode;
  final String resultMsg;

  KraHeader({
    required this.resultCode,
    required this.resultMsg,
  });

  factory KraHeader.fromJson(Map<String, dynamic> json) {
    return KraHeader(
      resultCode: json['resultCode'] ?? '',
      resultMsg: json['resultMsg'] ?? '',
    );
  }

  bool get isSuccess => resultCode == '00';
}

class KraBody {
  final List<KraRaceItem> items;
  final int numOfRows;
  final int pageNo;
  final int totalCount;

  KraBody({
    required this.items,
    required this.numOfRows,
    required this.pageNo,
    required this.totalCount,
  });

  factory KraBody.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'];
    List<KraRaceItem> itemsList = [];

    if (itemsData != null) {
      if (itemsData['item'] is List) {
        itemsList = (itemsData['item'] as List)
            .map((item) => KraRaceItem.fromJson(item))
            .toList();
      } else if (itemsData['item'] is Map) {
        itemsList = [KraRaceItem.fromJson(itemsData['item'])];
      }
    }

    return KraBody(
      items: itemsList,
      numOfRows: int.tryParse(json['numOfRows']?.toString() ?? '0') ?? 0,
      pageNo: int.tryParse(json['pageNo']?.toString() ?? '0') ?? 0,
      totalCount: int.tryParse(json['totalCount']?.toString() ?? '0') ?? 0,
    );
  }
}

class KraRaceItem {
  // 기본 정보
  final String hrNo;           // 마번
  final String hrName;         // 마명
  final String hrNameEn;       // 영문마명
  final int age;               // 연령
  final String sex;            // 성별
  final String name;           // 국적
  
  // 기수/조교사 정보
  final String jkNo;           // 기수번호
  final String jkName;         // 기수명
  final String jkNameEn;       // 영문기수명
  final String trNo;           // 조교사번호
  final String trName;         // 조교사명
  final String trNameEn;       // 영문조교사명
  final String owNo;           // 마주번호
  final String owName;         // 마주명
  final String owNameEn;       // 영문마주명
  
  // 경주 정보
  final String meet;           // 경마장 (서울/제주/부산경남)
  final String rcDate;         // 경주일자
  final String rcDay;          // 경주요일
  final int rcNo;              // 경주번호
  final int rcDist;            // 경주거리
  final String rcName;         // 경주명
  
  // 경주 결과
  final int ord;               // 순위
  final int chulNo;            // 출주번호
  final double rcTime;         // 경주기록
  final String wgHr;           // 마체중
  final double wgBudam;        // 부담중량
  final String diffUnit;       // 착차
  final double winOdds;        // 단승식배당률
  final double plcOdds;        // 복승식배당률
  
  // 경주 조건
  final String budam;          // 부담구분
  final String prizeCond;      // 경주조건
  final String rank;           // 등급조건
  final String ageCond;        // 연령조건
  final String sexCond;        // 성별조건
  final String weather;        // 날씨
  final String track;          // 주로
  
  // 상금
  final int chaksun1;          // 1착상금
  final int chaksun2;          // 2착상금
  final int chaksun3;          // 3착상금
  final int chaksun4;          // 4착상금
  final int chaksun5;          // 5착상금
  
  // 구간 기록 (서울)
  final double seS1fAccTime;   // 서울 S1F 통과누적기록
  final double seG3fAccTime;   // 서울 G3F 통과누적기록
  final double seG1fAccTime;   // 서울 G1F 통과누적기록
  final double se_3cAccTime;   // 서울 3코너 통과누적기록
  final double se_4cAccTime;   // 서울 4코너 통과누적기록
  
  // 구간 순위
  final int sjS1fOrd;          // 서울,제주 S1F 구간순위
  final int sjG3fOrd;          // 서울,제주 G3F 구간순위
  final int sjG1fOrd;          // 서울,제주 G1F 구간순위
  final int sj_3cOrd;          // 서울,제주 3코너 순위
  final int sj_4cOrd;          // 서울,제주 4코너 순위

  KraRaceItem({
    required this.hrNo,
    required this.hrName,
    required this.hrNameEn,
    required this.age,
    required this.sex,
    required this.name,
    required this.jkNo,
    required this.jkName,
    required this.jkNameEn,
    required this.trNo,
    required this.trName,
    required this.trNameEn,
    required this.owNo,
    required this.owName,
    required this.owNameEn,
    required this.meet,
    required this.rcDate,
    required this.rcDay,
    required this.rcNo,
    required this.rcDist,
    required this.rcName,
    required this.ord,
    required this.chulNo,
    required this.rcTime,
    required this.wgHr,
    required this.wgBudam,
    required this.diffUnit,
    required this.winOdds,
    required this.plcOdds,
    required this.budam,
    required this.prizeCond,
    required this.rank,
    required this.ageCond,
    required this.sexCond,
    required this.weather,
    required this.track,
    required this.chaksun1,
    required this.chaksun2,
    required this.chaksun3,
    required this.chaksun4,
    required this.chaksun5,
    required this.seS1fAccTime,
    required this.seG3fAccTime,
    required this.seG1fAccTime,
    required this.se_3cAccTime,
    required this.se_4cAccTime,
    required this.sjS1fOrd,
    required this.sjG3fOrd,
    required this.sjG1fOrd,
    required this.sj_3cOrd,
    required this.sj_4cOrd,
  });

  factory KraRaceItem.fromJson(Map<String, dynamic> json) {
    return KraRaceItem(
      hrNo: json['hrNo']?.toString() ?? '',
      hrName: json['hrName']?.toString() ?? '',
      hrNameEn: json['hrNameEn']?.toString() ?? '',
      age: int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      sex: json['sex']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      jkNo: json['jkNo']?.toString() ?? '',
      jkName: json['jkName']?.toString() ?? '',
      jkNameEn: json['jkNameEn']?.toString() ?? '',
      trNo: json['trNo']?.toString() ?? '',
      trName: json['trName']?.toString() ?? '',
      trNameEn: json['trNameEn']?.toString() ?? '',
      owNo: json['owNo']?.toString() ?? '',
      owName: json['owName']?.toString() ?? '',
      owNameEn: json['owNameEn']?.toString() ?? '',
      meet: json['meet']?.toString() ?? '',
      rcDate: json['rcDate']?.toString() ?? '',
      rcDay: json['rcDay']?.toString() ?? '',
      rcNo: int.tryParse(json['rcNo']?.toString() ?? '0') ?? 0,
      rcDist: int.tryParse(json['rcDist']?.toString() ?? '0') ?? 0,
      rcName: json['rcName']?.toString() ?? '',
      ord: int.tryParse(json['ord']?.toString() ?? '0') ?? 0,
      chulNo: int.tryParse(json['chulNo']?.toString() ?? '0') ?? 0,
      rcTime: double.tryParse(json['rcTime']?.toString() ?? '0') ?? 0.0,
      wgHr: json['wgHr']?.toString() ?? '',
      wgBudam: double.tryParse(json['wgBudam']?.toString() ?? '0') ?? 0.0,
      diffUnit: json['diffUnit']?.toString() ?? '',
      winOdds: double.tryParse(json['winOdds']?.toString() ?? '0') ?? 0.0,
      plcOdds: double.tryParse(json['plcOdds']?.toString() ?? '0') ?? 0.0,
      budam: json['budam']?.toString() ?? '',
      prizeCond: json['prizeCond']?.toString() ?? '',
      rank: json['rank']?.toString() ?? '',
      ageCond: json['ageCond']?.toString() ?? '',
      sexCond: json['sexCond']?.toString() ?? '',
      weather: json['weather']?.toString() ?? '',
      track: json['track']?.toString() ?? '',
      chaksun1: int.tryParse(json['chaksun1']?.toString() ?? '0') ?? 0,
      chaksun2: int.tryParse(json['chaksun2']?.toString() ?? '0') ?? 0,
      chaksun3: int.tryParse(json['chaksun3']?.toString() ?? '0') ?? 0,
      chaksun4: int.tryParse(json['chaksun4']?.toString() ?? '0') ?? 0,
      chaksun5: int.tryParse(json['chaksun5']?.toString() ?? '0') ?? 0,
      seS1fAccTime: double.tryParse(json['seS1fAccTime']?.toString() ?? '0') ?? 0.0,
      seG3fAccTime: double.tryParse(json['seG3fAccTime']?.toString() ?? '0') ?? 0.0,
      seG1fAccTime: double.tryParse(json['seG1fAccTime']?.toString() ?? '0') ?? 0.0,
      se_3cAccTime: double.tryParse(json['se_3cAccTime']?.toString() ?? '0') ?? 0.0,
      se_4cAccTime: double.tryParse(json['se_4cAccTime']?.toString() ?? '0') ?? 0.0,
      sjS1fOrd: int.tryParse(json['sjS1fOrd']?.toString() ?? '0') ?? 0,
      sjG3fOrd: int.tryParse(json['sjG3fOrd']?.toString() ?? '0') ?? 0,
      sjG1fOrd: int.tryParse(json['sjG1fOrd']?.toString() ?? '0') ?? 0,
      sj_3cOrd: int.tryParse(json['sj_3cOrd']?.toString() ?? '0') ?? 0,
      sj_4cOrd: int.tryParse(json['sj_4cOrd']?.toString() ?? '0') ?? 0,
    );
  }
}
