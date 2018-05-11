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

#include <memory>
#include "EventHandler.hxx"
#include "OSystem.hxx"
#include "genetic_settings.hxx"
#include "GalaxianGameState.hxx"

class Neuron;
class Pool;

class GalaxianGeneticAlgorithm {
public:	
	/**
	Create a new genetic algorithm parent object
	*/
	GalaxianGeneticAlgorithm(GalaxianGameState* gs);
	virtual ~GalaxianGeneticAlgorithm();

protected:

public:
	void initializeAlgorithm();
	void startSession();
	void finishSession();
	bool isRShiftKeyDown();
	bool isResetKeyDown();
	std::map<int, bool> evaluate();

private:
	Pool *myPool;
	Console *myConsole;
	GalaxianGameState* myGalaxianGameState;
};

#endif