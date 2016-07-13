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
    var type: String { return schema.type! }
    
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
            

            public func lookup(`type`:String, format:String?) -> String {
                let jsonType = JsonTypeMapping(rawValue: `type`)!
                let jsonFmt: JsonTypeMapping? = format != nil ? JsonTypeMapping(rawValue: format!): nil
                switch (jsonType, jsonFmt) {
                case (.any, .None):
                    return "Any"
                case (.array, .None):
                    return "Array"                           
                default:
                    fatalError()
                }
       }

       }

public extension SGGenerator {
    public func generateSwiftObjectForSchema(schema: GTLRDiscovery_JsonSchema,
                                             forMode: GeneratorMode ) -> String {
        let schemaClassName = schema.sg_objcClassName
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
                let propertyType = property.className
                let isArray = property.type == "array"
                body.append(indent(1) + "public let \(name):\(propertyType)")
                
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
        var paramFormat = resolvedSchema.format!
        
        if resolvedSchema.repeated != nil || paramType == "array" {
            // find type of items
            let depth = UnsafeMutablePointer<Int>(bitPattern: 1)
            if let itemsSchema = resolvedSchema.sg_itemsSchemaResolving(true, depth: depth) {
                paramType = itemsSchema.type!
                paramFormat = itemsSchema.format!
            } else {
                fatalError("array had no type") // maybe use Any?
            }
        }
        //let typeInfo = LookupTypeInfo(paramType, paramFormat, true)
        return (type: paramType, semantics:"", comment:"\(paramType) \(paramFormat)", itemsClassName: "")
    }

}

