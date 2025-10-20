#import "WMFSourceEditorFormatterUnderline.h"
#import "WMFSourceEditorColors.h"

@interface WMFSourceEditorFormatterUnderline ()

@property (nonatomic, strong) NSDictionary *underlineAttributes;
@property (nonatomic, strong) NSDictionary *underlineContentAttributes;
@property (nonatomic, strong) NSRegularExpression *underlineRegex;

@end

@implementation WMFSourceEditorFormatterUnderline

#pragma mark - Custom Attributed String Keys
NSString * const WMFSourceEditorCustomKeyContentUnderline = @"WMFSourceEditorCustomKeyContentUnderline";

- (instancetype)initWithColors:(WMFSourceEditorColors *)colors fonts:(WMFSourceEditorFonts *)fonts {
    self = [super initWithColors:colors fonts:fonts];
    if (self) {
        _underlineAttributes = @{
            NSForegroundColorAttributeName: colors.greenForegroundColor,
            WMFSourceEditorCustomKeyColorGreen: [NSNumber numberWithBool:YES]
        };

        _underlineContentAttributes = @{
            WMFSourceEditorCustomKeyContentUnderline: [NSNumber numberWithBool:YES]
        };

        _underlineRegex = [[NSRegularExpression alloc] initWithPattern:@"(<u>)(.*?)(<\\/u>)" options:0 error:nil];
    }

    return self;
}
- (void)addSyntaxHighlightingToAttributedString:(nonnull NSMutableAttributedString *)attributedString inRange:(NSRange)range {
    
    if (![self canEvaluateAttributedString:attributedString againstRange:range]) {
       return;
    }

    [attributedString removeAttribute:WMFSourceEditorCustomKeyContentUnderline range:range];

    [self.underlineRegex enumerateMatchesInString:attributedString.string
                                        options:0
                                          range:range
                                     usingBlock:^(NSTextCheckingResult *_Nullable result, NSMatchingFlags flags, BOOL *_Nonnull stop) {
            NSRange fullMatch = [result rangeAtIndex:0];
            NSRange openingRange = [result rangeAtIndex:1];
            NSRange contentRange = [result rangeAtIndex:2];
            NSRange closingRange = [result rangeAtIndex:3];

            if (openingRange.location != NSNotFound) {
                [attributedString addAttributes:self.underlineAttributes range:openingRange];
            }

            if (contentRange.location != NSNotFound) {
                [attributedString addAttributes:self.underlineContentAttributes range:contentRange];
            }

            if (closingRange.location != NSNotFound) {
                [attributedString addAttributes:self.underlineAttributes range:closingRange];
            }
        }];
}

- (void)updateFonts:(WMFSourceEditorFonts *)fonts inAttributedString:(NSMutableAttributedString *)attributedString inRange:(NSRange)range {
}

- (void)updateColors:(WMFSourceEditorColors *)colors inAttributedString:(NSMutableAttributedString *)attributedString inRange:(NSRange)range {

    NSMutableDictionary *mutAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.underlineAttributes];
    [mutAttributes setObject:colors.greenForegroundColor forKey:NSForegroundColorAttributeName];
    self.underlineAttributes = [[NSDictionary alloc] initWithDictionary:mutAttributes];
    
    if (![self canEvaluateAttributedString:attributedString againstRange:range]) {
       return;
    }

    [attributedString enumerateAttribute:WMFSourceEditorCustomKeyColorGreen
                                 inRange:range
                                 options:nil
                              usingBlock:^(id value, NSRange localRange, BOOL *stop) {
        if ([value isKindOfClass: [NSNumber class]]) {
            NSNumber *numValue = (NSNumber *)value;
            if ([numValue boolValue] == YES) {
                [attributedString addAttributes:self.underlineAttributes range:localRange];
            }
        }
    }];

}

#pragma mark - Public

- (BOOL)attributedString:(nonnull NSMutableAttributedString *)attributedString isUnderlineInRange:(NSRange)range {
    
    if (![self canEvaluateAttributedString:attributedString againstRange:range]) {
       return NO;
    }
    
    __block BOOL isContentKey = NO;

   if (range.length == 0) {

           NSDictionary<NSAttributedStringKey,id> *attrs = [attributedString attributesAtIndex:range.location effectiveRange:nil];

           if (attrs[WMFSourceEditorCustomKeyContentUnderline] != nil) {
               isContentKey = YES;
           } else {
               NSRange newRange = NSMakeRange(range.location - 1, 0);
               if (attrs[WMFSourceEditorCustomKeyColorGreen] && [self canEvaluateAttributedString:attributedString againstRange:newRange]) {
                   attrs = [attributedString attributesAtIndex:newRange.location effectiveRange:nil];
                   if (attrs[WMFSourceEditorCustomKeyContentUnderline] != nil) {
                       isContentKey = YES;
                   }
               }
           }

   } else {
       __block NSRange unionRange = NSMakeRange(NSNotFound, 0);
       [attributedString enumerateAttributesInRange:range options:nil usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange loopRange, BOOL * _Nonnull stop) {
           if (attrs[WMFSourceEditorCustomKeyContentUnderline] != nil) {
               if (unionRange.location == NSNotFound) {
                   unionRange = loopRange;
               } else {
                   unionRange = NSUnionRange(unionRange, loopRange);
               }
               stop = YES;
           }
       }];

        if (NSEqualRanges(unionRange, range)) {
            isContentKey = YES;
        }
   }
   return isContentKey;
}

@end
