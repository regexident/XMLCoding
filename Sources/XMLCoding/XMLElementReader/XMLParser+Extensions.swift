//
//  XMLParser+Extensions.swift
//  XMLCoding
//
//  Created by Vincent Esche on 1/4/19.
//  Copyright © 2019 Vincent Esche. All rights reserved.
//

import Foundation

extension XMLParser {
    static func parse(data: Data, delegate: XMLParserDelegate) throws {
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        
        if parser.parse() {
            return
        }
        
        let error = parser.parserError! as NSError
        
        let errorDescription = self.description(for: error)
        
        let string = String(data: data, encoding: .utf8) ?? ""
        let lines = string.split(separator: "\n")
        
        let row = parser.lineNumber - 1
        let column = parser.columnNumber - 1
        
        let line = (lines.isEmpty) ? "" : String(lines[row])
        let indentation = (lines.isEmpty) ? "" : String(repeating: " ", count: column)
        
        let help = indentation + "^ The error occured here."
        
        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: [],
            debugDescription: """
            Error at line \(parser.lineNumber), column \(parser.columnNumber): \
            \(errorDescription)
            
            \(line)
            \(help)
            """,
            underlyingError: error
        ))
    }
    
    static func description(for error: NSError) -> String {
        guard error.domain == XMLParser.errorDomain else {
            return error.localizedDescription
        }
        
        guard let errorCode = XMLParser.ErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }
        
        let descriptions: [XMLParser.ErrorCode: String] = [
            .internalError: "The parser object encountered an internal error.",
            .outOfMemoryError: "The parser object ran out of memory.",
            .documentStartError: "The parser object is unable to start parsing.",
            .emptyDocumentError: "The document is empty.",
            .prematureDocumentEndError: "The document ended unexpectedly.",
            .invalidHexCharacterRefError: "Invalid hexadecimal character reference encountered.",
            .invalidDecimalCharacterRefError: "Invalid decimal character reference encountered.",
            .invalidCharacterRefError: "Invalid character reference encountered.",
            .invalidCharacterError: "Invalid character encountered.",
            .characterRefAtEOFError: "Target of character reference cannot be found.",
            .characterRefInPrologError: "Invalid character found in the prolog.",
            .characterRefInEpilogError: "Invalid character found in the epilog.",
            .characterRefInDTDError: "Invalid character encountered in the DTD.",
            .entityRefAtEOFError: "Target of entity reference is not found.",
            .entityRefInPrologError: "Invalid entity reference found in the prolog.",
            .entityRefInEpilogError: "Invalid entity reference found in the epilog.",
            .entityRefInDTDError: "Invalid entity reference found in the DTD.",
            .parsedEntityRefAtEOFError: "Target of parsed entity reference is not found.",
            .parsedEntityRefInPrologError: "Target of parsed entity reference is not found in prolog.",
            .parsedEntityRefInEpilogError: "Target of parsed entity reference is not found in epilog.",
            .parsedEntityRefInInternalSubsetError: "Target of parsed entity reference is not found in internal subset.",
            .entityReferenceWithoutNameError: "Entity reference is without name.",
            .entityReferenceMissingSemiError: "Entity reference is missing semicolon.",
            .parsedEntityRefNoNameError: "Parsed entity reference is without an entity name.",
            .parsedEntityRefMissingSemiError: "Parsed entity reference is missing semicolon.",
            .undeclaredEntityError: "Entity is not declared.",
            .unparsedEntityError: "Cannot parse entity.",
            .entityIsExternalError: "Cannot parse external entity.",
            .entityIsParameterError: "Entity is a parameter.",
            .unknownEncodingError: "Document encoding is unknown.",
            .encodingNotSupportedError: "Document encoding is not supported.",
            .stringNotStartedError: "String is not started.",
            .stringNotClosedError: "String is not closed.",
            .namespaceDeclarationError: "Invalid namespace declaration encountered.",
            .entityNotStartedError: "Entity is not started.",
            .entityNotFinishedError: "Entity is not finished.",
            .lessThanSymbolInAttributeError: "Angle bracket is used in attribute.",
            .attributeNotStartedError: "Attribute is not started.",
            .attributeNotFinishedError: "Attribute is not finished.",
            .attributeHasNoValueError: "Attribute doesn’t contain a value.",
            .attributeRedefinedError: "Attribute is redefined.",
            .literalNotStartedError: "Literal is not started.",
            .literalNotFinishedError: "Literal is not finished.",
            .commentNotFinishedError: "Comment is not finished.",
            .processingInstructionNotStartedError: "Processing instruction is not started.",
            .processingInstructionNotFinishedError: "Processing instruction is not finished.",
            .notationNotStartedError: "Notation is not started.",
            .notationNotFinishedError: "Notation is not finished.",
            .attributeListNotStartedError: "Attribute list is not started.",
            .attributeListNotFinishedError: "Attribute list is not finished.",
            .mixedContentDeclNotStartedError: "Mixed content declaration is not started.",
            .mixedContentDeclNotFinishedError: "Mixed content declaration is not finished.",
            .elementContentDeclNotStartedError: "Element content declaration is not started.",
            .elementContentDeclNotFinishedError: "Element content declaration is not finished.",
            .xmlDeclNotStartedError: "XML declaration is not started.",
            .xmlDeclNotFinishedError: "XML declaration is not finished.",
            .conditionalSectionNotStartedError: "Conditional section is not started.",
            .conditionalSectionNotFinishedError: "Conditional section is not finished.",
            .externalSubsetNotFinishedError: "External subset is not finished.",
            .doctypeDeclNotFinishedError: "Document type declaration is not finished.",
            .misplacedCDATAEndStringError: "Misplaced CDATA end string.",
            .cdataNotFinishedError: "CDATA block is not finished.",
            .misplacedXMLDeclarationError: "Misplaced XML declaration.",
            .spaceRequiredError: "Space is required.",
            .separatorRequiredError: "Separator is required.",
            .nmtokenRequiredError: "Name token is required.",
            .nameRequiredError: "Name is required.",
            .pcdataRequiredError: "CDATA is required.",
            .uriRequiredError: "URI is required.",
            .publicIdentifierRequiredError: "Public identifier is required.",
            .ltRequiredError: "Left angle bracket is required.",
            .gtRequiredError: "Right angle bracket is required.",
            .ltSlashRequiredError: "Left angle bracket slash is required.",
            .equalExpectedError: "Equal sign expected.",
            .tagNameMismatchError: "Tag name mismatch.",
            .unfinishedTagError: "Unfinished tag found.",
            .standaloneValueError: "Standalone value found.",
            .invalidEncodingNameError: "Invalid encoding name found.",
            .commentContainsDoubleHyphenError: "Comment contains double hyphen.",
            .invalidEncodingError: "Invalid encoding.",
            .externalStandaloneEntityError: "External standalone entity.",
            .invalidConditionalSectionError: "Invalid conditional section.",
            .entityValueRequiredError: "Entity value is required.",
            .notWellBalancedError: "Document is not well balanced.",
            .extraContentError: "Error in content found.",
            .invalidCharacterInEntityError: "Invalid character in entity found.",
            .parsedEntityRefInInternalError: "Internal error in parsed entity reference found.",
            .entityRefLoopError: "Entity reference loop encountered.",
            .entityBoundaryError: "Entity boundary error.",
            .invalidURIError: "Invalid URI specified.",
            .uriFragmentError: "URI fragment.",
            .noDTDError: "Missing DTD.",
            .delegateAbortedParseError: "Delegate aborted parse.",
            ]
        
        guard let description = descriptions[errorCode] else {
            return "The parser object encountered an unknown error."
        }
        
        return description
    }
}
