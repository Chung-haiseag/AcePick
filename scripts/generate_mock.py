#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AcePick Mock Data Generator
2026년 1월 25일부터 8주간 주말 경주 데이터 생성
"""

import json
import random
from datetime import datetime, timedelta
from pathlib import Path

# 설정
START_DATE = datetime(2026, 1, 25)  # 2026년 1월 25일 (일요일)
WEEKS = 8
RACES_PER_DAY = 12
HORSES_PER_RACE = 12

# 기수 풀 (20명)
JOCKEYS = [
    "기수1", "기수2", "기수3", "기수4", "기수5",
    "기수6", "기수7", "기수8", "기수9", "기수10",
    "기수11", "기수12", "기수13", "기수14", "기수15",
    "기수16", "기수17", "기수18", "기수19", "기수20"
]

# 조교사 풀 (15명)
TRAINERS = [
    "조교사1", "조교사2", "조교사3", "조교사4", "조교사5",
    "조교사6", "조교사7", "조교사8", "조교사9", "조교사10",
    "조교사11", "조교사12", "조교사13", "조교사14", "조교사15"
]

# 말 이름 풀
HORSE_NAMES = [
    f"경주마{i}호" for i in range(1, 1001)
]

# 혈통 정보 풀
SIRES = ["명마1", "명마2", "명마3", "명마4", "명마5"]
DAMS = ["모마1", "모마2", "모마3", "모마4", "모마5"]


def generate_date_range():
    """2026년 1월 25일부터 8주간 주말(토, 일) 날짜 생성"""
    dates = []
    current_date = START_DATE
    
    # 8주 = 56일
    for _ in range(WEEKS):
        # 토요일 (weekday() = 5)
        saturday = current_date + timedelta(days=(5 - current_date.weekday()) % 7)
        if saturday >= START_DATE:
            dates.append(saturday)
        
        # 일요일 (weekday() = 6)
        sunday = saturday + timedelta(days=1)
        if sunday >= START_DATE and sunday < START_DATE + timedelta(days=56):
            dates.append(sunday)
        
        current_date = sunday + timedelta(days=1)
    
    return sorted(dates)


def generate_horse(horse_id, race_date, race_number, horse_number):
    """개별 말 정보 생성"""
    return {
        "horse_id": f"H2024_{horse_id:04d}",
        "horse_name": random.choice(HORSE_NAMES),
        "jockey": random.choice(JOCKEYS),
        "trainer": random.choice(TRAINERS),
        "gate": horse_number,  # 1~12
        "odds": round(random.uniform(1.8, 35.0), 2),
        "weight": random.randint(480, 540),
        "recent_form": [random.randint(1, 12) for _ in range(5)],
        "pedigree": {
            "sire": random.choice(SIRES),
            "dam": random.choice(DAMS),
            "sire_win_rate": round(random.uniform(0.1, 0.5), 3)
        },
        "sectional_times": {
            "first_600m": round(random.uniform(35.0, 40.0), 2),
            "second_600m": round(random.uniform(35.0, 40.0), 2),
            "last_600m": round(random.uniform(35.0, 42.0), 2),
            "acceleration_score": round(random.uniform(50, 100), 1)
        },
        "ai_prediction": {
            "rank": random.randint(1, 12),
            "confidence": round(random.uniform(0.5, 0.99), 3)
        }
    }


def generate_race(race_date, race_number):
    """개별 경주 정보 생성"""
    horses = []
    for horse_num in range(1, HORSES_PER_RACE + 1):
        horse_id = int(race_date.strftime("%Y%m%d")) * 10000 + race_number * 100 + horse_num
        horse = generate_horse(horse_id, race_date, race_number, horse_num)
        horses.append(horse)
    
    return {
        "race_id": f"R{race_date.strftime('%Y%m%d')}_{race_number:02d}",
        "race_date": race_date.strftime("%Y-%m-%d"),
        "race_number": race_number,
        "race_name": f"{race_date.strftime('%m월 %d일')} {race_number}경주",
        "race_time": f"{10 + race_number // 2:02d}:{(race_number % 2) * 30:02d}",
        "track": "서울경마장" if race_date.weekday() == 5 else "부산경마장",
        "distance": 1800,
        "horses": horses,
        "weather": random.choice(["맑음", "흐림", "약간의 비"]),
        "track_condition": random.choice(["양호", "보통", "불량"]),
        "created_at": datetime.now().isoformat()
    }


def generate_all_races():
    """모든 경주 데이터 생성"""
    dates = generate_date_range()
    all_races = []
    
    print(f"📅 생성 기간: {START_DATE.strftime('%Y년 %m월 %d일')} ~ {(START_DATE + timedelta(days=55)).strftime('%Y년 %m월 %d일')}")
    print(f"📊 주말 날짜 수: {len(dates)}일")
    print(f"🏇 하루당 경주 수: {RACES_PER_DAY}경주")
    print(f"🐴 경주당 말 수: {HORSES_PER_RACE}마리")
    print()
    
    for race_date in dates:
        print(f"📆 {race_date.strftime('%Y-%m-%d (%A)')} 경주 생성 중...", end=" ")
        for race_number in range(1, RACES_PER_DAY + 1):
            race = generate_race(race_date, race_number)
            all_races.append(race)
        print(f"✓ {RACES_PER_DAY}경주 완료")
    
    return all_races


def save_races_to_json(races):
    """경주 데이터를 JSON 파일로 저장"""
    output_dir = Path(__file__).parent.parent / "assets" / "mock_data"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_file = output_dir / "races.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(races, f, ensure_ascii=False, indent=2)
    
    return output_file


def main():
    """메인 함수"""
    print("=" * 60)
    print("🎯 AcePick Mock Data Generator")
    print("=" * 60)
    print()
    
    # 경주 데이터 생성
    print("🔄 경주 데이터 생성 중...")
    print()
    races = generate_all_races()
    
    print()
    print("=" * 60)
    print(f"✅ 총 {len(races)}개 경주 데이터 생성 완료!")
    print("=" * 60)
    print()
    
    # JSON 파일로 저장
    print("💾 JSON 파일 저장 중...")
    output_file = save_races_to_json(races)
    print(f"✓ 저장 완료: {output_file}")
    print()
    
    # 파일 정보 출력
    file_size = output_file.stat().st_size
    print(f"📊 파일 크기: {file_size:,} bytes ({file_size / 1024 / 1024:.2f} MB)")
    print()
    
    # 첫 번째 경주 정보 출력
    print("=" * 60)
    print("📋 첫 번째 경주 정보 (샘플)")
    print("=" * 60)
    first_race = races[0]
    print(f"경주 ID: {first_race['race_id']}")
    print(f"경주 날짜: {first_race['race_date']}")
    print(f"경주명: {first_race['race_name']}")
    print(f"경주 시간: {first_race['race_time']}")
    print(f"경마장: {first_race['track']}")
    print(f"거리: {first_race['distance']}m")
    print(f"날씨: {first_race['weather']}")
    print(f"마장 상태: {first_race['track_condition']}")
    print(f"출전 말 수: {len(first_race['horses'])}마리")
    print()
    
    # 첫 번째 말 정보 출력
    print("첫 번째 말 정보:")
    first_horse = first_race['horses'][0]
    print(f"  말 ID: {first_horse['horse_id']}")
    print(f"  말 이름: {first_horse['horse_name']}")
    print(f"  기수: {first_horse['jockey']}")
    print(f"  조교사: {first_horse['trainer']}")
    print(f"  게이트: {first_horse['gate']}")
    print(f"  배당: {first_horse['odds']}")
    print(f"  체중: {first_horse['weight']}kg")
    print(f"  최근 전적: {first_horse['recent_form']}")
    print(f"  혈통: {first_horse['pedigree']['sire']} x {first_horse['pedigree']['dam']}")
    print(f"  AI 예측 순위: {first_horse['ai_prediction']['rank']}위")
    print()


if __name__ == "__main__":
    main()
