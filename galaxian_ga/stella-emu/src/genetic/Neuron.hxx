#pragma once

#include <vector>

class Gene;

class Neuron {

public:
	Neuron();

	double value;
	std::vector<Gene *> incoming;
};