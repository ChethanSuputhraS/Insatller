/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"
#import "objc/runtime.h"

static char operationKey;

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)setImageWithURL:(NSURL *)url completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletedBlock)completedBlock
{
    [self setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)removeIndicator{
    UIView *overlay = [self viewWithTag:100];
    [UIView animateWithDuration:0.25 animations:^{
        overlay.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [overlay removeFromSuperview];
    }];

}

- (void)addIndicator:(NSURL*) url{
//    NSInteger style = UIActivityIndicatorViewStyleGray;
    NSInteger style = UIActivityIndicatorViewStyleGray;

    if ([url.relativePath rangeOfString:@"collection"].location != NSNotFound) {
        style = UIActivityIndicatorViewStyleGray;
    }
    UIImageView *overlay = [[UIImageView alloc] initWithFrame:self.bounds];
    overlay.image = self.image;
    overlay.tag = 100;
    [self addSubview:overlay];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    indicator.alpha = 1.0;
    CGRect bounds = self.bounds;
    CGPoint centerP = CGPointMake(bounds.size.width/2, bounds.size.height/2);
    indicator.center = centerP;
    indicator.hidesWhenStopped = YES;
    [indicator startAnimating];
//    [overlay addSubview:indicator];
    
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedBlock)completedBlock;
{
    [self cancelCurrentImageLoad];

    self.image = placeholder;
    if (url)
    {
        [self addIndicator:url];
        __weak UIImageView *wself = self;
        id<SDWebImageOperation> operation = [SDWebImageManager.sharedManager downloadWithURL:url options:options progress:progressBlock completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
        {
            __strong UIImageView *sself = wself;
            if (!sself) return;
            if (image)
            {
                sself.image = image;
                [sself setNeedsLayout];
            }
            if (completedBlock && finished)
            {
                completedBlock(image, error, cacheType);
            }
            [sself removeIndicator];

        }];
        objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancel in progress downloader from queue
    id<SDWebImageOperation> operation = objc_getAssociatedObject(self, &operationKey);
    if (operation)
    {
        [operation cancel];
        objc_setAssociatedObject(self, &operationKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
