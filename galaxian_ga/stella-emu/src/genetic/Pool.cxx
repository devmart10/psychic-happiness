#include "Pool.hxx"
#include "genetic_settings.hxx"
#include "Species.hxx"
#include "Genome.hxx"
#include "Gene.hxx"

#include <algorithm>

#define DELTA_DISJOINT 2.0
#define DELTA_WEIGHTS 0.4
#define DELTA_THRESHOLD 1.0

#define STALE_SPECIES 15

using namespace std;

bool sameSpecies(Genome *g1, Genome *g2);
double disjoint(vector<Gene *> g1, vector<Gene *> g2);
double weights(vector<Gene *> g1, vector<Gene *> g2);
bool genomeGT(Genome *g1, Genome *g2);
bool genomeLT(Genome *g1, Genome *g2);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Pool::Pool() :
	generation(0),
	currentSpecies(0),
	currentGenome(0),
	maxFitness(0),
	innovation(NUM_OUTPUTS)
{
	for (int i = 0; i < POPULATION_SIZE; i++) {
		Genome *genome = new Genome(this);
		genome->initBasicGenome();
		addToSpecies(genome);
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Pool::~Pool() {
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::initializeRun() {
	species[currentSpecies]->genomes[currentGenome]->generateNetwork();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::addToSpecies(Genome *genome) {
	bool found = false;

	for (Species *s : species) {
		if (!found && sameSpecies(genome, s->genomes[0])) {
			s->genomes.push_back(genome);
			found = true;
			break;
		}
	}

	if (!found) {
		Species *newSpecies = new Species(this);
		newSpecies->genomes.push_back(genome);
		species.push_back(newSpecies);
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool sameSpecies(Genome *g1, Genome *g2) {
	double dd = DELTA_DISJOINT * disjoint(g1->genes, g2->genes);
	double dw = DELTA_WEIGHTS * weights(g1->genes, g2->genes);

	return dd + dw < DELTA_THRESHOLD;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

double disjoint(vector<Gene *> g1, vector<Gene *> g2) {
	map<int, bool> i1, i2;

	for (Gene *gene : g1) {
		i1[gene->innovation] = true;
	}
	for (Gene *gene : g2) {
		i2[gene->innovation] = true;
	}

	int disjointGenes = 0;
	for (Gene *gene : g1) {
		if (!i2[gene->innovation]) {
			disjointGenes++;
		}
	}
	for (Gene *gene : g2) {
		if (!i1[gene->innovation]) {
			disjointGenes++;
		}
	}

	return disjointGenes / ((double)max(g1.size(), g2.size()));
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

double weights(vector<Gene *> g1, vector<Gene *> g2) {
	map<int, Gene *> i;

	for (Gene *gene : g2) {
		i[gene->innovation] = gene;
	}

	int sum = 0;
	double coincident = 0;
	for (Gene *gene : g1) {
		if (i[gene->innovation] != nullptr) {
			Gene *gene2 = i[gene->innovation];
			sum += abs(gene->weight - gene2->weight);
			coincident++;
		}
	}

	return sum / coincident;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int Pool::newInnovation() {
	return ++innovation;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::cullSpecies(bool cutToOne) {
	for (Species *s : species) {
		sort(s->genomes.begin(), s->genomes.end(), genomeGT);

		int remaining = cutToOne ? 1 : ceil(s->genomes.size() / 2.0);
		while (s->genomes.size() > remaining) {
			s->genomes.pop_back();
		}
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool genomeGT(Genome *g1, Genome *g2) {
	return g1->fitness > g2->fitness;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool genomeLT(Genome *g1, Genome *g2) {
	return g1->fitness < g2->fitness;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::rankGlobally() {
	vector<Genome *> global;

	for (Species *s : species) {
		for (Genome *genome : s->genomes) {
			global.push_back(genome);
		}
	}

	sort(global.begin(), global.end(), genomeLT);

	for (int i = 0; i < global.size(); i++) {
		global[i]->globalRank = i;
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

double Pool::totalAverageFitness() {
	double total = 0;

	for (Species *s : species) {
		total += s->averageFitness;
	}

	return total;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::removeStaleSpecies() {
	vector<Species *> survivors;

	for (Species *s : species) {
		sort(s->genomes.begin(), s->genomes.end(), genomeGT);

		if (s->genomes[0]->fitness > s->topFitness) {
			s->topFitness = s->genomes[0]->fitness;
			s->staleness = 0;
		}
		else {
			s->staleness++;
		}

		if (s->staleness < STALE_SPECIES || s->topFitness >= maxFitness) {
			survivors.push_back(s);
		}
	}

	species = survivors;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::removeWeakSpecies() {
	vector<Species *> survivors;

	double sum = totalAverageFitness();
	for (Species *s : species) {
		double breed = floor(s->averageFitness / sum * POPULATION_SIZE);
		if (breed > 1) {
			survivors.push_back(s);
		}
	}

	species = survivors;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::createNewGeneration() {
	cullSpecies(false);
	rankGlobally();
	removeStaleSpecies();
	rankGlobally();

	for (Species *s : species) {
		s->calculateAverageFitness();
	}
	removeWeakSpecies();

	double sum = totalAverageFitness();
	vector<Genome *> children;

	for (Species *s : species) {
		double breed = floor(s->averageFitness / sum * POPULATION_SIZE);
		for (int i = 0; i < breed; i++) {
			children.push_back(s->breedChild());
		}
	}

	cullSpecies(true);
	while (children.size() + species.size() < POPULATION_SIZE) {
		Species *s = species[floor(rand() / (double)RAND_MAX) * species.size()];
		children.push_back(s->breedChild());
	}

	for (Genome *child : children) {
		addToSpecies(child);
	}

	generation++;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Pool::nextGenome() {
	if (++currentGenome >= species[currentSpecies]->genomes.size()) {
		currentGenome = 0;
		if (++currentSpecies >= species.size()) {
			createNewGeneration();
			currentSpecies = 0;
		}
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool Pool::fitnessAlreadyMeasured() {
	return species[currentSpecies]->genomes[currentGenome]->fitness != 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -