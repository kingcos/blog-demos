#include "NaiveArray.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct NaiveArray_t {
	unsigned length;
	unsigned capacity;
	void** values;
};

NaiveArray newNaiveArray(void) {
	NaiveArray result = (NaiveArray)malloc(sizeof *result);
	if (result) {
		result->length = 0;
		result->capacity = 0;
		result->values = NULL;
	}
	return result;
}

static void ensureCapacity(NaiveArray array, unsigned capacity) {
	if (capacity > array->capacity) {
		if (array->capacity < 32) array->capacity = 32;
		while (capacity > array->capacity) {
			array->capacity *= 2;
		}
		array->values = (void**)realloc(array->values, array->capacity * sizeof *array->values);
		if (! array->values) {
			fprintf(stderr, "Unable to allocate %u bytes\n", array->capacity * sizeof *array->values);
			exit(EXIT_FAILURE);
		}
		
	}
}

void appendValue(NaiveArray array, void* value) {
	ensureCapacity(array, array->length + 1);
	array->values[array->length++] = value;
}

void insertValue(NaiveArray array, unsigned index, void* value) {
	ensureCapacity(array, array->length + 1);
	memmove(array->values + index, array->values + index + 1, array->length - index);
	array->length++;
	array->values[index] = value;
}

void deleteValue(NaiveArray array, unsigned index) {
	array->length--;
	unsigned numItemsAfterIndex = array->length - index;
	if (numItemsAfterIndex) memmove(array->values + index, array->values + index + 1, numItemsAfterIndex * sizeof *array->values);
}


unsigned getCount(NaiveArray array) {
	return array->length;
}

void* getValue(NaiveArray array, unsigned index) {
	return array->values[index];
}

void destroyNaiveArray(NaiveArray array) {
	if (array) free(array->values);
	free(array);
}



void emptyFunction(const void* unused) { }
