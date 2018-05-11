#pragma once

class Genome;

#include <vector>

class Species {

public:
	Species();
	~Species();

	Genome *crossover(Genome *g1, Genome *g2);
	Genome *breedChild();
	void calculateAverageFitness();

	double topFitness;
	double staleness;
	std::vector<Genome *> genomes;
	double averageFitness;

private:
};