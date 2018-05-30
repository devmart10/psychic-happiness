#pragma once

#include <vector>

class Genome;
class Pool;

class Species {

public:
	Species(Pool *);
	~Species();

	Genome *crossover(Genome *g1, Genome *g2);
	Genome *breedChild();
	void calculateAverageFitness();

	double topFitness;
	double staleness;
	std::vector<Genome *> genomes;
	double averageFitness;

private:
	Pool *pool;
};