/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "GTLRDiscovery.h"

typedef NS_ENUM(NSUInteger, SGGeneratorHandlerMessageType) {
  kSGGeneratorHandlerMessageError = 1,
  kSGGeneratorHandlerMessageWarning,
  kSGGeneratorHandlerMessageInfo
};

typedef void (^SGGeneratorMessageHandler)(SGGeneratorHandlerMessageType msgType,
                                          NSString *message);

typedef NS_OPTIONS(NSUInteger, SGGeneratorOptions) {
  kSGGeneratorOptionAuditJSON               = 1 << 0,
  kSGGeneratorOptionAllowRootOverride       = 1 << 1,
  kSGGeneratorOptionAllowGuessFormattedName = 1 << 2,
  kSGGeneratorOptionLegacyObjectNaming      = 1 << 3,
};

typedef enum {
  kGenerateInterface = 1,
  kGenerateImplementation
} GeneratorMode;

@interface SGGenerator : NSObject

@property(readonly) GTLRDiscovery_RestDescription* api;
@property(readonly) SGGeneratorOptions options;
@property(readonly) NSUInteger verboseLevel;
@property(readonly) NSString *frameworkName;

// The API name formatted for use as a directory name.
@property (readonly) NSString *formattedAPIName;

+ (instancetype)generatorForApi:(GTLRDiscovery_RestDescription *)api
                        options:(SGGeneratorOptions)options
                   verboseLevel:(NSUInteger)verboseLevel
          formattedNameOverride:(NSString *)formattedNameOverride
               useFrameworkName:(NSString *)frameworkName;

// Keys are the file names; values are the contents of the files.
- (NSDictionary *)generateFilesWithHandler:(SGGeneratorMessageHandler)messageHandler;

- (NSString *)generateObjectClassForSchema:(GTLRDiscovery_JsonSchema *)schema
                     forMode:(GeneratorMode)mode;                     

@end
////////////////////////////////////////////////////////////
// moved to .h to access from swift

@interface GTLRDiscovery_RestDescription (SGGeneratorAdditions)
@property(readonly) NSArray *sg_allMethods;
@property(readonly) NSDictionary *sg_queryEnumsMap;
@property(readonly) NSDictionary *sg_objectEnumsMap;
@property(readonly) NSArray *sg_allSchemas;
@property(readonly) NSArray *sg_topLevelObjectSchemas;
@property(readonly) NSArray *sg_allMethodObjectParameters;
@property(readonly) NSArray *sg_allMethodObjectParameterReferences;
@property(readonly) NSString *sg_resumableUploadPath;
@property(readonly) NSString *sg_simpleUploadPath;

- (NSString *)sg_cleanedRootURLString;
- (void)sg_calculateMediaPaths;
@end

@interface GTLRDiscovery_JsonSchema (SGGeneratorAdditions)
@property(readonly) NSString *sg_name;
@property(readonly) NSString *sg_objcName;
@property(readonly) NSString *sg_objcNameType;
@property(readonly) NSString *sg_capObjCName;
@property(readonly) NSString *sg_forceNameComment;
@property(readonly) GTLRDiscovery_RestMethod *sg_method;
@property(readonly, getter=sg_isParameter) BOOL sg_parameter;
@property(readonly) GTLRDiscovery_JsonSchema *sg_parentSchema;
@property(readonly) NSString *sg_fullSchemaName;
@property(readonly) NSString *sg_objcClassName;
@property(readonly) NSArray *sg_childObjectSchemas;
@property(readonly) GTLRDiscovery_JsonSchema *sg_resolvedSchema;
@property(readonly) NSString *sg_kindToRegister;
@property(readonly) BOOL sg_isLikelyInvalidUseOfKind;
@property(readonly) NSString *sg_formattedRange;
@property(readonly) NSString *sg_formattedDefault;
@property(readonly) NSString *sg_rangeAndDefaultDescription;

- (NSString *)sg_collectionItemsKey:(BOOL *)outSupportsPagination;

- (GTLRDiscovery_JsonSchema *)sg_itemsSchemaResolving:(BOOL)resolving
                                                depth:(NSInteger *)depth;

- (NSString *)sg_constantNamed:(NSString *)name;

- (void)sg_getObjectParamObjCType:(NSString **)objcType
                        asPointer:(BOOL *)asPointer
            objcPropertySemantics:(NSString **)objcPropertySemantics
                          comment:(NSString **)comment;

- (void)sg_getQueryParamObjCType:(NSString **)objcType
                       asPointer:(BOOL *)asPointer
           objcPropertySemantics:(NSString **)objcPropertySemantics
                         comment:(NSString **)comment
                  itemsClassName:(NSString **)itemsClassName;

- (NSArray *)sg_fullSchemaPath:(BOOL)formatted
                foldArrayItems:(BOOL)foldArrayItems;

@end

@interface GTLRDiscovery_RestResource (SGGeneratorAdditions)
@property(readonly) NSString *sg_name;
@end

@interface GTLRDiscovery_RestMethod (SGGeneratorAdditions)
@property(readonly) NSString *sg_name;
@property(readonly) NSArray *sg_sortedParameters;
@property(readonly) NSArray *sg_sortedParametersWithRequest;
@property(readonly) NSString *sg_resumableUploadPathOverride;
@property(readonly) NSString *sg_simpleUploadPathOverride;
@end

@interface GTLRDiscovery_RestMethodRequest (SGGeneratorAdditions)
@property(readonly) GTLRDiscovery_JsonSchema *sg_resolvedSchema;
@end

@interface GTLRDiscovery_RestMethodResponse (SGGeneratorAdditions)
@property(readonly) GTLRDiscovery_JsonSchema *sg_resolvedSchema;
@end

@interface SGGenerator ()
@property(strong) NSMutableArray *warnings;
@property(strong) NSMutableArray *infos;
@end
// This is added so it can be called on Methods, Parameters, and Schema.
@interface GTLRObject (SGGeneratorAdditions)
@property(readonly) NSString *sg_errorReportingName;
@property(readonly) SGGenerator *sg_generator;

- (void)sg_setProperty:(id)obj forKey:(NSString *)key;
- (id)sg_propertyForKey:(NSString *)key;
@end


