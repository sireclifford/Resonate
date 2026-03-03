import Foundation

struct USFMBookMapper {
    
    // Static dictionary so it is not recreated on every function call
    private static let map: [String: String] = [
        
        "genesis": "GEN",
        "exodus": "EXO",
        "leviticus": "LEV",
        "numbers": "NUM",
        "deuteronomy": "DEU",
        
        "joshua": "JOS",
        "judges": "JDG",
        "ruth": "RUT",
        
        "1 samuel": "1SA",
        "2 samuel": "2SA",
        
        "1 kings": "1KI",
        "2 kings": "2KI",
        
        "1 chronicles": "1CH",
        "2 chronicles": "2CH",
        
        "ezra": "EZR",
        "nehemiah": "NEH",
        "esther": "EST",
        
        "job": "JOB",
        "psalm": "PSA",
        "psalms": "PSA",
        "proverbs": "PRO",
        "ecclesiastes": "ECC",
        "song of solomon": "SNG",
        "song of songs": "SNG",
        
        "isaiah": "ISA",
        "jeremiah": "JER",
        "lamentations": "LAM",
        "ezekiel": "EZK",
        "daniel": "DAN",
        
        "hosea": "HOS",
        "joel": "JOL",
        "amos": "AMO",
        "obadiah": "OBA",
        "jonah": "JON",
        "micah": "MIC",
        "nahum": "NAM",
        "habakkuk": "HAB",
        "zephaniah": "ZEP",
        "haggai": "HAG",
        "zechariah": "ZEC",
        "malachi": "MAL",
        
        
        "matthew": "MAT",
        "mark": "MRK",
        "luke": "LUK",
        "john": "JHN",
        
        "acts": "ACT",
        "romans": "ROM",
        
        "1 corinthians": "1CO",
        "2 corinthians": "2CO",
        
        "galatians": "GAL",
        "ephesians": "EPH",
        "philippians": "PHP",
        "colossians": "COL",
        
        "1 thessalonians": "1TH",
        "2 thessalonians": "2TH",
        
        "1 timothy": "1TI",
        "2 timothy": "2TI",
        
        "titus": "TIT",
        "philemon": "PHM",
        "hebrews": "HEB",
        "james": "JAS",
        
        "1 peter": "1PE",
        "2 peter": "2PE",
        
        "1 john": "1JN",
        "2 john": "2JN",
        "3 john": "3JN",
        
        "jude": "JUD",
        "revelation": "REV"
    ]
    
    static func usfmCode(for name: String) -> String? {
        
        let normalized = name
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        
        return map[normalized]
    }
    
    static func displayName(for usfm: String) -> String {
        
        let reverseMap: [String: String] = [
            "GEN": "Genesis",
            "EXO": "Exodus",
            "LEV": "Leviticus",
            "NUM": "Numbers",
            "DEU": "Deuteronomy",
            "JOS": "Joshua",
            "JDG": "Judges",
            "RUT": "Ruth",
            "1SA": "1 Samuel",
            "2SA": "2 Samuel",
            "1KI": "1 Kings",
            "2KI": "2 Kings",
            "1CH": "1 Chronicles",
            "2CH": "2 Chronicles",
            "EZR": "Ezra",
            "NEH": "Nehemiah",
            "EST": "Esther",
            "JOB": "Job",
            "PSA": "Psalms",
            "PRO": "Proverbs",
            "ECC": "Ecclesiastes",
            "SNG": "Song of Solomon",
            "ISA": "Isaiah",
            "JER": "Jeremiah",
            "LAM": "Lamentations",
            "EZK": "Ezekiel",
            "DAN": "Daniel",
            "HOS": "Hosea",
            "JOL": "Joel",
            "AMO": "Amos",
            "OBA": "Obadiah",
            "JON": "Jonah",
            "MIC": "Micah",
            "NAM": "Nahum",
            "HAB": "Habakkuk",
            "ZEP": "Zephaniah",
            "HAG": "Haggai",
            "ZEC": "Zechariah",
            "MAL": "Malachi",
            
            "MAT": "Matthew",
            "MRK": "Mark",
            "LUK": "Luke",
            "JHN": "John",
            "ACT": "Acts",
            "ROM": "Romans",
            
            "CO1": "1 Corinthians",
            "CO2": "2 Corinthians",
            "GAL": "Galatians",
            "EPH": "Ephesians",
            "PHP": "Philippians",
            "COL": "Colossians",
            
            "TH1": "1 Thessalonians",
            "TH2": "2 Thessalonians",
            "TIT": "Titus",
            "HEB": "Hebrews",
            "JAS": "James",
            
            "PE1": "1 Peter",
            "PE2": "2 Peter",
            
            "JN1": "1 John",
            "JN2": "2 John",
            "JN3": "3 John",
            
            "JUD": "Jude",
            "REV": "Revelation"
        ]
        
        return reverseMap[usfm] ?? usfm
    }
    
}


