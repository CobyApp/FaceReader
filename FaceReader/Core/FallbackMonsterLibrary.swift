//
//  FallbackMonsterLibrary.swift
//  FaceReader
//

import Foundation

/// LLM(Apple Intelligence) 미지원 / 호출 실패 시 사용할 미리 준비된 빌런 후보들.
/// 등급(0~4) 별로 3~4개씩, ko/ja/en 모두 수기 작성. 랜덤 선택.
public enum FallbackMonsterLibrary {
    public struct Entry: Sendable, Equatable {
        public let codename: String
        public let description: String
    }

    public static func pick(grade: Int, language: MonsterDescriber.DescriptionLanguage) -> Entry {
        let clamped = max(0, min(4, grade))
        let table = library[language] ?? [:]
        let pool = table[clamped] ?? []
        return pool.randomElement() ?? Entry(codename: "???", description: "")
    }

    private static let library: [MonsterDescriber.DescriptionLanguage: [Int: [Entry]]] = [
        .ko: [
            0: [
                Entry(codename: "야근전사", description: "퇴근 시간만 되면 흔적도 없이 사라진다."),
                Entry(codename: "우울메기", description: "젖은 한숨으로 동네 분위기를 가라앉힌다."),
                Entry(codename: "새벽모기", description: "잠들려는 사람만 끈질기게 쫓아다닌다."),
                Entry(codename: "잔반파괴자", description: "냉장고 안의 평화를 단숨에 깨버린다."),
            ],
            1: [
                Entry(codename: "광기두꺼비", description: "한 번 울 때마다 동네 신호등이 깜빡인다."),
                Entry(codename: "절망꼬마", description: "출몰지에선 영웅들이 연차를 끊는다."),
                Entry(codename: "폭풍입맛", description: "마트가 통째로 텅 비곤 한다."),
                Entry(codename: "분노출근러", description: "월요일 아침마다 지하철을 마비시킨다."),
            ],
            2: [
                Entry(codename: "어둠싸이코", description: "정체불명의 외형에 신고가 폭주한다."),
                Entry(codename: "악몽편의점", description: "새벽에 마주치면 그 주는 잠 다 잤다."),
                Entry(codename: "좀비행정관", description: "결재 서류로 도시를 마비시킨다."),
                Entry(codename: "절망배달부", description: "주문한 적도 없는 우편을 매일 꽂아 둔다."),
            ],
            3: [
                Entry(codename: "심연안구", description: "응시당한 자는 일주일치 결근을 한다."),
                Entry(codename: "재앙발톱", description: "지나간 자리엔 항상 새 공사판이 생긴다."),
                Entry(codename: "폭주기관차머리", description: "도심을 가로질러 끝장을 보고 떠난다."),
                Entry(codename: "공포의식주", description: "전기·수도·통신을 한꺼번에 꺼버린다."),
            ],
            4: [
                Entry(codename: "종말두상", description: "등록 자체가 인류의 마지막 행정 처리."),
                Entry(codename: "초신성머리", description: "등장하면 엔딩 크레딧이 알아서 재생된다."),
                Entry(codename: "궁극의공허", description: "맞서본 자가 단 한 명도 돌아오지 못했다."),
                Entry(codename: "신급강림체", description: "관측한 자료조차 남기지 못한 절대 위협."),
            ],
        ],
        .ja: [
            0: [
                Entry(codename: "残業戦士", description: "退勤時間になると影も形もなくなる。"),
                Entry(codename: "鬱ナマズ", description: "湿ったため息で街の空気を沈ませる。"),
                Entry(codename: "夜中の蚊", description: "寝ようとする者だけを執拗に追う。"),
                Entry(codename: "残飯破壊者", description: "冷蔵庫の平和を一瞬で破る。"),
            ],
            1: [
                Entry(codename: "狂気ガエル", description: "鳴くたびに街の信号が点滅する。"),
                Entry(codename: "絶望チビ", description: "出没地ではヒーローが休暇申請する。"),
                Entry(codename: "暴風食欲", description: "スーパーが丸ごと消えることがある。"),
                Entry(codename: "怒り通勤者", description: "月曜の朝に地下鉄を麻痺させる。"),
            ],
            2: [
                Entry(codename: "闇サイコ", description: "正体不明の姿に通報が殺到する。"),
                Entry(codename: "悪夢コンビニ", description: "深夜に出会うと一週間眠れない。"),
                Entry(codename: "ゾンビ行政官", description: "決裁書類で都市を麻痺させる。"),
                Entry(codename: "絶望配達員", description: "頼んでもいない郵便を毎日差し込む。"),
            ],
            3: [
                Entry(codename: "深淵眼", description: "見つめられた者は一週間欠勤する。"),
                Entry(codename: "災禍の爪", description: "通った跡には必ず新工事が始まる。"),
                Entry(codename: "暴走機関車頭", description: "都心を貫いて去っていく。"),
                Entry(codename: "恐怖インフラ", description: "電気・水道・通信を一斉に落とす。"),
            ],
            4: [
                Entry(codename: "終末頭", description: "登録自体が人類最後の行政処理。"),
                Entry(codename: "超新星頭", description: "現れた瞬間にエンディングが自動再生される。"),
                Entry(codename: "究極の虚無", description: "対峙した者は誰一人帰って来なかった。"),
                Entry(codename: "神級降臨体", description: "観測記録すら残せない絶対脅威。"),
            ],
        ],
        .en: [
            0: [
                Entry(codename: "OvertimeWraith", description: "Vanishes the moment the clock strikes five."),
                Entry(codename: "SadCatfish", description: "Sighs damp enough to drag the whole block down."),
                Entry(codename: "MidnightMosquito", description: "Hunts only the desperately sleeping."),
                Entry(codename: "LeftoverWrecker", description: "Shatters the fridge's peace in seconds."),
            ],
            1: [
                Entry(codename: "MadToad", description: "Every croak makes the traffic lights flicker."),
                Entry(codename: "DespairTot", description: "Heroes file vacation requests after sightings."),
                Entry(codename: "StormAppetite", description: "Whole supermarkets simply disappear."),
                Entry(codename: "RushHourFury", description: "Paralyzes the subway every Monday morning."),
            ],
            2: [
                Entry(codename: "ShadowPsycho", description: "Identity unknown, complaints overflow."),
                Entry(codename: "NightmareKiosk", description: "Spotted at 3 AM, you won't sleep all week."),
                Entry(codename: "ZombieClerk", description: "Stamps the city into total paralysis."),
                Entry(codename: "DoomCourier", description: "Drops mail you never ordered, every day."),
            ],
            3: [
                Entry(codename: "AbyssEye", description: "One glance and you're out sick a full week."),
                Entry(codename: "RuinClaw", description: "Every footprint turns into a new construction site."),
                Entry(codename: "RunawayLocomotiveHead", description: "Charges through downtown and never looks back."),
                Entry(codename: "InfraTerror", description: "Cuts power, water, and signal all at once."),
            ],
            4: [
                Entry(codename: "DoomCranium", description: "Filing it is humanity's last bureaucratic act."),
                Entry(codename: "SupernovaHead", description: "End credits roll automatically in its presence."),
                Entry(codename: "UltimateVoid", description: "No one who faced it has ever returned."),
                Entry(codename: "GodTierDescent", description: "An absolute threat that left no observable trace."),
            ],
        ],
    ]
}
