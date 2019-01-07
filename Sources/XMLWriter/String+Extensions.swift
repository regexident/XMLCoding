import Foundation

extension String {
    func escaped(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
        var string = self
        for set in characterSet {
            string = string.replacingOccurrences(
                of: set.character,
                with: set.escapedCharacter,
                options: .literal
            )
        }
        return string
    }
}
