// Copyright © 2017 Tellus, Inc. All rights reserved.

#import "NSString+Helper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Helper)

- (NSString *)trimmed {
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (NSString *)titleized {
    if (isEmpty(self)) { return self; }
    NSSet *smallWords = [NSSet setWithArray:@[
        @"a", @"an", @"and", @"the", @"at", @"by", @"for", @"in", @"of", @"off", @"on", @"out", @"to", @"as", @"but", @"if", @"or", @"nor", @"so",
        @"from", @"into", @"onto", @"over", @"with"
    ]];
    NSPredicate *ordinalOrCardinalPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"(\\b\\d{1,}(?i:st|nd|rd|th)?\\b)"];

    NSMutableString *result = [self.lowercaseString mutableCopy];
    [result enumerateSubstringsInRange:NSMakeRange(0, result.length) options:NSStringEnumerationByWords usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        BOOL isOrdinalOrCardinal = [ordinalOrCardinalPredicate evaluateWithObject:substring];
        BOOL shouldCapitalize = ![smallWords containsObject:substring] && isNotEmpty(substring.firstLetter) && !isOrdinalOrCardinal;
        if (shouldCapitalize) {
            [result replaceCharactersInRange:substringRange withString:substring.capitalizedString];
        }
    }];
    return result;
}

- (NSString *)letterCharactersOnlyString {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet.letterCharacterSet invertedSet]] componentsJoinedByString:@""];
}

- (NSString *)alphanumericCharactersOnlyString {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet.alphanumericCharacterSet invertedSet]] componentsJoinedByString:@""];
}

- (NSString *)numbersOnlyString {
    return [[self componentsSeparatedByCharactersInSet:[NSCharacterSet.decimalDigitCharacterSet invertedSet]] componentsJoinedByString:@""];
}

- (NSString *)phoneNumbersOnlyString {
    NSString *numbersOnlyString = [self numbersOnlyString];
    if ([self hasPrefix:@"+"]) { return [@"+" stringByAppendingString:numbersOnlyString]; }
    return numbersOnlyString;
}

- (NSString *)urlDecodedString {
    NSString *result = [(NSString *)self stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    result = [result stringByRemovingPercentEncoding];
    return result;
}

- (NSString *)hashValue {
    const char *cstring = [self UTF8String];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(cstring, (unsigned int)strlen(cstring), digest);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x"
            "%02x%02x%02x%02x%02x"
            "%02x%02x%02x%02x%02x"
            "%02x%02x%02x%02x%02x",
            digest[0],  digest[1],  digest[2],  digest[3],  digest[4],
            digest[5],  digest[6],  digest[7],  digest[8],  digest[9],
            digest[10], digest[11], digest[12], digest[13], digest[14],
            digest[15], digest[16], digest[17], digest[18], digest[19]];
}

- (NSString *)md5 {
    const char *string = [self UTF8String];
    unsigned char result[16];
    CC_MD5(string, (unsigned int)strlen(string), result);
    NSString *hash = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    return [hash lowercaseString];
}

- (NSString *)sha1 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1(data.bytes, (unsigned int)data.length, digest);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) { [output appendFormat:@"%02x", digest[i]]; }

    return output;
}

- (double)searchDoubleValue {
    // Check if doubleValue is not equal to 0.
    // If not equal to 0, then return doubleValue
    // If equal to 0, then check if string contains any non-decimal-digit characters.
    // If not, return 0
    // If yes, return DBL_MAX
    //
    // string   doubleValue     searchDoubleValue
    // 5        5               5
    // 0        0               0
    // A        0               DBL_MAX
    if (self.doubleValue != 0 || [self rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet.invertedSet].location == NSNotFound) {
        return self.doubleValue;
    }
    return DBL_MAX;
}

- (BOOL)isEqualToStringCaseInsensitive:(NSString *)string {
    if ([self caseInsensitiveCompare:string] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

/**
 Get height of the string for given width and font

 @param width (CGFloat) Maximum width of the string
 @param font (UIFont) Font of the string
 @return (CGFloat) Height of the given string
 */
- (CGFloat)heightOfStringForWidth:(CGFloat)width font:(UIFont *)font {
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : font}
                                         context:nil];

    return textRect.size.height;
}

/**
 Get width of the string for given height and font

 @param height (CGFloat) Maximum height of the string
 @param font (UIFont) Font of the string
 @return (CGFloat) Width of the given string
 */
- (CGFloat)widthOfStringForHeight:(CGFloat)height font:(UIFont *)font {
    CGRect textRect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName : font}
                                         context:nil];

    return textRect.size.width;
}

- (CGSize)sizeForBalancedLineWidthWithFont:(UIFont *)font maxWidth:(CGFloat)maxWidth {
    if (isEmpty(self)) { return CGSizeZero; }
    // Prepare string to measure
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self attributes:@{NSFontAttributeName : font}];
    // Measure size using full width
    CGSize size = [attributedText boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    // Attempting to balance single line strings is useless
    NSInteger lineCount = round(size.height / font.lineHeight);
    if (lineCount <= 1) { return size; }
    // Reduce width until we start flowing onto more lines
    const CGFloat kStepSize = 5;
    while (YES) {
        CGSize testSize =
            [attributedText boundingRectWithSize:CGSizeMake(size.width - kStepSize, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        if (testSize.height > size.height) { break; }
        size = testSize;
    }
    // Ceil to prevent rounding problems with view sizing
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}

#if IS_DEBUG
static const char __alphabet[] = "0123456789"
                                 "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                 "abcdefghijklmnopqrstuvwxyz";
+ (NSString *)randomString:(int)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    u_int32_t alphabetLength = (u_int32_t)strlen(__alphabet);
    for (int i = 0; i < length; i++) { [randomString appendFormat:@"%c", __alphabet[arc4random_uniform(alphabetLength)]]; }
    return randomString;
}
#endif

- (NSString *)firstLetter {
    // It cut out any character that is not in the letterCharacterSet, and join them again into 1 string. Then it'll take the first letter of that result as a substring, and return it.
    if (isEmpty(self)) { return @""; }
    NSString *lettersOnlyString = [[self componentsSeparatedByCharactersInSet:NSCharacterSet.letterCharacterSet.invertedSet] componentsJoinedByString:@""];
    if (isEmpty(lettersOnlyString)) { return @""; }
    return [lettersOnlyString substringToIndex:1];
}

- (NSString *)subtractString:(NSString *)stringToSubtract {
    if (isNotEmpty(stringToSubtract)) {
        NSArray<NSString *> *arrayOfStrings = [self componentsSeparatedByString:stringToSubtract]; // Note that this is case sensitive
        if (arrayOfStrings.count == 1) {
            return arrayOfStrings.firstObject.trimmed;
        } else {
            NSString *result = @"";
            for (NSString *subString in arrayOfStrings) { result = [result stringByAppendingString:subString]; }
            return result.trimmed;
        }
    } else {
        return self;
    }
}

+ (NSString *)stringBySafelyAppendingString:(NSString *)firstString withString:(NSString *)secondString {
    if (isEmpty(firstString)) { return secondString.trimmed ?: @""; }
    if (isEmpty(secondString)) { return firstString.trimmed ?: @""; }
    return [@[ firstString.trimmed, secondString.trimmed ] componentsJoinedByString:@" "];
}

- (NSUInteger)wordCount {
    NSCharacterSet *separators = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray *words = [self componentsSeparatedByCharactersInSet:separators];

    NSIndexSet *separatorIndexes = [words indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) { return [obj isEqual:@""]; }];

    return [words count] - [separatorIndexes count];
}

- (NSString *)truncatedStringByLength:(NSUInteger)length appendingEllipsis:(BOOL)shouldAppendEllipsis {
    if (length == 0) { return self; }

    NSRange stringRange = {0, MIN(self.length, length)}; // Defining the length we'll accept
    stringRange = [self rangeOfComposedCharacterSequencesForRange:stringRange]; // Adjust the range to include dependent chars
    NSString *truncatedString = [self substringWithRange:stringRange]; // Limited string

    if (![truncatedString isEqual:self] && shouldAppendEllipsis) { // If the string was truncated
        truncatedString = [truncatedString stringByAppendingString:@"…"];
    }
    return truncatedString;
}

- (NSString *)firstWords:(NSInteger)wordCount {
    if (wordCount < 1 || isEmpty(self)) { return @""; }
    NSMutableArray *words = NSMutableArray.new;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByWords usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        [words addObject:substring];
    }];
    NSArray *interestingWords = [words subarrayWithRange:NSMakeRange(0, MIN(wordCount, words.count))];
    return [interestingWords componentsJoinedByString:@" "];
}

@end

@implementation NSAttributedString (Helper)

+ (instancetype)attributedStringWithImage:(UIImage *)image centeredForFont:(UIFont *)font {
    return [NSAttributedString attributedStringWithImage:image centeredForFont:font withOffset:0];
}

+ (instancetype)attributedStringWithImage:(UIImage *)image centeredForFont:(UIFont *)font withOffset:(CGFloat)offset {
    NSTextAttachment *iconAttachment = [NSTextAttachment new];
    iconAttachment.image = image;
    iconAttachment.bounds = CGRectMake(0, font.capHeight / 2 - image.size.height / 2 + offset, image.size.width, image.size.height);
    return [self attributedStringWithAttachment:iconAttachment];
}

@end

@implementation NSMutableAttributedString (Helper)

- (void)appendString:(NSString *)string {
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:string]];
}

@end
