#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <assert.h>

void trying(int *way);

int main(){
	int way;

	trying(&way);
	
	std::cout << way;
}

void trying(int *way){
	*way = 3;
}