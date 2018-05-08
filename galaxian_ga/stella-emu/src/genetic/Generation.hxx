#ifndef GENERATION_HXX
#define GENERATION_HXX

#define POPULATION_SIZE 4

#include <vector>
#include "Individual.hxx"

class Generation {
public:	
	int populationIndex;
	
	Generation();
	~Generation();
	Generation* createNewGeneration();
	Individual* getCurrentPlayer();
	Individual* getNextPlayer();
private:
	std::vector<Individual *> population;
};

#endif