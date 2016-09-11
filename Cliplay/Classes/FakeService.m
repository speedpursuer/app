//
//  FakeService.m
//  Example
//
//  Created by Jonathan Tribouharet
//

#import "FakeService.h"
#import "ModelComment.h"

@interface FakeService ()

@property NSArray *fakeData;

@end

@implementation FakeService {
	NSInteger index;
}

- (instancetype)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    [self generateFakeData];
	
	index = 0;
    
    return self;
}

- (void)generateFakeData
{
//    self.fakeData = @[@"Dock Gaylord", @"Mr. Izabella Ziemann", @"Haskell Medhurst DDS", @"Rebeka Torp", @"Shannon Kub", @"Kara Donnelly", @"Johnathan Kuphal", @"Jermaine Shanahan", @"Mrs. Rudy Hilll", @"Nathen Kutch Jr.", @"Elissa Lehner", @"Emmanuel Cruickshank", @"Annette Bechtelar", @"Ashleigh Wolff", @"Roberto Crist", @"Rocky Stamm", @"Adolphus Streich MD", @"Andres Rau", @"Ms. Opal Olson", @"Glenda Balistreri", @"Dr. Javon Sipes", @"Devante Leuschke", @"Liliana Bins", @"Mr. Rosie VonRueden", @"Nina Batz", @"Mrs. Garth Rau", @"Jeffrey Bauch", @"Judge Schmitt", @"Raymundo Rau", @"Mr. Kayley Bruen", @"Wava Reilly", @"Ms. Pablo Mosciski", @"Estrella Cremin", @"Bertram Gutmann", @"Raleigh Schuppe", @"Dr. Jace Kuvalis", @"Kelly Terry", @"Mr. Broderick Crooks", @"Tevin Reinger", @"Mckenna Graham V", @"Howard Kuhn", @"Payton Terry", @"Ofelia Osinski", @"Lera Bogan", @"Luz Gutmann DVM", @"Bulah Schaefer", @"Elissa Williamson", @"Joanne Schamberger", @"Orpha Eichmann", @"Haylee Hartmann", @"Cary Toy", @"Danial Marvin", @"Mrs. Wilbert Reynolds", @"Dr. Mable Ledner", @"Albin Leffler", @"Osbaldo Marks", @"Omari Wolf MD", @"Isabelle Schroeder", @"Douglas Kohler", @"Tomasa Reichert", @"Larue Von", @"Taylor Roberts MD", @"Mose Frami", @"Patrick Kautzer I", @"Godfrey Gottlieb V", @"Pearlie Kuhlman MD", @"Dixie Kiehn I", @"Karianne Larson", @"Terry Daugherty Sr.", @"Newell Pfannerstill I", @"Lola Johns", @"Freeda Wintheiser PhD", @"Yolanda Abbott", @"Lauryn Howe", @"June Kautzer", @"Zoie Bradtke", @"Ms. Vanessa Watsica", @"Janae Davis", @"Norene Harris", @"Brooks Ebert Sr."];
	
	self.fakeData = [self generateData];
}

- (NSArray *)generateData {
	NSMutableArray *array = [NSMutableArray new];
	for (int i = 0; i <= 30; i++) {
		[array addObject: [ModelComment commentWithProperties: [self commentData:i]]];
	}
	return [array copy];
}

- (NSDictionary *)commentData:(int)index{
	return @{
			 @"text": [@"可以的 " stringByAppendingString: @(index).stringValue],
			 @"time": @"2016-07-22T08:38:37.000Z",
			 @"author": @{
						@"name": @"*Оo糖oОo糖oО*",
						@"avatar": @"http://q.qlogo.cn/qqapp/1105320149/44BC003E5565C102A0842474BC16694F/100"
					 }
			 };
}

- (void)retrieveDataWithOffset:(NSUInteger)offset
                       success:(void (^)(NSArray *results, BOOL haveMoreData))success
                       failure:(void (^)())failure
{
    // 2 seconds of delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        BOOL haveMoreData = YES;
        NSUInteger pageSize = 10;
        if((offset + pageSize) >= self.fakeData.count){
            pageSize = self.fakeData.count - offset;
            haveMoreData = NO;
        }
        
        NSIndexSet *indexes = [[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(offset, pageSize)];
        NSArray *dataToReturn = [self.fakeData objectsAtIndexes:indexes];
        
        success(dataToReturn, haveMoreData);
    });
}

- (void)retrieveNoDataWithOffset:(NSUInteger)pageOffset
                         success:(void (^)(NSArray *results, BOOL haveMoreData))success
                         failure:(void (^)())failure
{
    // 2 seconds of delay
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        success(@[], NO);
    });
}

- (void)addNewCommentForClipID:(NSString *)clipID
					  withText:(NSString *)text
					  external:(BOOL)external
{
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		
		ModelComment *newComment = [ModelComment
								   commentWithProperties:@{@"text": [NSString stringWithFormat:@"%@ %ld", text, index],
														   @"time": @"2016-08-07T08:19:08.000Z",
														   @"author": @{
																	@"name": @"测试用户",
																	@"avatar": @"http://tva3.sinaimg.cn/crop.0.0.180.180.50/4abb6feegw1e9in5d2pqqj205005074c.jpg"
																	}
														   }];
		
		
		[self.delegate didPerformActionWithResult:newComment error:FALSE];
		
		index++;		
	});
}

@end
