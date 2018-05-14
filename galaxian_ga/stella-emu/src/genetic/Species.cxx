#include "Species.hxx"
#include "Genome.hxx"
#include "Gene.hxx"
#include "Pool.hxx"
#include <algorithm>

#define CROSSOVER_CHANCE 0.75

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Species::Species(Pool *_pool) :
	topFitness(0),
	staleness(0),
	averageFitness(0),
	pool(_pool)
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Species::~Species() {
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Genome *Species::crossover(Genome *g1, Genome *g2) {
	if (g2->fitness > g1->fitness) {
		Genome *temp = g2; 
		g2 = g1; 
		g1 = temp;
	}

	Genome *newGenome = new Genome(pool);

	map<int, Gene *> innovations2;
	for (Gene *gene : g2->genes) {
		innovations2[gene->innovation] = gene;
	}

	for (Gene *gene1 : g1->genes) {
		Gene *gene2 = innovations2[gene1->innovation];
		
		if (gene2 != NULL && (rand() > RAND_MAX / 2) && gene2->enabled) {
			newGenome->genes.push_back(new Gene(*gene2));
		}
		else {
			newGenome->genes.push_back(new Gene(*gene1));
		}
	}

	newGenome->maxNeuron = max(g1->maxNeuron, g2->maxNeuron);
	newGenome->mutationRates = g1->mutationRates;

	return newGenome;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Genome *Species::breedChild() {
	Genome *child;

	if (rand() / (double)RAND_MAX > CROSSOVER_CHANCE) {
		child = crossover(
			genomes[rand() / (double)RAND_MAX * genomes.size()],
			genomes[rand() / (double)RAND_MAX * genomes.size()]
		);
	}
	else {
		child = new Genome(*genomes[rand() / (double)RAND_MAX * genomes.size()]);
	}

	child->mutate();

	return child;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Species::calculateAverageFitness() {
	double total = 0;

	for (Genome *genome : genomes) {
		total += genome->globalRank;
	}

	averageFitness = total / genomes.size();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -