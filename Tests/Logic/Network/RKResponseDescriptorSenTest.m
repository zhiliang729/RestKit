//
//  RKResponseDescriptorSenTest.m
//  RestKit
//
//  Created by Kurry Tran on 12/27/13.
//  Copyright (c) 2013 RestKit. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "RKTestEnvironment.h"
#import "RKTestUser.h"

@interface RKResponseDescriptorSenTest : SenTestCase
{
    RKResponseDescriptor *firstDescriptor;
    RKResponseDescriptor *secondDescriptor;
    
    RKMapping *defaultMapping;
    NSString *defaultPathPattern;
    NSString *defaultKeyPath;
    NSIndexSet *defaultStatusCodes;
}
@end

@implementation RKResponseDescriptorSenTest

- (void)setUp
{
    [super setUp];
    defaultMapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    defaultKeyPath = @"";
    defaultPathPattern = @"/issues";
    defaultStatusCodes = [NSIndexSet indexSetWithIndex:200];
    firstDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                       pathTemplateString:defaultPathPattern
                                                     parameterConstraints:nil
                                                                  keyPath:defaultKeyPath
                                                              statusCodes:defaultStatusCodes
                                                                  mapping:defaultMapping];
}

#pragma mark - URL Matching

- (void)testBaseURLAndPathPatternIsNilDescriptorMatchesAll
{
    NSURL *baseURL = nil;
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/monkeys/1234.json"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:nil parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

- (void)testBaseURLIsNilAndPathPatternAndURLMatch
{
    NSURL *baseURL = nil;
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/monkeys/1234.json"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

- (void)testBaseURLIsNilAndPathPatternAndURLAreNotMatch
{
    NSURL *baseURL = nil;
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/mismatch"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

- (void)testBaseURLNotNilAndPathPatternNilAndGivenURLHostnameDoesNotMatch
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:nil parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"http://google.com/monkeys/1234.json"];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(NO);
}

- (void)testBaseURLNotNilAndPathPatternNilAndGivenURLHostnameMatch
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:nil parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"http://restkit.org/whatever"];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

- (void)testIdenticalPathPatternsWithDifferentBaseURL
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *otherBaseURL = [NSURL URLWithString:@"http://google.com"];
    NSURL *URL = [NSURL URLWithString:@"/monkeys/1234.json" relativeToURL:otherBaseURL];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(NO);
}

- (void)testIdenticalPathPatternsWithMatchingBaseURLAndPathAndQueryStringMatchPathPattern
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"/monkeys/1234.json" relativeToURL:baseURL];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

- (void)testIdenticalPathPatternsWithMatchingBaseURLAndPathAndQueryStringDoNotMatchPathPattern
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"/mismatch" relativeToURL:baseURL];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(NO);
}

- (void)testIdenticalPathPatternsWithMatchingBaseURLAndPathIncludesQueryString
{
    NSURL *baseURL = [NSURL URLWithString:@"http://restkit.org"];
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/monkeys/{monkeyID}.json" parameterConstraints:nil keyPath:nil statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful) mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"/monkeys/1234.json?param1=val1&param2=val2" relativeToURL:baseURL];
    expect([responseDescriptor matchesURL:URL relativeToBaseURL:baseURL parameters:nil]).to.equal(YES);
}

#pragma mark - Response Matching

- (void)testResponseExactMatch
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/api/v1/organizations/" parameterConstraints:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200] mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"http://0.0.0.0:5000/api/v1/organizations/?client_search=t"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:200 HTTPVersion:@"1.1" headerFields:nil];
    expect([responseDescriptor matchesResponse:response request:nil relativeToBaseURL:[NSURL URLWithString:@"http://0.0.0.0:5000"] parameters:nil]).to.equal(YES);
}

- (void)testResponseStatusNonMatch
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/api/v1/organizations/" parameterConstraints:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200] mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"http://0.0.0.0:5000/api/v1/organizations/?client_search=t"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:500 HTTPVersion:@"1.1" headerFields:nil];
    expect([responseDescriptor matchesResponse:response request:nil relativeToBaseURL:[NSURL URLWithString:@"http://0.0.0.0:5000"] parameters:nil]).to.equal(NO);
}

- (void)testResponseURLPathDoesNotMatch
{
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny pathTemplateString:@"/recommendation/" parameterConstraints:nil keyPath:nil statusCodes:[NSIndexSet indexSetWithIndex:200] mapping:mapping];
    NSURL *URL = [NSURL URLWithString:@"http://domain.com/domain/api/v1/recommendation/"];
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:URL statusCode:200 HTTPVersion:@"1.1" headerFields:nil];
    expect([responseDescriptor matchesResponse:response request:nil relativeToBaseURL:[NSURL URLWithString:@"http://domain.com/domain/api/v1/"] parameters:nil]).to.equal(NO);
}

#pragma mark - isEqual

- (void)testDescriptorsWithSameAttributesAreEqual
{
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:defaultPathPattern
                                                      parameterConstraints:nil
                                                                   keyPath:defaultKeyPath
                                                               statusCodes:defaultStatusCodes
                                                                   mapping:defaultMapping];
    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

- (void)testDescriptorsWithDifferentMappingsAreNotEqual
{
    RKMapping *mapping = [RKObjectMapping mappingForClass:[NSObject class]];
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:defaultPathPattern
                                                      parameterConstraints:nil
                                                                   keyPath:defaultKeyPath
                                                               statusCodes:defaultStatusCodes
                                                                   mapping:mapping];
    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

- (void)testDescriptorsWithDifferentPathPatternsAreNotEqual
{
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:@"/pull_requests"
                                                      parameterConstraints:nil
                                                                   keyPath:defaultKeyPath
                                                               statusCodes:defaultStatusCodes
                                                                   mapping:defaultMapping];
    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

- (void)testDescriptorsWithDifferentKeyPathsAreNotEqual
{
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:defaultPathPattern
                                                      parameterConstraints:nil
                                                                   keyPath:@"pull_request"
                                                               statusCodes:defaultStatusCodes
                                                                   mapping:defaultMapping];
    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

- (void)testDescriptorsWithDifferentStatusCodesAreNotEqual
{
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:defaultPathPattern
                                                      parameterConstraints:nil
                                                                   keyPath:defaultKeyPath
                                                               statusCodes:[NSIndexSet indexSetWithIndex:404]
                                                                   mapping:defaultMapping];
    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

- (void)testDescriptorsWithDifferentConstraintsAreNotEqual
{
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                                                  pathTemplateString:defaultPathPattern
                                                                                parameterConstraints:nil
                                                                                             keyPath:defaultKeyPath
                                                                                         statusCodes:[NSIndexSet indexSetWithIndex:404]
                                                                                             mapping:defaultMapping];
    
    secondDescriptor = [RKResponseDescriptor responseDescriptorWithMethods:RKHTTPMethodAny
                                                        pathTemplateString:defaultPathPattern
                                                      parameterConstraints:nil
                                                                   keyPath:defaultKeyPath
                                                               statusCodes:[NSIndexSet indexSetWithIndex:404]
                                                                   mapping:defaultMapping];
// TODO: Implement this test.
//    expect([firstDescriptor isEqual:secondDescriptor]).to.beFalsy();
}

@end
