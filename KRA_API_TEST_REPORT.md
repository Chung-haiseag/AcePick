# KRA API 테스트 결과 보고서

**날짜**: 2026년 1월 20일  
**테스트 대상**: 한국마사회 공공데이터 API (경주결과 조회)  
**API 버전**: API4_3

---

## ✅ 테스트 결과: 성공

### 📊 테스트 개요

**테스트 파라미터:**
- **경마장**: 서울 (meet=1)
- **경주일자**: 2022년 2월 20일 (rc_date=20220220)
- **경주번호**: 1경주 (rc_no=1)
- **페이지 크기**: 10개 (numOfRows=10)
- **페이지 번호**: 1 (pageNo=1)

**API 엔드포인트:**
```
https://apis.data.go.kr/B551015/API4_3/raceResult_3
```

**서비스 키:**
```
725f86c2e72ae4a10847e854827113c9959f61084843ef23d20934173f8418af
```

---

## 🔍 API 응답 분석

### 1. HTTP 응답

| 항목 | 값 |
|------|-----|
| **Status Code** | 200 OK |
| **Content-Type** | application/xml;charset=UTF-8 (기본) |
| **Content-Type (JSON)** | application/json (\_type=json 파라미터 사용 시) |
| **Transfer-Encoding** | chunked |

**중요 발견:**
- 기본 응답 형식은 **XML**
- **JSON 응답**을 받으려면 URL에 `&_type=json` 파라미터 추가 필요

### 2. API 응답 구조

**Header:**
```json
{
  "resultCode": "00",
  "resultMsg": "NORMAL SERVICE."
}
```

**Body:**
```json
{
  "items": {
    "item": [
      { /* 경주 결과 데이터 */ }
    ]
  },
  "numOfRows": 10,
  "pageNo": 1,
  "totalCount": 14
}
```

### 3. 실제 데이터 샘플

**첫 번째 경주 결과 (1위):**

| 필드 | 값 |
|------|-----|
| **마명** | 은혜 (EUNHYE) |
| **마번** | 0044233 |
| **기수** | 안토니오 (Antonio) |
| **기수번호** | 080478 |
| **조교사** | 김영관 (Kim Young Kwan) |
| **순위** | 1위 |
| **경주기록** | 75.9초 |
| **단승배당률** | 4.6배 |
| **복승배당률** | 1.8배 |
| **부담중량** | 56kg |
| **마체중** | 457kg (+2) |
| **착차** | 대 |
| **출주번호** | 9 |
| **경주거리** | 1200m |
| **경주조건** | 별정A, 국6등급, 3세, 오픈 |
| **날씨** | 맑음 |
| **주로** | 건조 (2%) |
| **상금** | 1착: 22,000,000원 |

**구간 기록 (서울):**
- S1F (200m): 14.1초 (1위)
- G3F (600m): 36.8초 (1위)
- G1F (1000m): 62.0초 (1위)
- 3코너: 24.8초 (1위)
- 4코너: 43.1초 (1위)

### 4. 전체 데이터 통계

| 항목 | 값 |
|------|-----|
| **총 출주 마수** | 14마리 |
| **반환된 데이터** | 10개 (첫 페이지) |
| **페이지 번호** | 1 |
| **총 페이지** | 2 (14 / 10 = 1.4) |

---

## 📋 응답 필드 분석

### 기본 정보 (6개)
- `hrNo`: 마번
- `hrName`: 마명 (한글)
- `hrNameEn`: 마명 (영문)
- `age`: 연령
- `sex`: 성별
- `name`: 국적

### 기수/조교사/마주 정보 (9개)
- `jkNo`, `jkName`, `jkNameEn`: 기수 정보
- `trNo`, `trName`, `trNameEn`: 조교사 정보
- `owNo`, `owName`, `owNameEn`: 마주 정보

### 경주 정보 (6개)
- `meet`: 경마장 (서울/제주/부산경남)
- `rcDate`: 경주일자
- `rcDay`: 경주요일
- `rcNo`: 경주번호
- `rcDist`: 경주거리
- `rcName`: 경주명

### 경주 결과 (8개)
- `ord`: 순위
- `chulNo`: 출주번호
- `rcTime`: 경주기록
- `wgHr`: 마체중
- `wgBudam`: 부담중량
- `diffUnit`: 착차
- `winOdds`: 단승식배당률
- `plcOdds`: 복승식배당률

### 경주 조건 (7개)
- `budam`: 부담구분
- `prizeCond`: 경주조건
- `rank`: 등급조건
- `ageCond`: 연령조건
- `sexCond`: 성별조건
- `weather`: 날씨
- `track`: 주로

### 상금 (5개)
- `chaksun1` ~ `chaksun5`: 1~5착 상금

### 구간 기록 - 서울 (5개)
- `seS1fAccTime`: S1F 통과누적기록
- `seG3fAccTime`: G3F 통과누적기록
- `seG1fAccTime`: G1F 통과누적기록
- `se_3cAccTime`: 3코너 통과누적기록
- `se_4cAccTime`: 4코너 통과누적기록

### 구간 순위 - 서울/제주 (5개)
- `sjS1fOrd`: S1F 구간순위
- `sjG3fOrd`: G3F 구간순위
- `sjG1fOrd`: G1F 구간순위
- `sj_3cOrd`: 3코너 순위
- `sj_4cOrd`: 4코너 순위

### 구간 기록 - 부산 (13개)
- `buS1fAccTime`, `buG8fAccTime`, `buG6fAccTime`, `buG4fAccTime`, `buG3fAccTime`, `buG2fAccTime`, `buG1fAccTime`
- `bu_10_8fTime`, `bu_8_6fTime`, `bu_6_4fTime`, `bu_4_2fTime`, `bu_2fGTime`, `bu_1fGTime`

### 구간 순위 - 부산 (7개)
- `buS1fOrd`, `buG8fOrd`, `buG6fOrd`, `buG4fOrd`, `buG3fOrd`, `buG2fOrd`, `buG1fOrd`

### 제주 구간 기록 (7개)
- `jeS1fTime`, `jeG3fTime`, `jeG1fTime`
- `je_1cTime`, `je_2cTime`, `je_3cTime`, `je_4cTime`

### 기타 (4개)
- `ilsu`: 일수
- `rating`: 레이팅
- `buga1`, `buga2`, `buga3`: 부가 정보

**총 필드 수: 약 70개**

---

## ✅ 검증 결과

### 1. API 연결 성공 ✅
- HTTP Status: 200 OK
- 응답 시간: 정상

### 2. 인증 성공 ✅
- resultCode: "00"
- resultMsg: "NORMAL SERVICE."

### 3. 데이터 반환 성공 ✅
- 총 14개 경주 결과 데이터
- 모든 필드 정상 파싱

### 4. JSON 형식 지원 ✅
- `_type=json` 파라미터로 JSON 응답 수신
- 모델 클래스와 구조 일치

---

## 🔧 KraApiConfig 수정 필요 사항

**현재 buildUrl() 메서드에 `_type=json` 추가 필요:**

```dart
static String buildUrl({
  required String endpoint,
  required Map<String, String> params,
}) {
  final uri = Uri.parse('$BASE_URL$endpoint');
  final queryParams = {
    'ServiceKey': SERVICE_KEY,
    '_type': 'json',  // ← 추가 필요
    ...params,
  };
  return uri.replace(queryParameters: queryParams).toString();
}
```

---

## 📊 데이터 품질 분석

### ✅ 장점:
1. **완전한 데이터**: 모든 필드가 제공됨
2. **정확한 구간 기록**: 200m, 600m, 1000m 구간 기록 제공
3. **상세한 메타데이터**: 날씨, 주로 상태, 경주 조건 등
4. **다국어 지원**: 한글/영문 병기

### ⚠️ 주의사항:
1. **경마장별 필드 차이**: 서울/제주/부산 구간 기록 필드가 다름
2. **Null 값 처리**: 일부 필드는 0 또는 빈 문자열
3. **단일/다중 아이템**: `items['item']`이 단일 객체 또는 배열일 수 있음

---

## 🚀 다음 단계

### 1. KraApiConfig 수정
- `buildUrl()`에 `_type: 'json'` 추가

### 2. 실제 앱 통합
- `KraApiService` 사용하여 데이터 조회
- Repository 패턴으로 도메인 모델 변환

### 3. 에러 처리 강화
- 네트워크 오류 처리
- 재시도 로직
- 캐싱 전략

### 4. 테스트 작성
- 단위 테스트
- 통합 테스트
- Mock 데이터 생성

---

## 📝 결론

**KRA API 연동 테스트 성공!** ✅

- API 키 정상 작동
- 실제 경주 데이터 수신 확인
- JSON 형식 지원 확인
- 모델 클래스와 응답 구조 일치

**다음 작업:**
1. `KraApiConfig`에 `_type=json` 파라미터 추가
2. `pubspec.yaml`에 `http`, `flutter_dotenv` 패키지 추가
3. 실제 앱에서 API 호출 테스트

---

**테스트 실행 명령어:**
```bash
cd ~/Documents/AcePick
dart run scripts/test_kra_real_api.dart
```

**테스트 날짜**: 2026년 1월 20일  
**테스트 상태**: ✅ 성공  
**API 상태**: 정상 작동
