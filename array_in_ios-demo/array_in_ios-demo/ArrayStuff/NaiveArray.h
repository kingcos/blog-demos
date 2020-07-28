typedef struct NaiveArray_t* NaiveArray;

NaiveArray newNaiveArray(void);

void appendValue(NaiveArray array, void* value);

void insertValue(NaiveArray array, unsigned index, void* value);

void* getValue(NaiveArray array, unsigned index);

void deleteValue(NaiveArray array, unsigned index);

unsigned getCount(NaiveArray array);

void destroyNaiveArray(NaiveArray array);

void emptyFunction(const void* unused);

