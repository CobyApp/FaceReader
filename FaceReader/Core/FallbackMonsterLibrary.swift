//
//  FallbackMonsterLibrary.swift
//  FaceReader
//

import Foundation

/// LLM(Apple Intelligence) 미지원 / 호출 실패 / 빈 응답 시 사용할 미리 준비된 빌런 후보들.
/// 등급(0~4) × 언어(ko/ja/en) 별로 ~10개씩 수기 작성. `pick` 이 등급에 맞는 풀에서 랜덤 선택.
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
        .ko: korean,
        .ja: japanese,
        .en: english,
    ]

    // MARK: - Korean (50)

    private static let korean: [Int: [Entry]] = [
        0: [
            Entry(codename: "야근전사", description: "퇴근 시간만 되면 흔적도 없이 사라진다."),
            Entry(codename: "우울메기", description: "젖은 한숨으로 동네 분위기를 가라앉힌다."),
            Entry(codename: "새벽모기", description: "잠들려는 사람만 끈질기게 쫓아다닌다."),
            Entry(codename: "잔반파괴자", description: "냉장고 속 평화를 단숨에 깨버린다."),
            Entry(codename: "코고는늑대", description: "한 번 짖을 때마다 옆집까지 깨어난다."),
            Entry(codename: "와이파이도둑", description: "카페 회선을 통째로 흡수한다."),
            Entry(codename: "회의민폐자", description: "회의실에 들어가면 시간이 두 배로 늘어난다."),
            Entry(codename: "깜빡공주", description: "약속 5분 전마다 기억을 잃어버린다."),
            Entry(codename: "졸음전염병", description: "사무실 절반을 동시에 졸게 만든다."),
            Entry(codename: "변비대왕", description: "마주친 사람의 하루 일정을 망친다."),
        ],
        1: [
            Entry(codename: "광기두꺼비", description: "한 번 울 때마다 동네 신호등이 점멸한다."),
            Entry(codename: "절망꼬마", description: "출몰지의 영웅들이 줄줄이 연차를 끊는다."),
            Entry(codename: "폭풍입맛", description: "마트가 통째로 텅 비곤 한다."),
            Entry(codename: "분노출근러", description: "월요일 아침마다 지하철을 마비시킨다."),
            Entry(codename: "광기카페인", description: "도시 전역 카페가 갑자기 문을 닫는다."),
            Entry(codename: "무한적금귀", description: "은행 ATM이 일주일째 멈춰 있다."),
            Entry(codename: "데드라인사신", description: "마감 직전마다 인터넷이 끊긴다."),
            Entry(codename: "폐기물도깨비", description: "출몰 후엔 분리수거가 절대 끝나지 않는다."),
            Entry(codename: "새벽편의점광", description: "야간 직원이 줄지어 사직서를 낸다."),
            Entry(codename: "환승길잃은자", description: "환승역마다 출구가 사라진다."),
        ],
        2: [
            Entry(codename: "어둠싸이코", description: "정체불명의 외형에 신고가 폭주한다."),
            Entry(codename: "악몽편의점", description: "새벽에 마주치면 그 주 내내 잠을 못 잔다."),
            Entry(codename: "좀비행정관", description: "결재 서류로 도시 전체를 마비시킨다."),
            Entry(codename: "절망배달부", description: "주문한 적 없는 우편을 매일 꽂아 둔다."),
            Entry(codename: "결재불능자", description: "어떤 카드도 그 앞에선 인식되지 않는다."),
            Entry(codename: "무한로딩령", description: "모든 앱이 영원히 돌아가게 만든다."),
            Entry(codename: "회식망령", description: "회식 자리에 매번 나타나 술값을 두 배로 늘린다."),
            Entry(codename: "부동산악령", description: "매물 가격이 그 앞에서 두 배로 뛴다."),
            Entry(codename: "의욕흡혈귀", description: "마주친 직원들이 그 날로 사표를 낸다."),
            Entry(codename: "반품도깨비", description: "받자마자 반품 박스로 돌아간다."),
        ],
        3: [
            Entry(codename: "심연안구", description: "응시당한 자는 일주일치 결근을 한다."),
            Entry(codename: "재앙발톱", description: "지나간 자리엔 항상 새 공사판이 생긴다."),
            Entry(codename: "폭주기관차머리", description: "도심을 가로질러 끝장을 보고 떠난다."),
            Entry(codename: "공포의식주", description: "전기·수도·통신을 한꺼번에 끊는다."),
            Entry(codename: "인플레이션거인", description: "등장하면 물가가 두 배로 뛴다."),
            Entry(codename: "멸망세금관", description: "통장 잔액이 알아서 사라진다."),
            Entry(codename: "절단의왕", description: "인터넷 백본을 한 큐에 잘라낸다."),
            Entry(codename: "5G퇴화군주", description: "신호를 다이얼업 시대로 되돌린다."),
            Entry(codename: "침묵용", description: "모든 카톡 답장을 며칠씩 지연시킨다."),
            Entry(codename: "차원경계자", description: "출몰지의 GPS가 한꺼번에 망가진다."),
        ],
        4: [
            Entry(codename: "종말두상", description: "등록 자체가 인류의 마지막 행정 처리다."),
            Entry(codename: "초신성머리", description: "등장 즉시 엔딩 크레딧이 자동 재생된다."),
            Entry(codename: "궁극의공허", description: "맞서본 자가 단 한 명도 돌아오지 못했다."),
            Entry(codename: "신급강림체", description: "관측 자료조차 남기지 못한 절대 위협."),
            Entry(codename: "우주퇴근령", description: "전 직장인의 휴가를 동시에 무효화한다."),
            Entry(codename: "무한미지급", description: "월급일을 영원히 미룬다."),
            Entry(codename: "종말의알람", description: "도시 전체를 새벽 5시에 동시 기상시킨다."),
            Entry(codename: "회색종지부", description: "출몰 이후 어떤 색깔도 보이지 않는다."),
            Entry(codename: "영겁의야근", description: "시간이 멈춘 사무실로 모두를 끌어들인다."),
            Entry(codename: "부정합론자", description: "모든 약속과 계획이 동시에 깨진다."),
        ],
    ]

    // MARK: - Japanese (50)

    private static let japanese: [Int: [Entry]] = [
        0: [
            Entry(codename: "残業戦士", description: "退勤時間が来ると影も形もなくなる。"),
            Entry(codename: "鬱ナマズ", description: "湿ったため息で街の空気を沈ませる。"),
            Entry(codename: "夜中の蚊", description: "寝ようとする者だけを執拗に追う。"),
            Entry(codename: "残飯破壊者", description: "冷蔵庫の平和を一瞬で破る。"),
            Entry(codename: "イビキ狼", description: "一吠えで隣家まで起こす。"),
            Entry(codename: "WiFi泥棒", description: "カフェの回線を独占して吸い尽くす。"),
            Entry(codename: "会議邪魔者", description: "入室すると会議時間が二倍に伸びる。"),
            Entry(codename: "うっかり姫", description: "約束の5分前に必ず記憶を失う。"),
            Entry(codename: "眠気の伝染", description: "出現するとオフィスの半分が居眠り。"),
            Entry(codename: "便秘大王", description: "出会った者の一日を確実に狂わせる。"),
        ],
        1: [
            Entry(codename: "狂気ガエル", description: "鳴くたびに街の信号が点滅する。"),
            Entry(codename: "絶望チビ", description: "出没地ではヒーローが休暇申請する。"),
            Entry(codename: "暴風食欲", description: "スーパーが丸ごと消えることがある。"),
            Entry(codename: "怒り通勤者", description: "月曜の朝に地下鉄を麻痺させる。"),
            Entry(codename: "狂気カフェイン", description: "街中のカフェが一斉に閉まる。"),
            Entry(codename: "無限積立鬼", description: "銀行ATMが一週間停止する。"),
            Entry(codename: "締切死神", description: "締切直前に必ずネットが落ちる。"),
            Entry(codename: "ゴミ妖怪", description: "出現後は分別回収が終わらない。"),
            Entry(codename: "深夜コンビニ狂", description: "夜勤店員が連鎖辞職する。"),
            Entry(codename: "乗換迷子", description: "乗換駅の出口が消える。"),
        ],
        2: [
            Entry(codename: "闇サイコ", description: "正体不明の姿に通報が殺到する。"),
            Entry(codename: "悪夢コンビニ", description: "深夜に出会うと一週間眠れない。"),
            Entry(codename: "ゾンビ行政官", description: "決裁書類で都市を麻痺させる。"),
            Entry(codename: "絶望配達員", description: "頼んでもいない郵便を毎日差し込む。"),
            Entry(codename: "決済不能者", description: "どのカードもその前では通らない。"),
            Entry(codename: "無限ローディング霊", description: "全てのアプリが永遠に回り続ける。"),
            Entry(codename: "飲み会亡霊", description: "毎度現れて会計を倍にする。"),
            Entry(codename: "不動産悪霊", description: "物件価格を瞬時に倍にする。"),
            Entry(codename: "やる気吸血鬼", description: "出会った社員が即日辞表を書く。"),
            Entry(codename: "返品妖怪", description: "受け取った瞬間に返品箱へ消える。"),
        ],
        3: [
            Entry(codename: "深淵眼", description: "見つめられた者は一週間欠勤する。"),
            Entry(codename: "災禍の爪", description: "通った跡に必ず新工事が始まる。"),
            Entry(codename: "暴走機関車頭", description: "都心を貫いて去っていく。"),
            Entry(codename: "恐怖インフラ", description: "電気・水道・通信を一斉に落とす。"),
            Entry(codename: "インフレ巨人", description: "現れると物価が一気に倍になる。"),
            Entry(codename: "滅亡税官", description: "口座残高が勝手に消えていく。"),
            Entry(codename: "切断の王", description: "ネット回線を一刀両断する。"),
            Entry(codename: "5G退化君主", description: "通信をダイヤルアップに巻き戻す。"),
            Entry(codename: "沈黙の竜", description: "全LINEの返信を数日遅らせる。"),
            Entry(codename: "次元境界者", description: "出没地のGPSを総崩れにする。"),
        ],
        4: [
            Entry(codename: "終末頭", description: "登録自体が人類最後の行政処理。"),
            Entry(codename: "超新星頭", description: "現れた瞬間にエンディングが自動再生される。"),
            Entry(codename: "究極の虚無", description: "対峙した者は誰一人帰ってこなかった。"),
            Entry(codename: "神級降臨体", description: "観測記録すら残せない絶対脅威。"),
            Entry(codename: "宇宙退勤令", description: "全社会人の休暇を一斉に無効化する。"),
            Entry(codename: "無限未払い", description: "給料日を永遠に先送りする。"),
            Entry(codename: "終末アラーム", description: "街全体を朝5時に一斉起床させる。"),
            Entry(codename: "灰色終止符", description: "出現後はあらゆる色が消える。"),
            Entry(codename: "永劫残業", description: "時間停止のオフィスへ全員を引き込む。"),
            Entry(codename: "不整合論者", description: "全ての約束と計画が同時に崩れる。"),
        ],
    ]

    // MARK: - English (50)

    private static let english: [Int: [Entry]] = [
        0: [
            Entry(codename: "OvertimeWraith", description: "Vanishes the moment the clock strikes five."),
            Entry(codename: "SadCatfish", description: "Sighs damp enough to drag the whole block down."),
            Entry(codename: "MidnightMosquito", description: "Hunts only the desperately sleeping."),
            Entry(codename: "LeftoverWrecker", description: "Shatters the fridge's peace in seconds."),
            Entry(codename: "SnoringWolf", description: "One bark wakes the entire next block."),
            Entry(codename: "WiFiBandit", description: "Drains every café network on sight."),
            Entry(codename: "MeetingPest", description: "Doubles meeting length the second it enters."),
            Entry(codename: "ScatterPrincess", description: "Forgets every plan exactly five minutes before."),
            Entry(codename: "DrowsyPlague", description: "Puts half the office to sleep at once."),
            Entry(codename: "ConstipationKing", description: "Wrecks the day of anyone who spots it."),
        ],
        1: [
            Entry(codename: "MadToad", description: "Every croak flickers all the traffic lights."),
            Entry(codename: "DespairTot", description: "Heroes file vacation requests after each sighting."),
            Entry(codename: "StormAppetite", description: "Whole supermarkets simply disappear."),
            Entry(codename: "RushHourFury", description: "Paralyzes the subway every Monday morning."),
            Entry(codename: "ManiaCaffeine", description: "Closes every café in town at once."),
            Entry(codename: "EndlessSaver", description: "Freezes every ATM for a full week."),
            Entry(codename: "DeadlineReaper", description: "Cuts the internet right before every deadline."),
            Entry(codename: "TrashSpook", description: "Recycling never finishes after sightings."),
            Entry(codename: "LateNightOtaku", description: "Convenience store clerks quit in droves."),
            Entry(codename: "TransferLost", description: "Exits vanish from every transfer station."),
        ],
        2: [
            Entry(codename: "ShadowPsycho", description: "Reports overflow at its unknown silhouette."),
            Entry(codename: "NightmareKiosk", description: "Spotted at 3 AM, you won't sleep all week."),
            Entry(codename: "ZombieClerk", description: "Stamps the city into total paralysis."),
            Entry(codename: "DoomCourier", description: "Drops mail you never ordered every single day."),
            Entry(codename: "CardDecliner", description: "No card swipes work in its presence."),
            Entry(codename: "LoadingForever", description: "All apps spin endlessly when it appears."),
            Entry(codename: "HanggetSpirit", description: "Always shows up to double the bar tab."),
            Entry(codename: "RealtyShade", description: "Listings double in price on the spot."),
            Entry(codename: "MotivationVampire", description: "Sees an employee, drains a resignation letter."),
            Entry(codename: "ReturnGoblin", description: "Every delivery turns back into a return."),
        ],
        3: [
            Entry(codename: "AbyssEye", description: "One glance and you're out sick a full week."),
            Entry(codename: "RuinClaw", description: "Every footprint becomes a new construction site."),
            Entry(codename: "RogueLocomotive", description: "Charges through downtown and never looks back."),
            Entry(codename: "InfraTerror", description: "Cuts power, water, and signal all at once."),
            Entry(codename: "InflationTitan", description: "Prices double the moment it appears."),
            Entry(codename: "DoomTaxman", description: "Drains accounts on its own twisted schedule."),
            Entry(codename: "SeverKing", description: "Slices the entire internet backbone in one go."),
            Entry(codename: "DowngradeLord", description: "Reverts every 5G signal back to dial-up."),
            Entry(codename: "SilenceDragon", description: "Drags every reply out by several days."),
            Entry(codename: "DimensionDrifter", description: "Scrambles every GPS within reach."),
        ],
        4: [
            Entry(codename: "DoomCranium", description: "Filing it is humanity's last bureaucratic act."),
            Entry(codename: "SupernovaHead", description: "End credits roll automatically in its presence."),
            Entry(codename: "UltimateVoid", description: "No one who faced it has ever returned."),
            Entry(codename: "GodTierDescent", description: "An absolute threat with no observable trace."),
            Entry(codename: "CosmicOutClock", description: "Cancels every PTO request across the planet."),
            Entry(codename: "InfiniteUnpaid", description: "Postpones payday until the end of time."),
            Entry(codename: "DoomAlarm", description: "Wakes the entire city at 5 AM on the dot."),
            Entry(codename: "GrayPeriod", description: "No color has been seen since its arrival."),
            Entry(codename: "EternalOvertime", description: "Drags all souls into a time-frozen office."),
            Entry(codename: "DisharmonyPrime", description: "Every plan and promise breaks at the same instant."),
        ],
    ]
}
