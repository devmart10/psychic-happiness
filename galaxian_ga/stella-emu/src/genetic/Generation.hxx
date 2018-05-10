#ifndef GENERATION_HXX
#define GENERATION_HXX

#define POPULATION_SIZE 4

#include <vector>
#include "Individual.hxx"

class Generation {
public:	
	int populationIndex;
	
	Generation(int genId);
	~Generation();
	Generation * spawnNextGeneration();
	Individual * getCurrentPlayer();
	Individual * getNextPlayer();
	const int &id;

private:
	int myGenerationId;
	std::vector<Individual *> population;
};

#endif