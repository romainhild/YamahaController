//
//  YamahaControllerXMLParser.swift
//  YamahaController
//
//  Created by Romain Hild on 11/08/2022.
//

import Foundation

class YamahaControllerXMLParser: NSObject, XMLParserDelegate {
    var name: String?
    var urlBase: URL?
    var controlPath: String?
    var model: String?
    var icons = [Icon]()

    var currentElement: String?
    var manufacturer: String?

    var iconUrl: String?
    var width: Int?
    var height: Int?
    var mimetype: String?
    var isInIcon = false
        
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "icon" {
            isInIcon = true
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = nil
        if elementName == "icon" {
            isInIcon = false
            if let width = width, let height = height, let mimetype = mimetype, let url = iconUrl {
                icons.append(Icon(width: width, height: height, mimetype: mimetype, path: url))
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
        case "manufacturer":
            manufacturer = string
        case "friendlyName":
            name = string
        case "modelName":
            model = string
        case "yamaha:X_URLBase":
            urlBase = URL(string: string)
        case "yamaha:X_yxcControlURL":
            controlPath = string
        case "url":
            if isInIcon {
                iconUrl = string
            }
        case "width":
            if isInIcon {
                width = Int(string)
            }
        case "height":
            if isInIcon {
                height = Int(string)
            }
        case "mimetype":
            if isInIcon {
                mimetype = string
            }
        default:
            return
        }
    }
}
