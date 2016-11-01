#import "Post.h"

@implementation Post

- (instancetype)init {
  return [self initWithUid:@"" andUsername:@"" andDatestamp:@"" andCode:@"" andContent:@""];
}

- (instancetype)initWithUid:(NSString *)uid
                 andUsername:(NSString *)username)
                  andDatestamp:(NSString *)datestamp
                   andCode:(NSString *)code 
		   andContent:(NSString *)content { 
  self = [super init];
  if (self) {
    self.uid = uid;
    self.username = username;
    self.datestamp = datestamp;
    self.code = code;
    self.content = content;
  }
  return self;
}
@end
