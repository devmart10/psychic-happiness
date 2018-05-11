#include <iostream>

#include "Console.hxx"
#include "GalaxianGameState.hxx"

using namespace std;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGameState::GalaxianGameState()
{
	reset();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

GalaxianGameState::~GalaxianGameState()
{
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::reset() {
	enemyPosMemOffset = 2;
	enemyPositions.clear();
	gameRunning = false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::tick() {
	if (gameRunning) {
		for (int i = 0; i < 3; i++) {
			enemyPosMem[i].first = myConsole->retreiveByte(0xC0 + i);
			enemyPosMem[i].second = myConsole->retreiveByte(0xC5 + i);
		}

		if (enemyPosMem[enemyPosMemOffset].second == 0) {
			enemyPosMemOffset = --enemyPosMemOffset < 0 ? enemyPosMemOffset : 2;
		}
	}
	else {
		gameRunning = isGameRunning();
	}
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGameState::isGameRunning() {
	return myConsole->retreiveByte(0xB9) < 3;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

vector<pair<int, int>> GalaxianGameState::getEnemyPositions() {
	enemyPositions.clear();

	enemyPositions.push_back(enemyPosMem[enemyPosMemOffset]);

	return enemyPositions;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

void GalaxianGameState::setConsole(Console *console) {
	myConsole = console;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGameState::getPlayerScore() {
	int tens = myConsole->retreivePartialByte(0xAE, 4, 0);
	int hundreds = myConsole->retreivePartialByte(0xAD, 4, 4);
	int thousands = myConsole->retreivePartialByte(0xAD, 4, 0);
	int ten_thousands = myConsole->retreivePartialByte(0xAC, 4, 4);
	int hun_thousands = myConsole->retreivePartialByte(0xAC, 4, 0);

	return tens * 10 + hundreds * 100 + thousands * 1000 +
		ten_thousands * 10000 + hun_thousands * 100000;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

bool GalaxianGameState::isPlayerDead() {
	return myConsole->retreiveByte(0xB2) != 0;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

vector<double> GalaxianGameState::getInputs() {
	vector<double> inputs;

	// TODO

	return inputs;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

int GalaxianGameState::getPlayerPosition() {
	return myConsole->retreiveByte(0xE4);
}