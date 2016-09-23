//
//  CliplayTests.m
//  CliplayTests
//
//  Created by 邢磊 on 2016/9/23.
//
//

#import <XCTest/XCTest.h>
#import "User.h"

@interface CliplayTests : XCTestCase
@property (nonatomic, strong) User *user;
@end

@implementation CliplayTests

- (void)setUp {
    [super setUp];
//	_user = [[User alloc] init];
	_user = [User loadWithDefault];
//	NSLog(_user);
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
	_user.name = @"xl";
//	_user.avatar = @"";
//	_user.wbAccessToken = @"";
//	_user.wbRefreshToken = _user.wbRefreshToken;
	[_user save];
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
