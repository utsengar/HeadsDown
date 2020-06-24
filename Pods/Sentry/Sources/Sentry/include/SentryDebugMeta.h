#import <Foundation/Foundation.h>

#import "SentrySerializable.h"

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(DebugMeta)
@interface SentryDebugMeta : NSObject <SentrySerializable>

/**
 * UUID of image
 */
@property (nonatomic, copy) NSString *_Nullable uuid;

/**
 * Type of debug meta, mostly just apple
 */
@property (nonatomic, copy) NSString *_Nullable type;

/**
 * Name of the image
 */
@property (nonatomic, copy) NSString *_Nullable name;

/**
 * Image size
 */
@property (nonatomic, copy) NSNumber *_Nullable imageSize;

/**
 * Image address
 */
@property (nonatomic, copy) NSString *_Nullable imageAddress;

/**
 * Image vm address
 */
@property (nonatomic, copy) NSString *_Nullable imageVmAddress;

- (instancetype)init;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
