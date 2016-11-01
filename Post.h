#import <Foundation/Foundation.h>

@interface Post : NSObject
@property(strong, nonatomic) NSString *uid;
@property(strong, nonatomic) NSString *username;
@property(strong, nonatomic) NSString *datestamp;
@property(strong, nonatomic) NSString *code;
@property(strong, nonatomic) NSString *content;

- (instancetype)initWithUid:(NSString *)uid
                  andUsername:(NSString *)username
                   andDatestamp:(NSString *)datestamp
                   andCode:(NSString *)code
                    andContent:(NSString *)content;

@end
