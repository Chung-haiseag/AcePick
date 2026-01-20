#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AcePick Tipster Mock Data Generator
50명의 팁스터 정보 생성
"""

import json
import random
from datetime import datetime, timedelta
from pathlib import Path

# 팁스터 이름 풀
TIPSTER_NAMES = [
    "경마의신", "예측왕", "마권의달인", "경주마박사", "배당분석가",
    "경마전문가", "통계마스터", "데이터분석가", "경마칼럼니스트", "배당사냥꾼",
    "마권투자자", "경마전략가", "말 읽는 사람", "경마 멘토", "승률의신",
    "배당 마법사", "경마 컨설턴트", "데이터 예측자", "경마 분석기", "마권 전문가",
    "경마 통계학자", "배당 분석기", "경주마 전문가", "경마 리포터", "배당 계산기",
    "경마 코치", "마권 투자가", "경마 전략가", "배당 최적화자", "경마 과학자",
    "경주마 분석가", "배당 예측가", "경마 인플루언서", "마권 마스터", "경마 거장",
    "배당 트레이더", "경마 연구원", "마권 분석기", "경주마 박사", "경마 전문가",
    "배당 최고의 인", "경마 매직", "마권 왕", "경마 스타", "배당 신",
    "경주마 마스터", "경마 챔피언", "마권 프로", "경마 레전드", "배당 천재"
]

# 경주 ID 풀 (races.json에서 생성된 경주들)
def generate_race_ids():
    """경주 ID 생성"""
    race_ids = []
    start_date = datetime(2026, 1, 31)
    for i in range(15):  # 15일
        current_date = start_date + timedelta(days=i*7 if i < 8 else (i-7)*7 + 1)
        for race_num in range(1, 13):
            race_ids.append(f"R{current_date.strftime('%Y%m%d')}_{race_num:02d}")
    return race_ids


def generate_recent_picks(race_ids, count=20):
    """최근 예측 기록 생성"""
    picks = []
    selected_races = random.sample(race_ids, min(count, len(race_ids)))
    
    for idx, race_id in enumerate(selected_races):
        # 예측 순위와 실제 순위의 정확도를 어느 정도 연관시킴
        predicted_rank = random.randint(1, 12)
        
        # 정확도에 따라 실제 순위 결정 (일부는 맞춤, 일부는 틀림)
        if random.random() < 0.4:  # 40% 확률로 맞춤
            actual_rank = predicted_rank
        else:
            actual_rank = random.randint(1, 12)
        
        # 타임스탬프 (과거 20일부터 오늘까지)
        days_ago = 20 - idx
        timestamp = (datetime.now() - timedelta(days=days_ago)).isoformat()
        
        picks.append({
            "race_id": race_id,
            "predicted_rank": predicted_rank,
            "actual_rank": actual_rank,
            "timestamp": timestamp
        })
    
    return picks


def calculate_trust_index(accuracy, consistency, volume, transparency, brier_score):
    """Trust Index 점수 계산"""
    # 정규화된 점수 계산
    accuracy_score = accuracy * 30  # 30점
    consistency_score = consistency * 25  # 25점
    volume_score = min((volume / 500) * 20, 20)  # 20점 (500을 기준으로)
    transparency_score = transparency * 15  # 15점
    brier_penalty = max(0, 10 - (brier_score * 25))  # 10점 (Brier score 페널티)
    
    total_score = accuracy_score + consistency_score + volume_score + transparency_score + brier_penalty
    
    # 40~95 범위로 정규화
    normalized_score = 40 + (total_score / 100) * 55
    return round(min(max(normalized_score, 40), 95), 1)


def generate_tipster(tipster_id, race_ids):
    """개별 팁스터 정보 생성"""
    # 통계 생성
    total_predictions = random.randint(50, 500)
    wins = int(total_predictions * random.uniform(0.25, 0.55))
    places = int(total_predictions * random.uniform(0.3, 0.65))
    total_followers = random.randint(100, 50000)
    
    # Trust Index 컴포넌트
    accuracy = round(random.uniform(0.4, 0.9), 3)
    consistency = round(random.uniform(0.5, 0.95), 3)
    volume = random.randint(50, 500)
    transparency = round(random.uniform(0.7, 1.0), 3)
    brier_score = round(random.uniform(0.1, 0.4), 3)
    
    # Trust Index 점수 계산
    trust_score = calculate_trust_index(accuracy, consistency, volume, transparency, brier_score)
    
    # ROI 계산 (정확도와 일부 연관)
    roi = round(random.uniform(-15.0, 25.0), 2)
    if accuracy > 0.7:
        roi = round(random.uniform(0, 25.0), 2)
    elif accuracy < 0.5:
        roi = round(random.uniform(-15.0, 5.0), 2)
    
    return {
        "tipster_id": f"TIP_{tipster_id:05d}",
        "username": random.choice(TIPSTER_NAMES),
        "verified": random.random() < 0.2,  # 20% 확률로 verified
        "trust_index": {
            "score": trust_score,
            "components": {
                "accuracy": accuracy,
                "consistency": consistency,
                "volume": volume,
                "transparency": transparency
            },
            "brier_score": brier_score,
            "roi": roi
        },
        "stats": {
            "total_predictions": total_predictions,
            "wins": wins,
            "places": places,
            "total_followers": total_followers
        },
        "recent_picks": generate_recent_picks(race_ids),
        "created_at": datetime.now().isoformat()
    }


def generate_all_tipsters(count=50):
    """모든 팁스터 데이터 생성"""
    race_ids = generate_race_ids()
    tipsters = []
    
    print(f"🎯 {count}명의 팁스터 데이터 생성 중...")
    print()
    
    for i in range(count):
        tipster = generate_tipster(i + 1, race_ids)
        tipsters.append(tipster)
        
        if (i + 1) % 10 == 0:
            print(f"✓ {i + 1}명 완료")
    
    # Trust Index 점수로 정렬 (높은 순)
    tipsters.sort(key=lambda x: x['trust_index']['score'], reverse=True)
    
    print()
    print(f"✅ 총 {len(tipsters)}명의 팁스터 생성 완료!")
    print()
    
    return tipsters


def save_tipsters_to_json(tipsters):
    """팁스터 데이터를 JSON 파일로 저장"""
    output_dir = Path(__file__).parent.parent / "assets" / "mock_data"
    output_dir.mkdir(parents=True, exist_ok=True)
    
    output_file = output_dir / "tipsters.json"
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(tipsters, f, ensure_ascii=False, indent=2)
    
    return output_file


def main():
    """메인 함수"""
    print("=" * 80)
    print("🎯 AcePick Tipster Mock Data Generator")
    print("=" * 80)
    print()
    
    # 팁스터 데이터 생성
    tipsters = generate_all_tipsters(count=50)
    
    print("=" * 80)
    print("💾 JSON 파일 저장 중...")
    output_file = save_tipsters_to_json(tipsters)
    print(f"✓ 저장 완료: {output_file}")
    print()
    
    # 파일 정보 출력
    file_size = output_file.stat().st_size
    print(f"📊 파일 크기: {file_size:,} bytes ({file_size / 1024:.2f} KB)")
    print()
    
    # 상위 3명 팁스터 정보 출력
    print("=" * 80)
    print("🏆 상위 3명 팁스터 (Trust Index 기준)")
    print("=" * 80)
    print()
    
    for rank, tipster in enumerate(tipsters[:3], 1):
        print(f"🥇 #{rank} - {tipster['username']}" if rank == 1 else 
              f"🥈 #{rank} - {tipster['username']}" if rank == 2 else
              f"🥉 #{rank} - {tipster['username']}")
        print(f"  ID: {tipster['tipster_id']}")
        print(f"  검증됨: {'✓' if tipster['verified'] else '✗'}")
        print(f"  Trust Index: {tipster['trust_index']['score']}")
        print(f"    - Accuracy: {tipster['trust_index']['components']['accuracy']}")
        print(f"    - Consistency: {tipster['trust_index']['components']['consistency']}")
        print(f"    - Volume: {tipster['trust_index']['components']['volume']}")
        print(f"    - Transparency: {tipster['trust_index']['components']['transparency']}")
        print(f"    - Brier Score: {tipster['trust_index']['brier_score']}")
        print(f"    - ROI: {tipster['trust_index']['roi']}%")
        print(f"  통계:")
        print(f"    - 총 예측: {tipster['stats']['total_predictions']}")
        print(f"    - 우승: {tipster['stats']['wins']}")
        print(f"    - 입상: {tipster['stats']['places']}")
        print(f"    - 팔로워: {tipster['stats']['total_followers']:,}명")
        print(f"  최근 예측: {len(tipster['recent_picks'])}개")
        print()
    
    print("=" * 80)
    print("✨ 팁스터 데이터 생성 완료!")
    print("=" * 80)


if __name__ == "__main__":
    main()
