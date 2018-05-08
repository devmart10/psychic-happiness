#ifndef INDIVIDUAL_HXX
#define INDIVIDUAL_HXX

class Individual {
public:
	Individual();
	~Individual();
	int getDirection();
	void calcFitness();
	double getFitness();
private:
	double fitness;
	double* dna;
};

#endif