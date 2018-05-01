//============================================================================
//
//   SSSS                        PPPPP
//  SS  SS                       PP  PP                        jj
//  SS       eeee  nn nn         PP   PP rr rrr    oooo
//   SSSS   ee  ee nnn  nn       PPPPPP  rrrr rr  oo  oo       jj
//      SS  eeeeee nn   nn       PP      rr      oo    oo      jj
//  SS  SS  ee     nn   nn ...   PP      rr       oo  oo       jj
//   SSSS    eeeee nn   nn ...   PP      rr        oooo   jj   jj
//                                                        jjjjj
//
// Senior Project Genetic Algorithm of Cole Twitchell and Devon Martin
// Cal Poly, San Luis Obispo 2018
//
// For more information, questions, or inqueries, contact colemtwitchell@gmail.com.
//============================================================================

#ifndef GALAXIAN_GENETIC_ALGORITHM_HXX
#define GALAXIAN_GENETIC_ALGORITHM_HXX

#include "genetic_settings.hxx"

class GalaxianGeneticAlgorithm {
public:
	/**
	Create a new genetic algorithm parent object
	*/
	GalaxianGeneticAlgorithm();
	virtual ~GalaxianGeneticAlgorithm();
	
public:
	void initializeAlgorithm();
	void printTickMessage();
	bool isMemDumpKeyDown();

private:

protected:

};

#endif