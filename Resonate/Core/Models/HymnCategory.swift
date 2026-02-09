import Foundation

enum HymnCategory: String, Codable, CaseIterable, Identifiable {

    case adoration_and_praise
    case opening_of_worship
    case morning_worship
    case sda_hymnal_evening_worship
    case second_advent
    case sabbath
    case hope_and_comfort
    case eternal_life
    case close_of_worship
    case sda_hymnal_trinity
    case love_of_god
    case majesty_and_power_of_god
    case power_of_god_in_nature
    case faithfulness_of_god
    case grace_and_mercy_of_god
    case first_advent
    case birth
    case life_and_ministry
    case sufferings_and_death
    case resurrection_and_ascension
    case priesthood
    case love_of_christ_for_us
    case sda_hymnal_kingdom_and_reign
    case glory_and_praise
    case sda_hymnal_holy_spirit
    case sda_hymnal_holy_scripture
    case invitation
    case repentance
    case forgiveness
    case consecration
    case baptism
    case salvation_and_redemption
    case community_in_christ
    case mission_of_the_church
    case dedication
    case ordination
    case sda_hymnal_child_dedication
    case communion
    case law_and_grace
    case spiritual_gifts
    case sda_hymnal_judgement
    case resurrection_of_the_saints
    case sda_hymnal_early_advent
    case our_love_for_god
    case joy_and_peace
    case meditation_and_prayer
    case faith_and_trust
    case guidance
    case thankfulness
    case humility
    case loving_service
    case obedience
    case love_for_one_another
    case watchfulness
    case christian_warfare
    case pilgrimage
    case stewardship
    case health_and_wholeness
    case love_of_country
    case love_in_the_home
    case marriage
    case call_to_worship
    
    
    case uncategorized

    var id: String { rawValue }

    var title: String {
        switch self {
        case .adoration_and_praise: return "Adoration and Praise"
        case .opening_of_worship: return "Opening of Worship"
        case .morning_worship: return "Morning Worship"
        case .sda_hymnal_evening_worship: return "Evening Worship"
        case .second_advent: return "Second Advent"
        case .sabbath: return "Sabbath"
        case .hope_and_comfort: return "Hope and Comfort"
        case .eternal_life: return "Eternal Life"
        case .close_of_worship: return "Close of Worship"
        case .sda_hymnal_trinity: return "Trinity"
        case .love_of_god: return "Love of God"
        case .majesty_and_power_of_god: return "Majesty and Power of God"
        case .power_of_god_in_nature: return "Power of God in Nature"
        case .faithfulness_of_god: return "Faithfulness of God"
        case .grace_and_mercy_of_god: return "Grace and Mercy of God"
        case .first_advent: return "First Advent"
        case .birth: return "Birth"
        case .life_and_ministry: return "Life and Ministry"
        case .sufferings_and_death: return "Sufferings and Death"
        case .resurrection_and_ascension: return "Resurrection and Ascension"
        case .priesthood: return "Priesthood"
        case .love_of_christ_for_us: return "Love of Christ for Us"
        case .sda_hymnal_kingdom_and_reign: return "Kingdom and Reign"
        case .glory_and_praise: return "Glory and Praise"
        case .sda_hymnal_holy_spirit: return "Holy Spirit"
        case .sda_hymnal_holy_scripture: return "Holy Scripture"
        case .invitation: return "Invitation"
        case .repentance: return "Repentance"
        case .forgiveness: return "Forgiveness"
        case .consecration: return "Consecration"
        case .baptism: return "Baptism"
        case .salvation_and_redemption: return "Salvation and Redemption"
        case .community_in_christ: return "Community in Christ"
        case .mission_of_the_church: return "Mission of the Church"
        case .dedication: return "Dedication"
        case .ordination: return "Ordination"
        case .sda_hymnal_child_dedication: return "Child Dedication"
        case .communion: return "Communion"
        case .law_and_grace: return "Law and Grace"
        case .spiritual_gifts: return "Spiritual Gifts"
        case .sda_hymnal_judgement: return "Judgement"
        case .resurrection_of_the_saints: return "Resurrection of the Saints"
        case .sda_hymnal_early_advent: return "Early Advent"
        case .our_love_for_god: return "Our Love for God"
        case .joy_and_peace: return "Joy and Peace"
        case .meditation_and_prayer: return "Meditation and Prayer"
        case .faith_and_trust: return "Faith and Trust"
        case .guidance: return "Guidance"
        case .thankfulness: return "Thankfulness"
        case .humility: return "Humility"
        case .loving_service: return "Loving Service"
        case .obedience: return "Obedience"
        case .love_for_one_another: return "Love for One Another"
        case .watchfulness: return "Watchfulness"
        case .christian_warfare: return "Christian Warfare"
        case .pilgrimage: return "Pilgrimage"
        case .stewardship: return "Stewardship"
        case .health_and_wholeness: return "Health and Wholeness"
        case .love_of_country: return "Love of Country"
        case .love_in_the_home: return "Love in the Home"
        case .marriage: return "Marriage"
        case .call_to_worship: return "Call to Worship"
        case .uncategorized: return "Uncategorized"
        }
    }
}
