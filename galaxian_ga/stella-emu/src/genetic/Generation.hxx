#ifndef GENERATION_HXX
#define GENERATION_HXX

#define POPULATION_SIZE 4

#include <list>
#include "Individual.hxx"

class Generation {
public:	
	Generation(int genId);
	~Generation();
	Generation * spawnNextGeneration();
	Individual * getNextPlayer();
	const int &id;
	Individual *currentPlayer;

private:
	int myGenerationId;

	std::list<Individual *>::iterator popItr;
	std::list<Individual *> population;
};

#endif