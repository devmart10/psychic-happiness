#pragma once

class Gene {

public:
	Gene();
	Gene(const Gene &oldGene);

	int into;
	int out;
	double weight;
	bool enabled;
	double innovation;

private:

};