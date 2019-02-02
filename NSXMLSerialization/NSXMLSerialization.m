//
//  NSXMLSerialization.m
//  CinCer
//
//  Created by Kid Young on 3/14/17.
//  Copyright © 2017 Yang XiHong. All rights reserved.
//

#import "NSXMLSerialization.h"
#import <Foundation/NSDictionary.h>
#import <Foundation/NSArray.h>
#import <Foundation/NSString.h>
#import <Foundation/NSError.h>
#import <Foundation/NSXMLParser.h>
#import <Foundation/NSCharacterSet.h>
#import <Foundation/NSData.h>
#import <Foundation/NSKeyValueCoding.h>

NSString * const kNSXMLSerializationTextNodeKey = @"#text";
NSString * const kNSXMLSerializationAttributePrefix = @"@";

NSString * const kNSXMLSerializationCommentsKey = @"__comments";

@interface NSXMLSerialization () <NSXMLParserDelegate> {
}

@property (nonatomic, assign) BOOL wrapRootNode;
@property (nonatomic, assign) BOOL preserveComments;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id> *root;
@property (nonatomic, strong) NSMutableArray *stack;
@property (nonatomic, strong) NSMutableString *text;

@property (nonatomic, strong) NSError *error;

@end

@implementation NSXMLSerialization

#pragma mark - Initialization
/*
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
}
 */
#pragma mark - Public Methods

#pragma mark  Validation

+ (BOOL)isValidXMLObject:(id)obj
{
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:obj];
    BOOL isValid = [parser parse];
    return isValid;
}

#pragma mark  Serialization

+ (nullable NSData *)dataWithXMLObject:(id)obj options:(NSXMLWritingOptions)opt error:(NSError **)error
{
    NSString *xmlString = [self stringWithXMLObject:obj];
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

#pragma mark  Deserialization

+ (nullable id)XMLObjectWithData:(NSData *)data options:(NSXMLReadingOptions)opt error:(NSError **)error
{
    NSXMLSerialization *xmlSerialization = [[NSXMLSerialization alloc] init];
    if (error != nil) {
        xmlSerialization.error = *error;
    }
    if (opt & NSXMLReadingWrapRootNode) {
        xmlSerialization.wrapRootNode = YES;
    }
    if (opt & NSXMLReadingPreserveComments) {
        xmlSerialization.preserveComments = YES;
    }
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = xmlSerialization;
    BOOL isValid = [parser parse];
    if (isValid) {
        return xmlSerialization.root;
    } else {
        return nil;
    }
}

+ (NSInteger)writeXMLObject:(id)obj toStream:(NSOutputStream *)stream options:(NSXMLWritingOptions)opt error:(NSError **)error
{
    return 0;
}

+ (nullable id)XMLObjectWithStream:(NSInputStream *)stream options:(NSXMLReadingOptions)opt error:(NSError **)error
{
    return nil;
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // Create stack to store parsing elements.
    self.stack = [NSMutableArray arrayWithCapacity:0];
    // Create object to store current element text value.
    self.text = [NSMutableString stringWithCapacity:0];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    if (self.text.length) {
        NSAssert(NO, @"Needs?");
//        NSMutableDictionary *previousElement = self.stack.lastObject;
//        id existing = previousElement[kNSXMLSerializationTextNodeKey];
//        if ([existing isKindOfClass:NSArray.class]) {
//            [existing addObject:self.text];
//        } else if (existing) {
//            previousElement[kNSXMLSerializationTextNodeKey] = [@[existing, self.text] mutableCopy];
//        } else {
//            previousElement[kNSXMLSerializationTextNodeKey] = self.text;
//        }
    }
//    self.text = [NSMutableString stringWithCapacity:0];

    // Create Dictionary for processing element
    NSMutableDictionary<NSString *, id> *processingElement = [NSMutableDictionary dictionaryWithCapacity:0];
    // Set attributes into processing element dictionary
    for (NSString *key in attributeDict.allKeys) {
        NSString *attributePrefixKey = [kNSXMLSerializationAttributePrefix stringByAppendingString:key];
        processingElement[attributePrefixKey] = attributeDict[key];
    }
    if (self.root == nil) {
        // Process root element
        if (self.wrapRootNode) {
            self.root = [NSMutableDictionary dictionaryWithObject:processingElement forKey:elementName];
            [self.stack addObject:self.root];
        } else {
            self.root = processingElement;
        }
        [self.stack addObject:processingElement];
    } else {
        // Create or merge processing element to previous element
        NSMutableDictionary<NSString *, id> *previousElement = self.stack.lastObject;
        id existing = previousElement[elementName];
        if ([existing isKindOfClass:NSArray.class]) {
            [existing addObject:processingElement];
        } else if (existing) {
            previousElement[elementName] = [@[existing, processingElement] mutableCopy];
        } else {
            previousElement[elementName] = processingElement;
        }
        [self.stack addObject:processingElement];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSMutableDictionary<NSString *, id> *processingElement = self.stack.lastObject;
    if (self.text.length) {
        id existing = processingElement[kNSXMLSerializationTextNodeKey];
        if ([existing isKindOfClass:NSArray.class]) {
            [existing addObject:self.text];
        } else if (existing) {
            processingElement[kNSXMLSerializationTextNodeKey] = [@[existing, self.text] mutableCopy];
        } else {
            processingElement[kNSXMLSerializationTextNodeKey] = self.text;
        }
    }
    self.text = [NSMutableString stringWithCapacity:0];
    [self.stack removeLastObject];

    // Check would collepse element
    NSMutableDictionary<NSString *, id> *filteredDict = [NSMutableDictionary dictionaryWithDictionary:processingElement];
    [filteredDict removeObjectsForKeys:@[kNSXMLSerializationCommentsKey, kNSXMLSerializationTextNodeKey]];
    NSMutableDictionary *attributes = [filteredDict mutableCopy];
    for (NSString *key in attributes.allKeys) {
        [attributes removeObjectForKey:key];
        if ([key hasPrefix:kNSXMLSerializationAttributePrefix]) {
            attributes[[key substringFromIndex:kNSXMLSerializationAttributePrefix.length]] = processingElement[key];
        }
    }
    NSMutableDictionary *childNodes = [filteredDict mutableCopy];
    for (NSString *key in childNodes.allKeys) {
        if ([key hasPrefix:kNSXMLSerializationAttributePrefix]) {
            [childNodes removeObjectForKey:key];
        }
    }
    NSDictionary *comments = processingElement[kNSXMLSerializationCommentsKey];
    if (attributes.count == 0 && childNodes.count == 0 && comments.count == 0) {
        NSMutableDictionary<NSString *, id> *previousElement = self.stack.lastObject;

        NSString *nodeName = nil;
        for (NSString *name in previousElement) {
            id object = previousElement[name];
            if (object == processingElement) {
                nodeName = name;
            } else if ([object isKindOfClass:NSArray.class] && [(NSArray *)object containsObject:processingElement]) {
                nodeName = name;
            }
        }
        NSAssert([elementName isEqualToString:nodeName], @"elementName is not the same as nodeName");
        if (nodeName) {
            id parentNode = previousElement[nodeName];
            id text = processingElement[kNSXMLSerializationTextNodeKey];
            NSString *innerText = text;
            if ([text isKindOfClass:NSArray.class]) {
                innerText = [text componentsJoinedByString:@"\n"];
            }
            if (innerText) {
                if ([parentNode isKindOfClass:NSArray.class]) {
                    NSMutableArray *parentNodeArray = parentNode;
                    parentNodeArray[parentNodeArray.count - 1] = innerText;
                } else {
                    previousElement[nodeName] = innerText;
                }
            }
        }
        return;

        id parentNode = previousElement[elementName];
        id text = processingElement[kNSXMLSerializationTextNodeKey];
        NSString *innerText = text;
        if ([text isKindOfClass:NSArray.class]) {
            innerText = [text componentsJoinedByString:@"\n"];
        }
        if (innerText) {
            if ([parentNode isKindOfClass:NSArray.class]) {
                NSMutableArray *parentNodeArray = parentNode;
                parentNodeArray[parentNodeArray.count - 1] = innerText;
            } else {
                previousElement[elementName] = innerText;
            }
        }
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *text = [string stringByTrimmingCharactersInSet:characterSet];
    [self.text appendString:text];
}

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment
{
    if (self.preserveComments) {
        NSMutableDictionary<NSString *, id> *processingElement = self.stack.lastObject;
        NSMutableArray<NSString *> *comments = processingElement[kNSXMLSerializationCommentsKey];
        if (!comments) {
            comments = [@[comment] mutableCopy];
            processingElement[kNSXMLSerializationCommentsKey] = comments;
        } else {
            [comments addObject:comment];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    NSString *text = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
    [self.text appendString:text];
}

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI
{

}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix
{

}

- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString
{

}

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID
{
    return nil;
}

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model
{

}

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data
{

}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    ///Handle parse error
    //Set error prorerty pointer to parse error.
    self.error = parseError;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError
{
    ///Handle validation error
    //Set error prorerty pointer to validation error.
    self.error = validationError;
}

#pragma mark - Encoding

+ (NSString *)stringWithXMLObject:(NSDictionary *)dictionary
{
    if (dictionary.count == 0) {
        return nil;
    } else if (dictionary.count == 1) {
        //ignore outermost dictionary
        return [self innerStringWithXMLNode:dictionary];
    } else {
        return [self stringWithXMLNode:dictionary name:@"root"];
    }
}

+ (NSString *)stringWithXMLNode:(id)node name:(NSString *)nodeName
{
    // Process Array, Dictionary and String
    if ([node isKindOfClass:NSArray.class]) {
        NSMutableArray<NSString *> *nodes = [NSMutableArray arrayWithCapacity:[node count]];
        for (id individualNode in node) {
            [nodes addObject:[self stringWithXMLNode:individualNode name:nodeName]];
        }
        return [nodes componentsJoinedByString:@"\n"];
    } else if ([node isKindOfClass:NSDictionary.class]) {
        NSMutableDictionary<NSString *, id> *filteredDict = [NSMutableDictionary dictionaryWithDictionary:node];
        [filteredDict removeObjectsForKeys:@[kNSXMLSerializationCommentsKey, kNSXMLSerializationTextNodeKey]];
        NSMutableDictionary *attributes = [filteredDict mutableCopy];
        for (NSString *key in attributes.allKeys) {
            [attributes removeObjectForKey:key];
            if ([key hasPrefix:kNSXMLSerializationAttributePrefix]) {
                attributes[[key substringFromIndex:kNSXMLSerializationAttributePrefix.length]] = node[key];
            }
        }
        NSMutableString *attributeString = [NSMutableString string];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, __unused BOOL *stop) {
            [attributeString appendFormat:@" %@=\"%@\"", [self stringWithXMLEncoded:key.description], [self stringWithXMLEncoded:value.description]];
        }];
        NSString *innerXML = [self innerStringWithXMLNode:node];
        if (innerXML.length) {
            return [NSString stringWithFormat:@"<%1$@%2$@>%3$@</%1$@>", nodeName, attributeString, innerXML];
        } else {
            return [NSString stringWithFormat:@"<%@%@/>", nodeName, attributeString];
        }
    } else {
        return [NSString stringWithFormat:@"<%1$@>%2$@</%1$@>", nodeName, [self stringWithXMLEncoded:[node description]]];
    }
}

+ (NSString *)innerStringWithXMLNode:(NSDictionary *)dictionary
{
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:0];
    // Comments
    for (NSString *comment in dictionary[kNSXMLSerializationCommentsKey]) {
        [nodes addObject:[NSString stringWithFormat:@"<!--%@-->", comment]];
    }
    // Filter except Child Nodes
    NSMutableDictionary<NSString *, id> *filteredDict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    // Remove Comments and Text Nodes
    [filteredDict removeObjectsForKeys:@[kNSXMLSerializationCommentsKey, kNSXMLSerializationTextNodeKey]];
    for (NSString *key in filteredDict.allKeys) {
        // Ignore Attributes
        if ([key hasPrefix:kNSXMLSerializationAttributePrefix] == NO) {
            [nodes addObject:[self stringWithXMLNode:filteredDict[key] name:key]];
        }
    }
    // Text
    id text = dictionary[kNSXMLSerializationTextNodeKey];
    NSString *innerText = text;
    if ([text isKindOfClass:NSArray.class]) {
        innerText = [text componentsJoinedByString:@"\n"];
    }
    if (innerText) {
        [nodes addObject:[self stringWithXMLEncoded:innerText]];
    }
    return [nodes componentsJoinedByString:@"\n"];
}

+ (NSString *)stringWithXMLEncoded:(NSString *)string
{
    return [[[[[string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"]
               stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"]
               stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"]
             stringByReplacingOccurrencesOfString:@"\'" withString:@"&apos;"]
            stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
}

+ (NSString *)stringWithXMLDecoded:(NSString *)string
{
    return [[[[[string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"]
               stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"]
              stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]
             stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"]
            stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
}

@end
