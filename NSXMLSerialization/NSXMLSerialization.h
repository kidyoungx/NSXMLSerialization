//
//  NSXMLSerialization.h
//  CinCer
//
//  Created by Kid Young on 3/14/17.
//  Copyright © 2017 Yang XiHong. All rights reserved.
//

#import <Foundation/NSObject.h>

@class NSError, NSOutputStream, NSInputStream, NSData;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, NSXMLReadingOptions) {
    NSXMLReadingMutableContainers = (1UL << 0),
    NSXMLReadingMutableLeaves = (1UL << 1),
    NSXMLReadingAllowFragments = (1UL << 2),

    NSXMLReadingWrapRootNode = 1 << 3,
    NSXMLReadingPreserveComments = 1 << 4,
} NS_ENUM_AVAILABLE(10_7, 5_0);

typedef NS_OPTIONS(NSUInteger, NSXMLWritingOptions) {
    NSXMLWritingPrettyPrinted = (1UL << 0)
} NS_ENUM_AVAILABLE(10_7, 5_0);

/* A class for converting XML to Foundation objects and converting Foundation objects to XML.

 An object that may be converted to XML must have the following properties:
 - Top level object is an NSArray or NSDictionary
 - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
 - All dictionary keys are NSStrings
 - NSNumbers are not NaN or infinity
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface NSXMLSerialization : NSObject {
@private
    void *reserved[6];
}

/* Returns YES if the given object can be converted to XML data, NO otherwise. The object must have the following properties:
 - Top level object is an NSArray or NSDictionary
 - All objects are NSString, NSNumber, NSArray, NSDictionary, or NSNull
 - All dictionary keys are NSStrings
 - NSNumbers are not NaN or infinity
 Other rules may apply. Calling this method or attempting a conversion are the definitive ways to tell if a given object can be converted to XML data.
 */
+ (BOOL)isValidXMLObject:(id)obj;

/* Generate XML data from a Foundation object. If the object will not produce valid XML then an exception will be thrown. Setting the NSXMLWritingPrettyPrinted option will generate XML with whitespace designed to make the output more readable. If that option is not set, the most compact possible XML will be generated. If an error occurs, the error parameter will be set and the return value will be nil. The resulting data is a encoded in UTF-8.
 */
+ (nullable NSData *)dataWithXMLObject:(id)obj options:(NSXMLWritingOptions)opt error:(NSError **)error;

/* Create a Foundation object from XML data. Set the NSXMLReadingAllowFragments option if the parser should allow top-level objects that are not an NSArray or NSDictionary. Setting the NSXMLReadingMutableContainers option will make the parser generate mutable NSArrays and NSDictionaries. Setting the NSXMLReadingMutableLeaves option will make the parser generate mutable NSString objects. If an error occurs during the parse, then the error parameter will be set and the result will be nil.
   The data must be in one of the 5 supported encodings listed in the XML specification: UTF-8, UTF-16LE, UTF-16BE, UTF-32LE, UTF-32BE. The data may or may not have a BOM. The most efficient encoding to use for parsing is UTF-8, so if you have a choice in encoding the data passed to this method, use UTF-8.
 */
+ (nullable id)XMLObjectWithData:(NSData *)data options:(NSXMLReadingOptions)opt error:(NSError **)error;

/* Write XML data into a stream. The stream should be opened and configured. The return value is the number of bytes written to the stream, or 0 on error. All other behavior of this method is the same as the dataWithXMLObject:options:error: method.
 */
+ (NSInteger)writeXMLObject:(id)obj toStream:(NSOutputStream *)stream options:(NSXMLWritingOptions)opt error:(NSError **)error NS_UNAVAILABLE;

/* Create a XML object from XML data stream. The stream should be opened and configured. All other behavior of this method is the same as the XMLObjectWithData:options:error: method.
 */
+ (nullable id)XMLObjectWithStream:(NSInputStream *)stream options:(NSXMLReadingOptions)opt error:(NSError **)error NS_UNAVAILABLE;

/* Transform 
 & : &amp;
 < : &lt;
 > : &gt;
 ' : &apos;
 " : &quot;
 use for internal xml
 */
+ (NSString *)stringWithXMLEncoded:(NSString *)string;

/* Transform internal xml
 &amp; : &
 &lt; : <
 &gt; : >
 &apos; : '
 &quot; : "
 back to xml
 */
+ (NSString *)stringWithXMLDecoded:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
