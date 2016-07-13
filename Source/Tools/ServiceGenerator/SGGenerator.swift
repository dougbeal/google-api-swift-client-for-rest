//
//  SGGenerator.swift
//  ServiceGenerator
//
//  Created by Douglas Beal on 7/12/16.
//
//

import Foundation
public let indentString = "    "
func indent(level: Int = 0) -> String {
    var string = ""
    for _ in 0..<level {
        string = string + indentString
    }
    return string
}

struct SchemaSwiftWrapper: CustomStringConvertible {
    private let schema: GTLRDiscovery_JsonSchema
    //private var _type: SGTypeInfo? = nil
    // var type: SGTypeInfo {
    //     if _type == nil {
    //         _type = LookupTypeInfo(schema.type)
    //     }
    //     return _type!
    // }
    var type: String {
        return schema.sg_getObjectParamSwiftType().type
    }

    var className: String { return schema.sg_SwiftClassName() }

    var description: String {
        return "type \(schema.type), format \(schema.format)"
    }
    init( schema: GTLRDiscovery_JsonSchema ) {
        self.schema = schema
    }


}

public enum SwiftSchemaKeys: String {
    case ClassName = "schemaSwiftClassName"
}

public enum JsonTypeMapping: String {
    case any = "any"
    case array = "array"
    case object = "object"
    case string = "string"
    case boolean = "boolean"
    case integer = "integer"
    case number = "number"
    case float = "float"
    case double = "double"
    case int32 = "int32"
    case uint32 = "uint32"
    case int64 = "int64"
    case uint64 = "uint64"
    case byte = "byte"
    case date = "date"
    case date_time = "date-time"
    case google_datetime = "google-datetime"
    case google_duration = "google-duration"
    case google_fieldmask = "google-fieldmask"
    case use_item_class = "ITEMS_CLASS"

                      


}

public func jsonTypeToSwift( `type`:String, format:String?) -> String {
        let jsonType = JsonTypeMapping(rawValue: `type`)!
        let jsonFormat: JsonTypeMapping? = format != nil ? JsonTypeMapping(rawValue: format!): nil
        switch (jsonType, jsonFormat) {
        case (.any, .None):
            return "Any"
        case (.array, .None):
            return "Array"
        case (.boolean, .None):
            return "Bool"
        case (.object, .None):
            return JsonTypeMapping.use_item_class.rawValue
        case (.string, .None):
            return "String"
        case (.integer, .Some(.int32)):
            return "Int32"
        case (.integer, .Some(.uint32)):
            return "UInt32"
        case (.string, .Some(.int64)):
            return "Int64"
        case (.string, .Some(.uint64)):
            return "UInt64"
        case (.number, .Some(.double)):
            return "Double"
        case (.number, .Some(.float)):
            return "Float"
        case (.string, .Some(.date_time)):
            return "GTLRDateTime"
        case (.string, .Some(.byte)):
            return "GTLRBase64"                   
        default:
            fatalError("not implemented/found '\(jsonType)' '\(jsonFormat)'")
        }
    }                             
                             
public extension SGGenerator {
    public func generateSwiftObjectForSchema(schema: GTLRDiscovery_JsonSchema,
                                             forMode: GeneratorMode ) -> String {
        let schemaClassName = schema.sg_objcClassName
        var collectionSupportsPagination: ObjCBool = ObjCBool(false)

        let collectionsItemKey = schema.sg_collectionItemsKey(&collectionSupportsPagination)
        let isCollectionClass: Bool = collectionsItemKey != ""
        let locator = "\(#file):\(#function):\(#line):\(#column)"
        let decl = "public struct \(schemaClassName) { // \(locator)"
        let declOpen = indent(0) + decl
        let declClose = indent(0) + "} //" + decl

        var body = Array<String>()

        let additionalProperties = schema

        body.append(declOpen)

        if let properties = schema.properties?.additionalProperties() {
            for (name,schema) in properties.sort({ $0.0 < $1.0 }) {
                guard let schema = schema as? GTLRDiscovery_JsonSchema else { fatalError() }
                let property = SchemaSwiftWrapper(schema: schema.sg_resolvedSchema)
                let propertyType = property.type
                let propertyClass = property.className
                
                let isClass = property.type == JsonTypeMapping.use_item_class.rawValue
                let type = isClass ? propertyClass : propertyType

                body.append(indent(1) + "public let \(name):\(type)?")

            }
        }
        body.append(declClose)

        return body.joinWithSeparator("\n")
    }


}
/*
- (NSString *)sg_objcClassName {
  // Always use the resolved schema so we get real names.
  GTLRDiscovery_JsonSchema *resolvedSchema = self.sg_resolvedSchema;

  NSString *result = [resolvedSchema sg_propertyForKey:kSchemaObjCClassNameKey];
  if (result == nil) {
    NSArray *parts = [resolvedSchema sg_fullSchemaPath:YES foldArrayItems:YES];
    NSString *fullName = [parts componentsJoinedByString:@""];

    result = [NSString stringWithFormat:@"%@",
                       /*kProjectPrefix, self.sg_generator.formattedAPIName,*/ fullName];

    [resolvedSchema sg_setProperty:result forKey:kSchemaObjCClassNameKey];
  }
  return result;
}*/
public extension GTLRDiscovery_JsonSchema {
    public var resolvedSchema: GTLRDiscovery_JsonSchema {
        return self.sg_resolvedSchema
    }

    public func sg_SwiftClassName() -> String {
        if let result = resolvedSchema.sg_propertyForKey(SwiftSchemaKeys.ClassName.rawValue) as? String {
            return result
        } else {
            if let parts = resolvedSchema.sg_fullSchemaPath(true, foldArrayItems: true) as? Array<String> {
                let fullName = parts.joinWithSeparator("")
                let result = "\(fullName)"
                resolvedSchema.sg_setProperty(result, forKey: SwiftSchemaKeys.ClassName.rawValue)
                return result
            } else {
                fatalError()
            }
        }
    }

    public func sg_getObjectParamSwiftType()
        -> (`type`:String, semantics: String, comment: String, itemsClassName: String)
    {
        var paramType = resolvedSchema.type!
        var paramFormat = resolvedSchema.format
        var type = ""

        if resolvedSchema.repeated != nil || paramType == "array" {
            // find type of items
            var depth = Int(1)//UnsafeMutablePointer<Int>(bitPattern: 1)
            let array = jsonTypeToSwift(paramType, format: paramFormat)
            if let itemsSchema = resolvedSchema.sg_itemsSchemaResolving(true, depth: &depth) {
                paramType = itemsSchema.type!
                paramFormat = itemsSchema.format
                type = array + "<" + jsonTypeToSwift(paramType, format: paramFormat) + ">"
            } else {
                fatalError("array had no type") // maybe use Any?
            }
        } else {
            type = jsonTypeToSwift(paramType, format: paramFormat)
        }
        return (type: type, semantics:"", comment:"\(paramType) \(paramFormat)", itemsClassName: "")
    }

}
