#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

int main(int argc, char **argv) {
	int success = EXIT_SUCCESS;
	@autoreleasepool {
		NSEnumerator *argsEnum = [[[NSProcessInfo processInfo] arguments] objectEnumerator];
		[argsEnum nextObject];
		NSString *compositeKind = [argsEnum nextObject];
		if (!compositeKind) {
			NSLog(@"Not enough arguments; please specify a compositing kind (Atop, In, Out, or Over)");
			success = EXIT_FAILURE;
		} else {
			CIFilterGenerator *filterGenerator = [CIFilterGenerator filterGenerator];
			NSString *filterName = [NSString stringWithFormat:@"CISource%@Compositing", compositeKind];
			CIFilter *sourceWhatever = [CIFilter filterWithName:filterName];
			if (!sourceWhatever) {
				NSLog(@"Could not find %@ filter to adapt", filterName);
				success = EXIT_FAILURE;
			} else {
				[filterGenerator exportKey:kCIInputBackgroundImageKey
					fromObject:sourceWhatever
					withName:kCIInputImageKey];
				[filterGenerator exportKey:kCIInputImageKey
					fromObject:sourceWhatever
					withName:kCIInputBackgroundImageKey];

				NSMutableDictionary *attributes = [sourceWhatever.attributes mutableCopy];
				[attributes setObject:filterName forKey:kCIAttributeFilterName];
				NSString *sourceDisplayName = [attributes objectForKey:kCIAttributeFilterDisplayName];
				[attributes setObject:[sourceDisplayName stringByReplacingOccurrencesOfString:@"Source" withString:@"Destination"] forKey:kCIAttributeFilterDisplayName];
				NSURL *docURL = [attributes objectForKey:kCIAttributeReferenceDocumentation];
				if (docURL)
					[attributes setObject:[docURL absoluteString] forKey:kCIAttributeReferenceDocumentation];
				[attributes setObject:[sourceWhatever inputKeys] forKey:@"CIInputs"];
				[attributes setObject:[sourceWhatever outputKeys] forKey:@"CIOutputs"];
				filterGenerator.classAttributes = attributes;

				NSString *outputFilename = [NSString stringWithFormat:@"Destination%@.cifilter", compositeKind];
				bool wrote = [filterGenerator writeToURL:[NSURL fileURLWithPath:outputFilename] atomically:YES];
				if (!wrote) {
					NSLog(@"Could not write out generated filter file to %@", outputFilename);
					success = EXIT_FAILURE;
				}
			}
		}
	}
	return success;
}
