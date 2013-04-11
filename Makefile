all: DestinationAtop.cifilter DestinationIn.cifilter DestinationOut.cifilter DestinationOver.cifilter
.PHONY: all

CFLAGS+=-fobjc-arc
LDFLAGS+=-framework Foundation -framework QuartzCore

DestinationAtop.cifilter: makeDestinationCIFilter
	./$^ Atop
DestinationIn.cifilter: makeDestinationCIFilter
	./$^ In
DestinationOut.cifilter: makeDestinationCIFilter
	./$^ Out
DestinationOver.cifilter: makeDestinationCIFilter
	./$^ Over

makeDestinationCIFilter: makeDestinationCIFilter.o
