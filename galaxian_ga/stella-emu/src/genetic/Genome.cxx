#include <iostream>
#include <Windows.h>
#include <memory>

#include "GalaxianGameState.hxx"
#include "Gene.hxx"
#include "Neuron.hxx"
#include "Pool.hxx"
#include "genetic_settings.hxx"

#include "Genome.hxx"

#define MUTATE_CONNECTIONS_CHANCE 0.25
#define MUTATE_LINK_CHANCE 4.0
#define MUTATE_BIAS_CHANCE 0.4
#define MUTATE_NODE_CHANCE 0.5
#define MUTATE_ENABLE_CHANCE 0.2
#define MUTATE_DISABLE_CHANCE 0.4
#define MUTATE_STEP_CHANCE 0.1
#define PERTURB_CHANCE 0.9

using namespace std;

int randomNeuron(vector<Gene *> genes, bool isInput);
double sigmoid(double x);
bool containsLink(vector<Gene *> genes, Gene *g);

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Genome::Genome(Pool *_pool) :
	fitness(0),
	maxNeuron(0),
	globalRank(0),
	pool(_pool)
{
	mutationRates["connections"] = MUTATE_CONNECTIONS_CHANCE;
	mutationRates["link"] = MUTATE_LINK_CHANCE;
	mutationRates["bias"] = MUTATE_BIAS_CHANCE;
	mutationRates["node"] = MUTATE_NODE_CHANCE;
	mutationRates["enable"] = MUTATE_ENABLE_CHANCE;
	mutationRates["disable"] = MUTATE_DISABLE_CHANCE;
	mutationRates["step"] = MUTATE_STEP_CHANCE;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Genome::Genome(const Genome &old) :
	maxNeuron(old.maxNeuron),
	mutationRates(old.mutationRates),
	genes(old.genes),
	pool(old.pool)
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Genome::~Genome()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::initBasicGenome() {
	innovation = 1;
	maxNeuron = NUM_INPUTS;
	mutate();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::mutate() {
	for (pair<string, double> rate : mutationRates) {
		if (rand() > RAND_MAX / 2) {
			rate.second *= .95;
		}
		else {
			rate.second *= 1.05263;
		}
	}

	if (rand() / (double)RAND_MAX < mutationRates["connections"]) {
		pointMutate();
	}

	double p = mutationRates["link"];
	while (p-- > 0) {
		if (rand() / (double)RAND_MAX < p) {
			linkMutate(false);
		}
	}

	p = mutationRates["bias"];
	while (p-- > 0) {
		if (rand() / (double)RAND_MAX < p) {
			linkMutate(true);
		}
	}

	p = mutationRates["node"];
	while (p-- > 0) {
		if (rand() / (double)RAND_MAX < p) {
			nodeMutate();
		}
	}

	p = mutationRates["enable"];
	while (p-- > 0) {
		if (rand() / (double)RAND_MAX < p) {
			enableDisableMutate(true);
		}
	}

	p = mutationRates["disable"];
	while (p-- > 0) {
		if (rand() / (double)RAND_MAX < p) {
			enableDisableMutate(false);
		}
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::pointMutate() {
	double step = mutationRates["step"];

	for (Gene *gene : genes) {
		if (rand() / (double)RAND_MAX < PERTURB_CHANCE) {
			gene->weight += (rand() / (double)RAND_MAX) * step * 2 - step;
		}
		else {
			gene->weight = (rand() / (double)RAND_MAX) * 4 - 2;
		}
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::linkMutate(bool forceBias) {
	int n1 = randomNeuron(genes, true);
	int n2 = randomNeuron(genes, false);

	Gene *newLink = new Gene();

	if ((n1 <= NUM_INPUTS && n2 <= NUM_INPUTS) ||
		(n1 >= MAX_NODES && n2 >= MAX_NODES)   ||
		(n1 == n2)) {
		return;
	}

	if (n2 <= NUM_INPUTS) {
		int temp = n1; 
		n1 = n2; 
		n2 = n1;
	}

	newLink->into = n1;
	newLink->out = n2;

	if (forceBias) {
		newLink->into = NUM_INPUTS - 1;
	}

	if (containsLink(genes, newLink)) {
		return;
	}

	newLink->innovation = pool->newInnovation();
	newLink->weight = (rand() / (double)RAND_MAX) * 4 - 2;

	genes.push_back(newLink);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int randomNeuron(vector<Gene *> genes, bool isInput) {
	map<int, bool> neurons;

	if (isInput) {
		for (int i = 0; i < NUM_INPUTS; i++) {
			neurons[i] = true;
		}
	}

	for (int i = 0; i < NUM_OUTPUTS; i++) {
		neurons[MAX_NODES + i] = true;
	}

	for (Gene *gene : genes) {
		if (isInput || gene->into > NUM_INPUTS) {
			neurons[gene->into] = true;
		}
		if (isInput || gene->out > NUM_INPUTS) {
			neurons[gene->out] = true;
		}
	}

	int n = (rand() / (double)RAND_MAX) * neurons.size() + 1;

	for (pair<int, bool> p : neurons) {
		if (--n == 0) {
			return p.first;
		}
	}

	return 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool containsLink(vector<Gene *> genes, Gene *g) {
	for (Gene *gene : genes) {
		if (gene->into == g->into && gene->out == g->out) {
			return true;
		}
	}

	return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::enableDisableMutate(bool enable) {
	vector<Gene *> candidates;

	for (Gene *gene : genes) {
		if (gene->enabled == !enable) {
			candidates.push_back(gene);
		}
	}

	if (candidates.size() == 0) {
		return;
	}

	Gene *toFlip = candidates[(rand() / (double)RAND_MAX) * candidates.size()];
	toFlip->enabled = !toFlip->enabled;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::nodeMutate() {
	if (genes.size() == 0) {
		return;
	}

	maxNeuron++;

	Gene *gene = genes[floor((rand() / (double)RAND_MAX) * genes.size())];
	if (!gene->enabled) {
		return;
	}

	Gene *gene1 = new Gene(*gene);
	gene1->out = maxNeuron;
	gene1->weight = 1.0;
	gene1->innovation = pool->newInnovation();
	gene1->enabled = true;
	genes.push_back(gene1);

	Gene *gene2 = new Gene(*gene);
	gene2->into = maxNeuron;
	gene2->innovation = pool->newInnovation();
	gene2->enabled = true;
	genes.push_back(gene2);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void Genome::generateNetwork() {
	map<int, Neuron *> network;

	for (int i = 0; i < NUM_INPUTS; i++) {
		network[i] = new Neuron();
	}

	for (int i = 0; i < NUM_OUTPUTS; i++) {
		network[MAX_NODES + i] = new Neuron();
	}

	for (Gene *gene : genes) {
		if (gene->enabled) {
			if (network[gene->out] == NULL) {
				network[gene->out] = new Neuron();
			}
			Neuron *neuron = network[gene->out];
			neuron->incoming.push_back(gene);

			if (network[gene->into] == NULL) {
				network[gene->into] = new Neuron();
			}
		}
	}

	this->network = network;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

std::map<int, bool> Genome::evaluateNetwork(vector<double> inputs) {
	map<int, bool> outputs;

	for (int i = 0; i < NUM_INPUTS; i++) {
		network[i]->value = inputs[i];
	}

	for (pair<int, Neuron *> p : network) {
		double sum = 0;
		for (Gene *incoming : p.second->incoming) {
			Neuron *other = network[incoming->into];
			sum += incoming->weight * other->value;
		}

		if (p.second->incoming.size() > 0) {
			p.second->value = sigmoid(sum);
		}
	}

	for (int i = 0; i < NUM_OUTPUTS; i++) {
		if (network[MAX_NODES + i]->value > 0) {
			outputs[i] = true;
		}
		else {
			outputs[i] = false;
		}
	}

	return outputs;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

double sigmoid(double x) {
	return 2.0 / (1 + exp(-4.9*x)) - 1;
}