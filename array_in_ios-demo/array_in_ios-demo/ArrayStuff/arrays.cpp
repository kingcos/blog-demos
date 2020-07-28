#include <errno.h>
#include <limits.h>
#include <stdlib.h>
#include <algorithm>

#include <CoreFoundation/CoreFoundation.h>
#include <vector>
#include "NaiveArray.h"

typedef std::vector<void*> vector_t;

unsigned kInitialArrayLength;

#if ! (USE_CF || USE_NAIVE || USE_VECTOR)
#define USE_CF 1
#endif

#if USE_CF
typedef CFMutableArrayRef Array;

#elif USE_NAIVE
typedef NaiveArray Array;

#elif USE_VECTOR
typedef vector_t* Array;

#endif

void insertItemsAtEnd(CFMutableArrayRef array, unsigned numItems) {
	while (numItems--) {
		CFArrayAppendValue(array, NULL);
	}
}

void insertItemsAtEnd(NaiveArray array, unsigned numItems) {
	while (numItems--) {
		appendValue(array, NULL);
	}
}

void insertItemsAtEnd(vector_t* array, unsigned numItems) {
	while (numItems--) {
		array->push_back(NULL);
	}
}

void insertItemsAtBeginning(CFMutableArrayRef array, unsigned numItems) {
	while (numItems--) {
		CFArrayInsertValueAtIndex(array, 0, NULL);
	}
}

void insertItemsAtBeginning(NaiveArray array, unsigned numItems) {
	while (numItems--) {
		insertValue(array, 0, NULL);
	}
}

void insertItemsAtBeginning(vector_t* array, unsigned numItems) {
	while (numItems--) {
		array->insert(array->begin(), NULL);
	}
}

void insertItemsRandomly(CFMutableArrayRef array, unsigned numItems, const unsigned* randomLocations) {
	while (numItems--) {
		CFArrayInsertValueAtIndex(array, *randomLocations++, NULL);
	}
}

void insertItemsRandomly(NaiveArray array, unsigned numItems, const unsigned* randomLocations) {
	while (numItems--) {
		insertValue(array, *randomLocations++, NULL);
	}
}

void insertItemsRandomly(vector_t* array, unsigned numItems, const unsigned* randomLocations) {
	while (numItems--) {
		array->insert(array->begin() + *randomLocations++, NULL);
	}
}

void deleteItemsFromEnd(CFMutableArrayRef array, unsigned numItems) {
	unsigned arrayLength = CFArrayGetCount(array);
	while (numItems--) {
		CFArrayRemoveValueAtIndex(array, --arrayLength);
	}
}

void deleteItemsFromEnd(NaiveArray array, unsigned numItems) {
	unsigned arrayLength = getCount(array);
	while (numItems--) {
		deleteValue(array, --arrayLength);
	}
}

void deleteItemsFromEnd(vector_t* array, unsigned numItems) {
	while (numItems--) {
		array->pop_back();
	}
}

void deleteItemsFromBeginning(CFMutableArrayRef array, unsigned numItems) {
	while (numItems--) {
		CFArrayRemoveValueAtIndex(array, 0);
	}
}

void deleteItemsFromBeginning(NaiveArray array, unsigned numItems) {
	while (numItems--) {
		deleteValue(array, 0);
	}
}

void deleteItemsFromBeginning(vector_t* array, unsigned numItems) {
	while (numItems--) {
		array->erase(array->begin());
	}
}

void deleteItemsRandomly(CFMutableArrayRef array, unsigned numItems, unsigned *locations) {
	while (numItems--) {
		CFArrayRemoveValueAtIndex(array, *locations++);
	}
}

void deleteItemsRandomly(NaiveArray array, unsigned numItems, unsigned *locations) {
	while (numItems--) {
		deleteValue(array, *locations++);
	}
}

void deleteItemsRandomly(vector_t* array, unsigned numItems, unsigned *locations) {
	while (numItems--) {
		array->erase(array->begin() + *locations++);
	}
}


void walkItemsForward(CFMutableArrayRef array) {
	unsigned i, count = CFArrayGetCount(array);
	for (i=0; i < count; i++) {
		emptyFunction(CFArrayGetValueAtIndex(array, i));
	}
}


void walkItemsForward(NaiveArray array) {
	unsigned i, count = getCount(array);
	for (i=0; i < count; i++) {
		emptyFunction(getValue(array, i));
	}
}

void walkItemsForward(vector_t* array) {
	unsigned i, count = array->size();
	for (i=0; i < count; i++) {
		emptyFunction(array->at(i));
	}
}

void walkItemsBackward(CFMutableArrayRef array) {
	unsigned i = CFArrayGetCount(array);
	while (i--) {
		emptyFunction(CFArrayGetValueAtIndex(array, i));
	}
}


void walkItemsBackward(NaiveArray array) {
	unsigned i = getCount(array);
	while (i--) {
		emptyFunction(getValue(array, i));
	}
}

void walkItemsBackward(vector_t* array) {
	unsigned i = array->size();
	while (i--) {
		emptyFunction(array->at(i));
	}
}

void walkItemsInOrder(CFMutableArrayRef array, unsigned* order) {
	unsigned i, count = CFArrayGetCount(array);
	for (i=0; i < count; i++) {
		emptyFunction(CFArrayGetValueAtIndex(array, *order++));
	}
}


void walkItemsInOrder(NaiveArray array, unsigned* order) {
	unsigned i, count = getCount(array);
	for (i=0; i < count; i++) {
		emptyFunction(getValue(array, *order++));
	}
}

void walkItemsInOrder(vector_t* array, unsigned* order) {
	unsigned i, count = array->size();
	for (i=0; i < count; i++) {
		emptyFunction(array->at(*order++));
	}
}
Array newArray() {
	Array array;
		
	#if USE_CF
		array = CFArrayCreateMutable(NULL, 0, NULL);
	#elif USE_NAIVE
		array = newNaiveArray();
	#elif USE_VECTOR
		array = new vector_t();
	#endif
	insertItemsAtEnd(array, kInitialArrayLength);
	return array;
}

void destroyArray(Array array) {
	#if USE_CF
		CFRelease(array);
	#elif USE_NAIVE
		destroyNaiveArray(array);
	#elif USE_VECTOR
		delete array;
	#endif
}

// Fix for duplicate symbol error
int _main(int argc, char* argv[]) {
// int main(int argc, char* argv[]) {
	Array array;
	
	double start, end;
	
	const unsigned numItemsToInsert = 10000;
	const unsigned numItemsToDelete = 10000;
	
	srandom(0);
	
	if (argv[1]) kInitialArrayLength = strtoul(argv[1], NULL, 0);
	if (kInitialArrayLength == 0 || kInitialArrayLength == UINT_MAX) {
		kInitialArrayLength = 100000;
		printf("Defaulting to an initial length of %u\n", kInitialArrayLength);
	}
	

	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	insertItemsAtEnd(array, numItemsToInsert);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("End insertion time per item: %f us\n", 1000000. * (end - start) / numItemsToInsert);
	

	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	insertItemsAtBeginning(array, numItemsToInsert);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Beginning insertion time per item: %f us\n", 1000000. * (end - start) / numItemsToInsert);
	
	unsigned* randomInsertionLocations = new unsigned[numItemsToInsert];
	unsigned i;
	for (i=0; i < numItemsToInsert; i++) {
		randomInsertionLocations[i] = random() % (kInitialArrayLength + 1 + i);
	}
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	insertItemsRandomly(array, numItemsToInsert, randomInsertionLocations);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Random insertion time per item: %f us\n", 1000000. * (end - start) / numItemsToInsert);
	delete[] randomInsertionLocations;
	
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	walkItemsForward(array);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Forwards walk time per item: %f us\n", 1000000. * (end - start) / kInitialArrayLength);
	
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	walkItemsBackward(array);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Backward walk time per item: %f us\n", 1000000. * (end - start) / kInitialArrayLength);
	
	unsigned* randomOrder = new unsigned[kInitialArrayLength];
	for (i=0; i < kInitialArrayLength; i++) randomOrder[i] = i;
	std::random_shuffle(randomOrder, randomOrder + kInitialArrayLength);
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	walkItemsInOrder(array, randomOrder);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Random walk time per item: %f us\n", 1000000. * (end - start) / kInitialArrayLength);
	delete[] randomOrder;
	
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	deleteItemsFromBeginning(array, numItemsToDelete);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Beginning deletion time per item: %f us\n", 1000000. * (end - start) / numItemsToDelete);
	
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	deleteItemsFromEnd(array, numItemsToDelete);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Ending deletion time per item: %f us\n", 1000000. * (end - start) / numItemsToDelete);
	
	unsigned* randomDeletionLocations = new unsigned[numItemsToDelete];
	for (i=0; i < numItemsToDelete; i++) randomDeletionLocations[i] = random() % (kInitialArrayLength - i);
	array = newArray();
	start = CFAbsoluteTimeGetCurrent();
	deleteItemsRandomly(array, numItemsToDelete, randomDeletionLocations);
	end = CFAbsoluteTimeGetCurrent();
	destroyArray(array);
	printf("Random deletion time per item: %f us\n", 1000000. * (end - start) / numItemsToDelete);
	delete[] randomDeletionLocations;
	
	return 0;
}
